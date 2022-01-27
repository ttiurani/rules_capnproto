load("//capnp/toolchain_defs:toolchain_defs.bzl", "toolchain_target_for_repo")

RUST_LANG_REPO = "rules_capnproto_rust_toolchain"
RUST_LANG_TOOLCHAIN = toolchain_target_for_repo(RUST_LANG_REPO)
RUST_LANG_SHORTNAME = "rust"
RUST_LANG_PLUGIN = "@rules_capnproto//third_party/capnproto/cargo:capnpc_rust"
RUST_LANG_RUNTIME = "@rules_capnproto//third_party/capnproto/cargo:capnp_rust"
