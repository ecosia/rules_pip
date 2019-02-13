def _get_platform(repo_ctx):
    if "mac" in repo_ctx.os.name:
        return "osx"

    return repo_ctx.os.name

def _select_requirements_for_platform(repo_ctx):
    current_platform = _get_platform(repo_ctx)

    for label, intended_platform in repo_ctx.attr.requirements_per_platform.items():
        if intended_platform == current_platform:
            return repo_ctx.path(label)

    fail(
        "None of the given requirements files match the current environment",
        attr = "pip_repository",
    )

def _pip_repository_impl(repo_ctx):
    repo_ctx.file("BUILD", "")

    create_repo_exe_path = repo_ctx.path(repo_ctx.attr._create_repo_exe)
    repo_directory = repo_ctx.path("")

    if repo_ctx.attr.requirements:
        requirements_path = repo_ctx.path(repo_ctx.attr.requirements)
    elif repo_ctx.attr.requirements_per_platform:
        requirements_path = _select_requirements_for_platform(repo_ctx)
    else:
        fail(
            "Either 'requirements' or 'requirements_per_platform' is required",
            attr = "pip_repository",
        )

    wheel_cache = repo_ctx.attr.wheel_cache or repo_ctx.os.environ.get("BAZEL_PIP_CACHE", "")
    # SOURCE_DATE_EPOCH of is needed for reproducible wheel builds
    # A date of at least 01.01.1980 is needed due to the python zip library
    environment = {
        "SOURCE_DATE_EPOCH": "315532800",
    }
    environment.update(repo_ctx.attr.environment)

    r = repo_ctx.execute(
        [
            repo_ctx.attr.python_interpreter,
            create_repo_exe_path,
            repo_ctx.attr.python_interpreter,
            wheel_cache,
            # The build directory is needed for deterministic wheel builds
            repo_ctx.attr.wheel_build_dir,
            repo_directory,
            requirements_path,
        ] + repo_ctx.attr.wheel_args,
        environment = environment,
        quiet = repo_ctx.attr.quiet,
    )

    if r.return_code:
        fail(r.stderr)

pip_repository = repository_rule(
    implementation = _pip_repository_impl,
    attrs = {
        "requirements": attr.label(
            allow_files = True,
        ),
        "requirements_per_platform": attr.label_keyed_string_dict(
            allow_files = True,
            allow_empty = False,
        ),
        "python_interpreter": attr.string(default = "python3"),
        "wheel_build_dir": attr.string(default = "/tmp/pip-build"),
        "wheel_args": attr.string_list(),
        "wheel_cache": attr.string(),
        "environment": attr.string_dict(),
        "quiet": attr.bool(default = True),
        "_create_repo_exe": attr.label(
            default = "//tools:create_pip_repository.par",
            executable = True,
            cfg = "host",
        ),
    },
)
