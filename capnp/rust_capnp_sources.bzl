load("//capnp:capnp_info.bzl", "CapnpInfo")
load("//capnp/internal:capnp_lang_toolchain.bzl", "CapnpLangToolchainInfo")
load("//capnp/internal:capnp_toolchain.bzl", "CapnpToolchainInfo")
load("//capnp/internal:capnp_tool_action.bzl", "capnp_tool_action")
load("//capnp/toolchain_defs:rust_defs.bzl", "RUST_LANG_TOOLCHAIN")
load("//capnp/toolchain_defs:toolchain_defs.bzl", "CAPNP_TOOLCHAIN")

RUST_SRC_FILE_EXTENSION = "rs"

CapnpRustInfo = provider(fields = {
    "rust_srcs": "rust source files for this target (non-transitive)",
})

def _get_rust_file_name_base(capnp_file):
    return capnp_file.basename.replace(".capnp", "_capnp")

def _capnp_rust_aspect_impl(target, ctx):
    rust_srcs = [
        ctx.actions.declare_file(_get_rust_file_name_base(src) + "." + RUST_SRC_FILE_EXTENSION, sibling = src)
        for src in target[CapnpInfo].srcs
    ]

    # Create an action to generate rust sources from the capnp files.
    capnp_tool_action(
        ctx = ctx,
        target = ctx.label,
        capnp_toolchain = ctx.attr._capnp_toolchain[CapnpToolchainInfo],
        capnp_lang_toolchain = ctx.attr._capnp_lang_toolchain[CapnpLangToolchainInfo],
        srcs = target[CapnpInfo].srcs,
        srcs_transitive = target[CapnpInfo].srcs_transitive,
        includes_transitive = target[CapnpInfo].includes_transitive,
        embed_files_transitive = target[CapnpInfo].embed_files_transitive,
        outputs = rust_srcs,
    )
    
    # # Also write lib.rs as the sibling of the first srcs
    rust_srcs.append(ctx.actions.declare_file("lib.rs", sibling = target[CapnpInfo].srcs[0]))
    content = "pub use capnp;\n"
    for src in target[CapnpInfo].srcs:
        content += "pub mod " + _get_rust_file_name_base(src) + ";\n"
    ctx.actions.write(
        output = rust_srcs[-1],
        content = content,
        is_executable = False,
    )

    return [
        CapnpRustInfo(
            rust_srcs = rust_srcs,
        ),
    ]

def _rust_capnp_sources_impl(ctx):
    for dep in ctx.attr.deps:
        return [
          DefaultInfo(files = depset(dep[CapnpRustInfo].rust_srcs))
        ]

capnp_rust_aspect = aspect(
    implementation = _capnp_rust_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_capnp_toolchain": attr.label(
            providers = [CapnpToolchainInfo],
            default = CAPNP_TOOLCHAIN,
        ),
        "_capnp_lang_toolchain": attr.label(
            providers = [CapnpLangToolchainInfo],
            default = RUST_LANG_TOOLCHAIN,
        ),
    },
    incompatible_use_toolchain_transition = True,
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)

rust_capnp_sources = rule(
    implementation = _rust_capnp_sources_impl,
    attrs = {
        "deps": attr.label_list(
            aspects = [capnp_rust_aspect],
            providers = [CapnpInfo],
        ),
        "_capnp_toolchain": attr.label(
            providers = [CapnpToolchainInfo],
            default = CAPNP_TOOLCHAIN,
        ),
        "_capnp_lang_toolchain": attr.label(
            providers = [CapnpLangToolchainInfo],
            default = RUST_LANG_TOOLCHAIN,
        ),
    },
    incompatible_use_toolchain_transition = True,
)
