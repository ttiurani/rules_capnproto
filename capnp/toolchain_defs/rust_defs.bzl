load("//capnp/toolchain_defs:toolchain_defs.bzl", "toolchain_target_for_repo")

RUST_LANG_REPO = "rules_capnproto_rust_toolchain"
RUST_LANG_TOOLCHAIN = toolchain_target_for_repo(RUST_LANG_REPO)
RUST_LANG_SHORTNAME = "rust"
RUST_LANG_PLUGIN = "@capnproto//:capnpc_rust"
RUST_LANG_RUNTIME = "@capnproto//:capnp_rust"
