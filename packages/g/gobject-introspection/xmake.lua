package("gobject-introspection")

    set_homepage("https://gi.readthedocs.io/en/latest/")
    set_description("GObject introspection is a middleware layer between C libraries (using GObject) and language bindings.")
    set_license("LGPL-2.0")

    add_urls("https://download.gnome.org/sources/gobject-introspection/$(version).tar.xz", {version = function (version)
        return format("%d.%d/gobject-introspection-%s", version:major(), version:minor(), version)
    end})
    add_versions("1.70.0", "902b4906e3102d17aa2fcb6dad1c19971c70f2a82a159ddc4a94df73a3cafc4a")
    add_versions("1.80.1", "a1df7c424e15bda1ab639c00e9051b9adf5cea1a9e512f8a603b53cd199bc6d8")
    add_versions("1.82.0", "0f5a4c1908424bf26bc41e9361168c363685080fbdb87a196c891c8401ca2f09")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_extsources("apt::libgirepository1.0-dev", "apt::libgirepository-1.0-dev", "pacman::gobject-introspection-runtime")
    end

    add_deps("meson", "ninja", "pkg-config", "python 3.x", "flex", "bison")
    add_deps("glib", {configs = {shared = true}})
    add_includedirs("include/gobject-introspection-1.0")
    on_install("macosx", "linux", function (package)
        import("package.tools.meson").install(package)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("g_irepository_get_default", {includes = "girepository.h"}))
    end)
