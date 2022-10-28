package("btk")
    set_description("The btk package")

    add_urls("https://github.com/BusyStudent/Btk-ng.git")
    -- add_versions("0.1", "0f490d124753f63f42d28a8fe08f48a59ce56191")

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
