workspace(name = "com_apt_itude_rules_pip")

# Dependencies for this repository

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//rules:dependencies.bzl", "pip_rules_dependencies")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

pip_rules_dependencies()

# Buildifier repositories

http_archive(
    name = "io_bazel_rules_go",
    urls = ["https://github.com/bazelbuild/rules_go/archive/0.18.4.tar.gz"],
    strip_prefix = "rules_go-0.18.4",
    sha256 = "fb8efea4020f484f9a2b20806d4129d5dc6c50b559f550f89da7fb5153217ab0",
)

http_archive(
    name = "com_github_bazelbuild_buildtools",
    urls = ["https://github.com/bazelbuild/buildtools/archive/0.25.0.tar.gz"],
    strip_prefix = "buildtools-0.25.0",
    sha256 = "3d934630a7ece3a018eec29573705b999020923e9741f64dcee78b7e7fa4555e",
)

load(
    "@io_bazel_rules_go//go:deps.bzl",
    "go_register_toolchains",
    "go_rules_dependencies",
)

go_rules_dependencies()

go_register_toolchains()

load(
    "@com_github_bazelbuild_buildtools//buildifier:deps.bzl",
    "buildifier_dependencies",
)

buildifier_dependencies()

# PIP repositories

load("//rules:repository.bzl", "pip_repository")
load("//:python.bzl", "PYTHON2", "PYTHON3")

pip_repository(
    name = "pip2",
    python_interpreter = PYTHON2,
    requirements_per_platform = {
        "//thirdparty/pip/2:requirements-linux.txt": "linux",
        "//thirdparty/pip/2:requirements-osx.txt": "osx",
    },
    # quiet = False,
    wheel_cache = "~/.cache/bazel/wheels"
)

pip_repository(
    name = "pip3",
    python_interpreter = PYTHON3,
    requirements_per_platform = {
        "//thirdparty/pip/3:requirements-linux.txt": "linux",
        "//thirdparty/pip/3:requirements-osx.txt": "osx",
    },
    # quiet = False,
    wheel_cache = "~/.cache/bazel/wheels"
)
