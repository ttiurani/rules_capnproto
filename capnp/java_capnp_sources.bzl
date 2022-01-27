load("//capnp:capnp_info.bzl", "CapnpInfo")
load("//capnp/internal:capnp_lang_toolchain.bzl", "CapnpLangToolchainInfo")
load("//capnp/internal:capnp_toolchain.bzl", "CapnpToolchainInfo")
load("//capnp/internal:capnp_tool_action.bzl", "capnp_tool_action")
load("//capnp/toolchain_defs:java_defs.bzl", "JAVA_LANG_TOOLCHAIN")
load("//capnp/toolchain_defs:toolchain_defs.bzl", "CAPNP_TOOLCHAIN")

JAVA_SRC_FILE_EXTENSION = "java"

CapnpJavaInfo = provider(fields = {
    "java_srcs": "java source files for this target (non-transitive)",
})

def _get_java_file_name(capnp_file_basename):
    file_name_parts = capnp_file_basename.replace(".capnp", "").split('_')
    file_name = file_name_parts[0].capitalize()
    for x in file_name_parts[1:]:
        file_name += x.capitalize()
    return file_name + "." + JAVA_SRC_FILE_EXTENSION

def _capnp_java_aspect_impl(target, ctx):
    java_srcs = [
        ctx.actions.declare_file(_get_java_file_name(src.basename), sibling = src)
        for src in target[CapnpInfo].srcs
    ]

    # Create an action to generate java sources from the capnp files.
    capnp_tool_action(
        ctx = ctx,
        target = ctx.label,
        capnp_toolchain = ctx.attr._capnp_toolchain[CapnpToolchainInfo],
        capnp_lang_toolchain = ctx.attr._capnp_lang_toolchain[CapnpLangToolchainInfo],
        srcs = target[CapnpInfo].srcs,
        srcs_transitive = target[CapnpInfo].srcs_transitive,
        includes_transitive = target[CapnpInfo].includes_transitive,
        embed_files_transitive = target[CapnpInfo].embed_files_transitive,
        outputs = java_srcs,
    )
    return [
        CapnpJavaInfo(
            java_srcs = java_srcs,
        ),
    ]

def _java_capnp_sources_impl(ctx):
    for dep in ctx.attr.deps:
        return [
          DefaultInfo(files = depset(dep[CapnpJavaInfo].java_srcs))
        ]

capnp_java_aspect = aspect(
    implementation = _capnp_java_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_capnp_toolchain": attr.label(
            providers = [CapnpToolchainInfo],
            default = CAPNP_TOOLCHAIN,
        ),
        "_capnp_lang_toolchain": attr.label(
            providers = [CapnpLangToolchainInfo],
            default = JAVA_LANG_TOOLCHAIN,
        ),
    },
    incompatible_use_toolchain_transition = True,
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)

java_capnp_sources = rule(
    implementation = _java_capnp_sources_impl,
    attrs = {
        "deps": attr.label_list(
            aspects = [capnp_java_aspect],
            providers = [CapnpInfo],
        ),
        "_capnp_toolchain": attr.label(
            providers = [CapnpToolchainInfo],
            default = CAPNP_TOOLCHAIN,
        ),
        "_capnp_lang_toolchain": attr.label(
            providers = [CapnpLangToolchainInfo],
            default = JAVA_LANG_TOOLCHAIN,
        ),
    },
    incompatible_use_toolchain_transition = True,
)
