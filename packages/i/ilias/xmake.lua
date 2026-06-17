package("ilias")
    set_homepage("https://github.com/BusyStudent/Ilias")
    set_description("ilias, Modern lightweight async runtime based on cpp20 coroutine")
    set_license("MIT")

    add_urls("https://github.com/BusyStudent/Ilias.git", {alias = "git"})
    add_urls("https://github.com/BusyStudent/Ilias/archive/refs/tags/v$(version).tar.gz", {alias = "github"})

    -- The release versions
    add_versions("github:0.4.0", "5b85614445e8ea8ee10d6909afa8a5e01d525a152a38066fce402b7ab755df03")
    add_versions("github:0.4.1", "3e205beb08fe69117d554852d8ba5c23c0feb79b19bff991ed89c385bd8b9ea4")
    add_versions("github:0.4.2", "beb784a17e8de95b72e418d308dffd9c424c0efdaf0046253135cca64665be7e")

    -- The dev versions
    add_versions("git:dev", "main")

    -- The system deps
    local tls_deps = {}
    if is_plat("windows", "mingw") then
        add_syslinks("Ws2_32")
    else
        -- In windows, use schannel, no-deps, other platform, use openssl3
        tls_deps = {"openssl3"}
    end

    -- The configure
    local configsOption = {
        fmt        = {description = "Use fmt replace std::format",         type = "boolean", default = false, deps = {"fmt"}      },
        log        = {description = "Enable builtin debug log",            type = "boolean", default = false, deps = {}           },
        tls        = {description = "Enable Tls support",                  type = "boolean", default = true,  deps = tls_deps     },
        spdlog     = {description = "Use spdlog to log",                   type = "boolean", default = false, deps = {"spdlog"}   },
        fiber      = {description = "Enable stackful coroutine support",   type = "boolean", default = true,  deps = {}           },
        io_uring   = {description = "Use io_uring as platform context",    type = "boolean", default = false, deps = {"io_uring"} },
        openssl    = {description = "Force to use openssl as tls backend", type = "boolean", default = false, deps = {"openssl3"} },
        coro_trace = {description = "Enable Coroutine async stacktrace",   type = "boolean", default = false, deps = {}           },
        stdcxx     = {description = "C++ standard version for building",   type = "number",  default = 23,    deps = {}           }
    }
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    for k, info in pairs(configsOption) do
        add_configs(k, {description = info.description, default = info.default, type = info.type})
    end

    on_load(function (package)
        for name, info in pairs(configsOption) do
            local val = package:config(name)

            if name == "stdcxx" then
                if tonumber(val) < 23 then
                    package:add("deps", "zeus_expected")
                end
            elseif val then
                for _, dep in ipairs(info.deps) do
                    package:add("deps", dep)
                end
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        for k, v in pairs(configsOption) do
            local val = package:config(k)
            table.insert(configs, "--" .. k .. "=" .. tostring(val))
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)