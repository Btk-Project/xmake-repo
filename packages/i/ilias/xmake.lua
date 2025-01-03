package("ilias")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/BusyStudent/Ilias")
    set_description("ilias, header-only network library based on cpp20 coroutine")

    add_urls("https://github.com/BusyStudent/Ilias/archive/refs/tags/v$(version).tar.gz")
    add_versions("0.1.0", "9f5cc13a6ef7037a4eac02d90ed1ffcbd9af02dabf5b84a4eda8da8ec14479fa")
    add_versions("0.2.0", "7e0fa09e012d8405253131321386f43fb5d4c49f0080de0cd7d68d16d162b0c3")

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