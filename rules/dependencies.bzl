load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_WHEEL_BUILD_FILE_CONTENT = """
py_library(
    name = "lib",
    srcs = glob(["**/*.py"]),
    data = glob(
        ["**/*"],
        exclude = [
            "**/*.py",
            "**/* *",  # Bazel runfiles cannot have spaces in the name
            "BUILD",
            "WORKSPACE",
            "*.whl.zip",
        ],
    ),
    imports = ["."],
    visibility = ["//visibility:public"],
)
"""

def pip_rules_dependencies():
    _remote_wheel(
        name = "pip",
        url = "https://files.pythonhosted.org/packages/d7/41/34dd96bd33958e52cb4da2f1bf0818e396514fd4f4725a79199564cd0c20/pip-19.0.2-py2.py3-none-any.whl",
        sha256 = "6a59f1083a63851aeef60c7d68b119b46af11d9d803ddc1cf927b58edcd0b312",
    )

    _remote_wheel(
        name = "setuptools",
        url = "https://files.pythonhosted.org/packages/d1/6a/4b2fcefd2ea0868810e92d519dacac1ddc64a2e53ba9e3422c3b62b378a6/setuptools-40.8.0-py2.py3-none-any.whl",
        sha256 = "e8496c0079f3ac30052ffe69b679bd876c5265686127a3159cfa415669b7f9ab",
    )

    _remote_wheel(
        name = "wheel",
        url = "https://files.pythonhosted.org/packages/7c/d7/20bd3c501f53fdb0b7387e75c03bd1fce748a1c3dd342fc53744e28e3de1/wheel-0.33.0-py2.py3-none-any.whl",
        sha256 = "b79ffea026bc0dbd940868347ae9eee36789b6496b6623bd2dec7c7c540a8f99",
    )

    _remote_wheel(
        name = "pip_tools",
        url = "https://files.pythonhosted.org/packages/96/43/34412d316bdbf1cd9c9a0e487138b40db4e1e11212cee2d46440b6b49b08/pip_tools-3.7.0-py2.py3-none-any.whl",
        sha256 = "4ff38ab655bec47db2d5a82fa6c6807e231ecddf3b7cbb2f2b957a9b11f016c3",
    )

    _remote_wheel(
        name = "click",
        url = "https://files.pythonhosted.org/packages/fa/37/45185cb5abbc30d7257104c434fe0b07e5a195a6847506c074527aa599ec/Click-7.0-py2.py3-none-any.whl",
        sha256 = "2335065e6395b9e67ca716de5f7526736bfa6ceead690adf616d925bdc622b13",
    )

    _remote_wheel(
        name = "six",
        url = "https://files.pythonhosted.org/packages/73/fb/00a976f728d0d1fecfe898238ce23f502a721c0ac0ecfedb80e0d88c64e9/six-1.12.0-py2.py3-none-any.whl",
        sha256 = "3350809f0555b11f552448330d0b52d5f24c91a322ea4a15ef22629740f3761c",
    )

    _ensure_rule_exists(
        http_archive,
        name = "bazel_skylib",
        urls = ["https://github.com/bazelbuild/bazel-skylib/archive/3721d32c14d3639ff94320c780a60a6e658fb033.tar.gz"],
        strip_prefix = "bazel-skylib-3721d32c14d3639ff94320c780a60a6e658fb033",
        sha256 = "6b6ef4f707252c55b6109f02f4322f5219c7467b56bff8587876681ad067e57b",
    )

    _ensure_rule_exists(
        http_archive,
        name = "subpar",
        urls = ["https://github.com/google/subpar/archive/a25a2f2f9a0a491346df78e933e777d2af76ac27.tar.gz"],
        strip_prefix = "subpar-a25a2f2f9a0a491346df78e933e777d2af76ac27",
        sha256 = "31cb6a17fdcfc747d7ee1748b3e4e067b49112b3466c402561fd29ca2e03e9f7",
    )

def _remote_wheel(name, url, sha256):
    _ensure_rule_exists(
        http_archive,
        name = "pip_%s" % name,
        url = url,
        sha256 = sha256,
        build_file_content = _WHEEL_BUILD_FILE_CONTENT,
        type = "zip",
    )

def _ensure_rule_exists(rule_type, name, **kwargs):
    if name not in native.existing_rules():
        rule_type(name = name, **kwargs)
