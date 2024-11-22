package("ilias")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/BusyStudent/Ilias")
    set_description("ilias, header-only network library based on cpp20 coroutine")

    add_urls("https://github.com/BusyStudent/Ilias/archive/refs/tags/v$(version).tar.gz")
    add_versions("0.1.0", "9f5cc13a6ef7037a4eac02d90ed1ffcbd9af02dabf5b84a4eda8da8ec14479fa")

    if is_host("windows") and not is_plat("cross") then
        add_syslinks("Ws2_32")
    end

    on_install(function (package)
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)