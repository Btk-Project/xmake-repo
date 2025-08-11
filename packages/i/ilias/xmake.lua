package("ilias")
    set_homepage("https://github.com/BusyStudent/Ilias")
    set_description("ilias, header-only network library based on cpp20 coroutine")

    add_urls("https://github.com/BusyStudent/Ilias.git", {alias = "git"})
    add_urls("https://github.com/BusyStudent/Ilias/archive/refs/tags/v$(version).tar.gz", {alias = "github"})

    -- The release versions
    add_versions("github:0.1.0", "9f5cc13a6ef7037a4eac02d90ed1ffcbd9af02dabf5b84a4eda8da8ec14479fa")
    add_versions("github:0.2.0", "7e0fa09e012d8405253131321386f43fb5d4c49f0080de0cd7d68d16d162b0c3")
    add_versions("github:0.2.1", "dcc822434b1028e468e067645e5f38dc4966faa8454a6925f74fbe2bba94d809")
    add_versions("github:0.2.2", "91f9f8eb44238dab3186157772d375c2e3b77f1742c149848f511b92e64d5ad2")
    add_versions("github:0.2.3", "4746a9b929fa2c3554b3e52108c7ebf6bba45eb50e70bec7192ad34497046528")

    -- The dev versions
    add_versions("git:dev", "main")

    -- The system deps
    if is_host("windows") and not is_plat("cross") then
        add_syslinks("Ws2_32")
    end

    -- The configure
    local configsOption = {
        fmt             = {description = "Use fmt replace std::format", default = false, type = "boolean", deps = {"fmt"}},
        log             = {description = "Enable bultin debug log", default = false, type = "boolean", deps = {}},
        spdlog          = {description = "Use spdlog to log", default = false, type = "boolean", deps = {"spdlog"}},
        fiber           = {description = "Enable stackful coroutine support", default = false, type = "boolean", deps = {}},
        io_uring        = {description = "Use io_uring as platform context", default = false, type = "boolean", deps = {"io_uring"}}
        cpp20           = {description = "Enable polyfills for std::expected in cpp20", default = false, type = "boolean", deps = {"zeus_expected"}}
    }

    for k, info in pairs(configsOption) do
        add_configs(k, {description = info.description, default = info.default, type = info.type})
    end

    on_load(function (package)
        for k, v in pairs(configsOption) do
            if package:config(k) then
                package:add("deps", v.deps)
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        for k, v in pairs(configsOption) do
            table.insert(configs, "--" .. k .. "=" .. (package:config(k) and "true" or "false"))
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)