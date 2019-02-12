import contextlib
import glob
import os
import errno
import sys
import pkg_resources
import re
import subprocess
from os import path

import pip
from pip._internal import main as pip_main
from wheel import wheelfile
from six.moves import reload_module

from piprules import util

class Error(Exception):

    """Base exception for the wheels module"""

def _create_no_hash_requirements_file(requirements_file_path):
    regex = re.compile(r"--hash=sha256:.+")
    with open(requirements_file_path, "rt") as fin:
        with open(requirements_file_path[:-4] + "_no_hash.txt", "wt") as fout:
            for line in fin:
                fout.write(regex.sub("", line))

def _check_offline_cache(cache_directory, build_directory, dest_directory, requirements_file_path, *extra_args):
    _create_no_hash_requirements_file(requirements_file_path)
    # Have to run pip in a subprocess here as it can not be called twice in the same process
    result = subprocess.run(
        [
            "python3", util.get_import_path_of_module(pip) + "/pip/__main__.py",
            "wheel",
            "--no-index",
            "--find-links", cache_directory,
            "-w", dest_directory,
            "-r", requirements_file_path[:-4] + "_no_hash.txt",
        ]
    )
    os.remove(requirements_file_path[:-4] + "_no_hash.txt")
    if result.returncode != 0:
        return False

    return True

def download(cache_directory, build_directory, dest_directory, requirements_file_path, *extra_args):
    cached = _check_offline_cache(cache_directory, build_directory, dest_directory, requirements_file_path, *extra_args)
    if not cached:
        reload_module(pip._internal)
        with _add_pip_import_paths_to_pythonpath():
            return_code = pip._internal.main(
                args=[
                    "wheel",
                    "-b", build_directory,
                    "-w", dest_directory,
                    "-r", requirements_file_path,
                ] + list(extra_args)
            )

            if return_code > 0:
                sys.exit(return_code)

        cache_directory = os.path.expanduser(cache_directory)

        try:
            os.makedirs(cache_directory)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise

        for f in (f for f in os.listdir(dest_directory) if path.isfile(path.join(dest_directory, f)) and f.endswith(".whl")):
            os.link(path.join(dest_directory, f), path.join(cache_directory, f))


@contextlib.contextmanager
def _add_pip_import_paths_to_pythonpath():
    import pip
    import setuptools
    import wheel

    import_paths = [util.get_import_path_of_module(m) for m in [pip, setuptools, wheel]]
    with util.prepend_to_pythonpath(import_paths):
        yield


def find_all(directory):
    for matching_path in glob.glob("{}/*.whl".format(directory)):
        yield matching_path


def unpack(wheel_path, dest_directory):
    # TODO(): don't use unsupported wheel library
    with wheelfile.WheelFile(wheel_path) as wheel_file:
        distribution_name = wheel_file.parsed_filename.group("name")
        library_name = util.normalize_distribution_name(distribution_name)
        package_directory = os.path.join(dest_directory, library_name)
        wheel_file.extractall(package_directory)

    try:
        return next(pkg_resources.find_distributions(package_directory))
    except StopIteration:
        raise DistributionNotFoundError(package_directory)


class DistributionNotFoundError(Error):
    def __init__(self, package_directory):
        super(DistributionNotFoundError, self).__init__()
        self.package_directory = package_directory

    def __str__(self):
        return "Could not find in Python distribution in directory {}".format(
            self.package_directory
        )
