package("ilias")
    set_homepage("https://github.com/BusyStudent/Ilias")
    set_description("ilias, network library based on cpp20 coroutine")
    set_license("MIT")

    add_urls("https://github.com/BusyStudent/Ilias.git", {alias = "git"})
    add_urls("https://github.com/BusyStudent/Ilias/archive/refs/tags/v$(version).tar.gz", {alias = "github"})

    -- The release versions
    add_versions("github:0.1.0", "9f5cc13a6ef7037a4eac02d90ed1ffcbd9af02dabf5b84a4eda8da8ec14479fa")
    add_versions("github:0.2.0", "7e0fa09e012d8405253131321386f43fb5d4c49f0080de0cd7d68d16d162b0c3")
    add_versions("github:0.2.1", "dcc822434b1028e468e067645e5f38dc4966faa8454a6925f74fbe2bba94d809")
    add_versions("github:0.2.2", "91f9f8eb44238dab3186157772d375c2e3b77f1742c149848f511b92e64d5ad2")
    add_versions("github:0.2.3", "4746a9b929fa2c3554b3e52108c7ebf6bba45eb50e70bec7192ad34497046528")
    add_versions("github:0.3.0", "8b1c6cde8b280d3d17bea358a513938e9c4fbdab8c0baeee0a6fb49820151797")
    add_versions("github:0.3.1", "26b82cd80e4c307fc5d2860e2309ed72c2c940050be8b1e17cee54a7d081a6c3")
    add_versions("github:0.3.2", "7e97bdcd4dd649ee004caea62cf0c70fbf2972c2f3208d3b75efea5e4ef74e7c")
    add_versions("github:0.3.3", "a8bd24d026e299ff94ef0bf5d18ce45eb54313e0a6041043747d9666d0e34880")
    add_versions("github:0.3.4", "d79ae1dc92af43e879543d6b1f1c22957bd3e9663b2257544d98817003266a3f")

    -- The dev versions
    add_versions("git:dev", "main")

    -- The system deps
    local tls_deps = {}
    if is_host("windows") and not is_plat("cross") then
        add_syslinks("Ws2_32")
    else
        -- In windows, use schannel, no-deps, other platform, use openssl3
        tls_deps = {"openssl3"}
    end

    -- The configure
    local configsOption = {
        fmt             = {description = "Use fmt replace std::format", default = false, type = "boolean", deps = {"fmt"}},
        log             = {description = "Enable bultin debug log", default = false, type = "boolean", deps = {}},
        tls             = {description = "Enable Tls support", default = true, type = "boolean", deps = tls_deps},
        spdlog          = {description = "Use spdlog to log", default = false, type = "boolean", deps = {"spdlog"}},
        fiber           = {description = "Enable stackful coroutine support", default = true, type = "boolean", deps = {}},
        io_uring        = {description = "Use io_uring as platform context", default = false, type = "boolean", deps = {"io_uring"}},
        openssl         = {description = "Force to use openssl as tls backend", default = false, type = "boolean", deps = {"openssl3"}},
        cpp20           = {description = "Enable polyfills for std::expected in cpp20", default = false, type = "boolean", deps = {"zeus_expected"}},
        coro_trace      = {description = "Enable Coroutine async stacktrace", default = false, type = "boolean", deps = {}}
    }
    add_configs("shared", {description = "always use shared library", default = true, type = "boolean", readonly = true})

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