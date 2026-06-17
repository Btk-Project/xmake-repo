package("neko-proto-tools")
    set_description("neko-proto-tools, cpp library like protobuf, but simpler and more lightweight")

    -- 建议 alias 语义这样写
    add_urls("https://github.com/liuli-neko/NekoProtoTools.git", {alias = "git"})
    add_urls("https://github.com/liuli-neko/NekoProtoTools/archive/refs/tags/v$(version).tar.gz", {alias = "github"})

    -- tarball 对应 sha256
    add_versions("github:0.2.5", "fa48c165864f80ca7aa8b98c19713a24b5b08e894890b01b07073ff7f2f50643")

    -- git 对应 commit
    add_versions("git:0.2.5", "2f21adc8edfc3ed51e6cccdb9625a85c1d2347a9")

    -- 测试版本
    add_versions("git:0.3.0", "bea18bb8a5bbe2936170a62e3bae1acc98e6e73c")

    -- dev 视为 >= 所有版本号
    add_versions("git:dev", "main")

    local configsOption = {
        enable_simdjson      = {description = "Enable simdjson support.",                            type = "boolean", default = true,  deps = {"simdjson"}},
        enable_rapidjson     = {description = "Enable rapidjson for json serializer support.",       type = "boolean", default = false, deps = {"rapidjson"}},
        enable_communication = {description = "Enable communication module.",                        type = "boolean", default = true,  deps = {"ilias"}},
        enable_fmt           = {description = "Enable fmt support for logging.",                     type = "boolean", default = false, deps = {"fmt"}},
        enable_spdlog        = {description = "Enable spdlog support for logging.",                  type = "boolean", default = false, deps = {"spdlog"}},

        -- <= 0.2.5 有效；0.2.6+ / dev 无效
        enable_rapidxml      = {description = "Enable rapidxml support for xml serializer support.", type = "boolean", default = true,  deps = {"rapidxml"}, maxver = "0.2.5"},

        -- >= 0.3.0 有效；dev 也有效
        enable_pugixml       = {description = "Enable pugixml support for xml serializer support.",  type = "boolean", default = false, deps = {"pugixml"},  minver = "0.3.0"},

        enable_jsonrpc       = {description = "Enable jsonrpc module.",                              type = "boolean", default = true,  deps = {"ilias"}},
        enable_protocol      = {description = "Enable protocol support.",                            type = "boolean", default = true,  deps = {}}
    }

    local function is_devver(package)
        local ver = package:version_str()
        return ver == nil or ver == "" or ver == "dev" or ver == "main" or ver == "master"
    end

    local function version_ge(package, ver)
        if is_devver(package) then
            return true
        end
        return package:version():ge(ver)
    end

    local function version_le(package, ver)
        if is_devver(package) then
            return false
        end
        return package:version():le(ver)
    end

    local function config_available(package, name, info)
        if info.minver and not version_ge(package, info.minver) then
            return false, "requires version >= " .. info.minver
        end

        if info.maxver and not version_le(package, info.maxver) then
            return false, "was removed after " .. info.maxver
        end

        return true
    end

    local function config_value(package, name, info, opt)
        opt = opt or {}

        local raw = package:config(name)
        local available, reason = config_available(package, name, info)

        if not available then
            -- 对带 minver/maxver 的选项，我们不在 add_configs 里设置 default。
            -- 因此 raw ~= nil 通常表示用户显式传入了这个配置。
            if opt.warn and raw ~= nil then
                wprint("package(neko-proto-tools): config." .. name ..
                       " is ignored, because it " .. reason ..
                       " in version " .. tostring(package:version_str()))
            end
            return nil, false
        end

        if raw == nil then
            return info.default, true
        end
        return raw, true
    end

    for name, info in pairs(configsOption) do
        local conf = {
            description = info.description,
            type = info.type
        }

        -- 有版本生命周期的配置不要直接设置 default。
        -- 否则该配置在无效版本里也会得到默认值，难以判断用户是否显式传入。
        if not info.minver and not info.maxver then
            conf.default = info.default
        end

        add_configs(name, conf)
    end

    on_load(function (package)
        local added_deps = {}

        for name, info in pairs(configsOption) do
            local enabled = config_value(package, name, info, {warn = true})
            if enabled then
                for _, dep in ipairs(info.deps or {}) do
                    if not added_deps[dep] then
                        package:add("deps", dep)
                        added_deps[dep] = true
                    end
                end
            end
        end
    end)

    on_install(function (package)
        local configs = {}

        -- 如果上游 xmake.lua 支持 kind 配置，传这种形式更稳
        table.insert(configs, "--kind=" .. (package:config("shared") and "shared" or "static"))

        for name, info in pairs(configsOption) do
            local value, available = config_value(package, name, info)
            if available then
                table.insert(configs, "--" .. name .. "=" .. tostring(value and true or false))
            end
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cxxincludes("neko_proto_tools/xxx.hpp"))
    end)