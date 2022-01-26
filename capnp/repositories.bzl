load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//capnp/internal:capnp_lang_toolchain_gen.bzl", "capnp_lang_toolchain_gen")
load("//capnp/internal:capnp_toolchain_gen.bzl", "capnp_toolchain_gen")
load(
    "//capnp/toolchain_defs:cc_defs.bzl",
    "CC_LANG_PLUGIN",
    "CC_LANG_REPO",
    "CC_LANG_RUNTIME",
    "CC_LANG_SHORTNAME",
)
load(
    "//capnp/toolchain_defs:rust_defs.bzl",
    "RUST_LANG_PLUGIN",
    "RUST_LANG_REPO",
    "RUST_LANG_RUNTIME",
    "RUST_LANG_SHORTNAME",
)
load(
    "//capnp/toolchain_defs:ts_defs.bzl",
    "TS_LANG_PLUGIN",
    "TS_LANG_PLUGIN_DEPS",
    "TS_LANG_REPO",
    "TS_LANG_SHORTNAME",
)
load(
    "//capnp/toolchain_defs:toolchain_defs.bzl",
    "CAPNP_TOOLCHAIN_DEFAULT_CAPNP_TOOL",
    "CAPNP_TOOLCHAIN_REPO",
)

def capnp_dependencies():
    maybe(
        http_archive,
        name = "capnproto",
        build_file = "@rules_capnproto//third_party/capnproto:BUILD.capnp.bazel",
        sha256 = "a156efe56b42957ea2d118340d96509af2e40c7ef8f3f8c136df48001a5eb2ac",
        strip_prefix = "capnproto-0.9.0",
        urls = [
            # TODO(kgreenek): Mirror this somewhere in case github is down.
            # Ideally mirror.bazel.build (ping @philwo on github).
            "https://github.com/capnproto/capnproto/archive/refs/tags/v0.9.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "zlib",
        build_file = "@rules_capnproto//third_party:BUILD.zlib.bazel",
        sha256 = "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff",
        strip_prefix = "zlib-1.2.11",
        urls = [
            # TODO(kgreenek): Mirror this somewhere in case github is down.
            # Ideally mirror.bazel.build (ping @philwo on github).
            "https://github.com/madler/zlib/archive/v1.2.11.tar.gz",
        ],
    )

    # Rust

    maybe(
        http_archive,
        name = "rules_rust",
        sha256 = "257d08303b2814ff29f11d1d4f2ed9dff39d5fa9f7362dc802faa090875ea5d9",
        strip_prefix = "rules_rust-fd436df9e2d4ac1b234ca5e969e34a4cb5891910",
        # Master branch as of 2022-01-18
        url = "https://github.com/bazelbuild/rules_rust/archive/fd436df9e2d4ac1b234ca5e969e34a4cb5891910.tar.gz",
    )

    maybe(
        http_archive,
        name = "raze__capnp__0_14_5",
        url = "https://crates.io/api/v1/crates/capnp/0.14.5/download",
        type = "tar.gz",
        sha256 = "16c262726f68118392269a3f7a5546baf51dcfe5cb3c3f0957b502106bf1a065",
        strip_prefix = "capnp-0.14.5",
        build_file = Label("//third_party/capnproto/cargo:BUILD.capnp-0.14.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__capnpc__0_14_5",
        url = "https://crates.io/api/v1/crates/capnpc/0.14.5/download",
        type = "tar.gz",
        sha256 = "682f2a7a680ac01d07fcc5e201cf23e5de65f528dfad7305e4a0a5312d35952f",
        strip_prefix = "capnpc-0.14.5",
        build_file = Label("//third_party/capnproto/cargo:BUILD.capnpc-0.14.5.bazel"),
    )

def capnp_toolchain(capnp_tool = CAPNP_TOOLCHAIN_DEFAULT_CAPNP_TOOL):
    capnp_toolchain_gen(
        name = CAPNP_TOOLCHAIN_REPO,
        capnp_tool = capnp_tool,
    )

def capnp_cc_toolchain(plugin = CC_LANG_PLUGIN, runtime = CC_LANG_RUNTIME):
    capnp_lang_toolchain_gen(
        name = CC_LANG_REPO,
        lang_shortname = CC_LANG_SHORTNAME,
        plugin = CC_LANG_PLUGIN,
        runtime = CC_LANG_RUNTIME,
    )

def capnp_rust_toolchain(plugin = RUST_LANG_PLUGIN, runtime = RUST_LANG_RUNTIME):
    capnp_lang_toolchain_gen(
        name = RUST_LANG_REPO,
        lang_shortname = RUST_LANG_SHORTNAME,
        plugin = RUST_LANG_PLUGIN,
        runtime = RUST_LANG_RUNTIME,
    )

def capnp_ts_toolchain(plugin = TS_LANG_PLUGIN): 
    capnp_lang_toolchain_gen(
        name = TS_LANG_REPO,
        lang_shortname = TS_LANG_SHORTNAME,
        plugin = TS_LANG_PLUGIN,
        plugin_deps = TS_LANG_PLUGIN_DEPS,
    )
