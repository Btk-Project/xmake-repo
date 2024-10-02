package("neko-proto")
    set_description("neko-proto, cpp library like protobuf, but simpler and more lightweight")

    add_urls("https://github.com/liuli-neko/NekoProtoTools.git")
    -- add_versions("0.1", "0f490d124753f63f42d28a8fe08f48a59ce56191")
    
    local configsOption = {
        enable_simdjson        = {description = "Enable simdjson support.", default = true, type = "boolean", deps = {"simdjson"}},
        enable_rapidjson       = {description = "Enable rapidjson for json serializer support.", default = false, type = "boolean", deps = {"rapidjson"}},
        enable_communication   = {description = "Enable communication module.", default = true, type = "boolean", deps = {"ilias"}},
        enable_fmt             = {description = "Enable fmt support for logging.", default = false, type = "boolean", deps = {"fmt"}},
        enable_spdlog          = {description = "Enable spdlog support for logging.", default = false, type = "boolean", deps = {"spdlog"}}}

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
