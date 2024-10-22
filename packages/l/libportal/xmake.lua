package("libportal")
    set_homepage("https://libportal.org/")
    set_description("Flatpak portal library")
    set_license("LGPL-3.0-only")

    add_urls("https://github.com/flatpak/libportal/releases/download/$(version)/libportal-$(version).tar.xz", {alias = "github"})

    add_versions("github:0.8.1", "281e54e4f8561125a65d20658f1462ab932b2b1258c376fed2137718441825ac")

    add_configs("docs",  {description = "Build API reference with gi-docgen.", default = false, type = "boolean"})
    add_configs("tests", {description = "Build unit tests.", default = false, type = "boolean"})

    add_deps("meson", "ninja", "gobject-introspection")
    on_load(function (package)
    end)

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Ddocs=" .. (package:config("docs") and "true" or "false"))
        table.insert(configs, "-Dtests=" .. (package:config("tests") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        -- test
    end)