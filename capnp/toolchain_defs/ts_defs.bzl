load("//capnp/toolchain_defs:toolchain_defs.bzl", "toolchain_target_for_repo")

TS_LANG_REPO = "rules_capnproto_ts_toolchain"
TS_LANG_TOOLCHAIN = toolchain_target_for_repo(TS_LANG_REPO)
TS_LANG_SHORTNAME = "ts"
TS_LANG_PLUGIN = "@capnproto//:capnpc_ts"
TS_LANG_PLUGIN_DEPS = ["@npm//:node_modules" , "@nodejs_toolchains//:resolved_toolchain"]
