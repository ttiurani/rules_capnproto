load(
    "@rules_capnproto//capnp/internal:capnp_lang_toolchain.bzl",
    "capnp_lang_toolchain",
)

capnp_lang_toolchain(
    name = "toolchain",
    lang_shortname = "{lang_shortname}",
    plugin = "{plugin}",
    {plugin_deps}
    {runtime}
    visibility = ["//visibility:public"],
)
