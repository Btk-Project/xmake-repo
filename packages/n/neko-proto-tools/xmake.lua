package("neko-proto-tools")
    set_description("neko-proto-tools, cpp library like protobuf, but simpler and more lightweight")

    add_urls("https://github.com/liuli-neko/NekoProtoTools.git", {alias = "github"})
    add_urls("https://github.com/liuli-neko/NekoProtoTools/archive/refs/tags/v$(version).tar.gz", {alias = "git"})
    
    -- add_versions("git:0.2.1", "f104cbbaf3cb91411a7b8dfa732cae465a92e58f1cc048ae1892b99f6499046a")
    -- add_versions("github:0.2.1", "072e07a9a74f2067b5c1251ce2f02ffc931df79f")

    -- add_versions("git:0.2.2", "538a99a9cc95a10343b5d731b6d92362645115c42a047a1d8918c7bbca3b5a01")
    -- add_versions("github:0.2.2", "5c368a7b72deeba4a6ae8aab07e272b79f053640")

    -- The dev versions
    add_versions("github:dev", "main")
    
    local configsOption = {
        enable_simdjson        = {description = "Enable simdjson support.", default = true, type = "boolean", deps = {"simdjson"}},
        enable_rapidjson       = {description = "Enable rapidjson for json serializer support.", default = false, type = "boolean", deps = {"rapidjson"}},
        enable_communication   = {description = "Enable communication module.", default = true, type = "boolean", deps = {"ilias"}},
        enable_fmt             = {description = "Enable fmt support for logging.", default = false, type = "boolean", deps = {"fmt"}},
        enable_spdlog          = {description = "Enable spdlog support for logging.", default = false, type = "boolean", deps = {"spdlog"}},
        enable_rapidxml        = {description = "Enable rapidxml support for xml serializer support.", default = true, type = "boolean", deps = {"rapidxml"}},
        enable_jsonrpc         = {description = "Enable jsonrpc module.", default = true, type = "boolean", deps = {"ilias"}, version = "0.2.3"}
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
        if package:config("shared") then
            configs.kind = "shared"
        end
        for k, v in pairs(configsOption) do
            table.insert(configs, "--" .. k .. "=" .. (package:config(k) and "true" or "false"))
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)
