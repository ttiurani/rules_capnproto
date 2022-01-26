def _capnp_lang_toolchain_gen_impl(ctx):
    runtime_str = "" if not ctx.attr.runtime else "runtime = \"" + str(ctx.attr.runtime) + "\","
    plugin_deps_str = "" if not ctx.attr.plugin_deps else "plugin_deps = " + str(ctx.attr.plugin_deps) + ","
    ctx.template(
        "toolchain/BUILD.bazel",
        ctx.attr._build_tpl,
        substitutions = {
            "{lang_shortname}": ctx.attr.lang_shortname,
            "{plugin}": ctx.attr.plugin,
            "{plugin_deps}": plugin_deps_str,
            "{runtime}": runtime_str,
        },
    )

capnp_lang_toolchain_gen = repository_rule(
    implementation = _capnp_lang_toolchain_gen_impl,
    attrs = {
        "lang_shortname": attr.string(),
        "plugin": attr.string(),
        "plugin_deps": attr.string_list(),
        "runtime": attr.string(),
        "_build_tpl": attr.label(
            default = "@rules_capnproto//capnp/internal:BUILD.lang_toolchain.tpl",
        ),
    },
    doc = "Creates the Capnp toolchain that will be used by all capnp_[lang]_library targets",
)
