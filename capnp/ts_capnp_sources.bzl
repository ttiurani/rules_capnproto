load("@rules_cc//cc:action_names.bzl", "CPP_COMPILE_ACTION_NAME")
load("@rules_cc//cc:toolchain_utils.bzl", "find_cpp_toolchain")
load("//capnp:capnp_info.bzl", "CapnpInfo")
load("//capnp/internal:capnp_lang_toolchain.bzl", "CapnpLangToolchainInfo")
load("//capnp/internal:capnp_toolchain.bzl", "CapnpToolchainInfo")
load("//capnp/internal:capnp_tool_action.bzl", "capnp_tool_action")
load("//capnp/internal:label_utils.bzl", "package_dir")
load("//capnp/toolchain_defs:ts_defs.bzl", "TS_LANG_TOOLCHAIN")
load("//capnp/toolchain_defs:toolchain_defs.bzl", "CAPNP_TOOLCHAIN")

JS_SRC_FILE_EXTENSION = "js"
D_TS_SRC_FILE_EXTENSION = "d.ts"

CapnpTsInfo = provider(fields = {
    "ts_srcs": "Typescript source files for this target (non-transitive)",
})

def _capnp_ts_aspect_impl(target, ctx):
    js_srcs = [
        ctx.actions.declare_file(src.basename + "." + JS_SRC_FILE_EXTENSION, sibling = src)
        for src in target[CapnpInfo].srcs
    ]

    dts_srcs = [
        ctx.actions.declare_file(src.basename + "." + D_TS_SRC_FILE_EXTENSION, sibling = src)
        for src in target[CapnpInfo].srcs
    ]

    ts_srcs = js_srcs + dts_srcs

    # Create an action to generate ts sources from the capnp files.
    capnp_tool_action(
        ctx = ctx,
        target = ctx.label,
        capnp_toolchain = ctx.attr._capnp_toolchain[CapnpToolchainInfo],
        capnp_lang_toolchain = ctx.attr._capnp_lang_toolchain[CapnpLangToolchainInfo],
        srcs = target[CapnpInfo].srcs,
        srcs_transitive = target[CapnpInfo].srcs_transitive,
        includes_transitive = target[CapnpInfo].includes_transitive,
        embed_files_transitive = target[CapnpInfo].embed_files_transitive,
        outputs = ts_srcs,
    )
    
    return [
        CapnpTsInfo(
            ts_srcs = ts_srcs,
        ),
    ]

def _ts_capnp_sources_impl(ctx):
    for dep in ctx.attr.deps:
        return [
          DefaultInfo(files = depset(dep[CapnpTsInfo].ts_srcs))
        ]

capnp_ts_aspect = aspect(
    implementation = _capnp_ts_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_capnp_toolchain": attr.label(
            providers = [CapnpToolchainInfo],
            default = CAPNP_TOOLCHAIN,
        ),
        "_capnp_lang_toolchain": attr.label(
            providers = [CapnpLangToolchainInfo],
            default = TS_LANG_TOOLCHAIN,
        ),
    },
    incompatible_use_toolchain_transition = True,
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)

ts_capnp_sources = rule(
    implementation = _ts_capnp_sources_impl,
    attrs = {
        "deps": attr.label_list(
            aspects = [capnp_ts_aspect],
            providers = [CapnpInfo],
        ),
        "_capnp_toolchain": attr.label(
            providers = [CapnpToolchainInfo],
            default = CAPNP_TOOLCHAIN,
        ),
        "_capnp_lang_toolchain": attr.label(
            providers = [CapnpLangToolchainInfo],
            default = TS_LANG_TOOLCHAIN,
        ),
    },
    incompatible_use_toolchain_transition = True,
)
