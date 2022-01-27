load("//capnp/toolchain_defs:toolchain_defs.bzl", "toolchain_target_for_repo")

JAVA_LANG_REPO = "rules_capnproto_java_toolchain"
JAVA_LANG_TOOLCHAIN = toolchain_target_for_repo(JAVA_LANG_REPO)
JAVA_LANG_SHORTNAME = "java"
JAVA_LANG_PLUGIN = "@capnproto_java//:capnpc_java"
