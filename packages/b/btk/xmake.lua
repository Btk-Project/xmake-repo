package("btk")
    set_description("The btk package")

    add_urls("https://github.com/BusyStudent/Btk-ng.git")
    -- add_versions("0.1", "0f490d124753f63f42d28a8fe08f48a59ce56191")

    if is_host("windows") and not is_plat("cross") then
        add_syslinks("user32", "shlwapi", "shell32", "imm32", "gdi32", "ole32")
        add_syslinks("windowscodecs", "d2d1", "dwrite", "uuid", "dxguid")
    end

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)
