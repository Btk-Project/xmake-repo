package("neko-proto-tools")
    set_description("neko-proto-tools, cpp library like protobuf, but simpler and more lightweight")

    -- 建议 alias 语义换回来：git 仓库叫 git，tarball 叫 github
    add_urls("https://github.com/liuli-neko/NekoProtoTools.git", {alias = "git"})
    add_urls("https://github.com/liuli-neko/NekoProtoTools/archive/refs/tags/v$(version).tar.gz", {alias = "github"})

    -- github:xxx 对应 tarball sha256
    -- git:xxx 对应 git commit
    add_versions("github:0.2.5", "fa48c165864f80ca7aa8b98c19713a24b5b08e894890b01b07073ff7f2f50643")
    add_versions("git:0.2.5", "2f21adc8edfc3ed51e6cccdb9625a85c1d2347a9")
    
    -- 测试版本
    add_versions("git:0.3.0", "bea18bb8a5bbe2936170a62e3bae1acc98e6e73c")

    -- dev 是 git 分支
    add_versions("git:dev", "main")

    local configsOption = {
        enable_simdjson      = {description = "Enable simdjson support.",                            type = "boolean", default = true,  deps = {"simdjson"}},
        enable_rapidjson     = {description = "Enable rapidjson for json serializer support.",       type = "boolean", default = false, deps = {"rapidjson"}},
        enable_communication = {description = "Enable communication module.",                        type = "boolean", default = true,  deps = {"ilias"}},
        enable_fmt           = {description = "Enable fmt support for logging.",                     type = "boolean", default = false, deps = {"fmt"}},
        enable_spdlog        = {description = "Enable spdlog support for logging.",                  type = "boolean", default = false, deps = {"spdlog"}},

        -- <= 0.2.5 有效；0.2.6+ / dev 删除
        enable_rapidxml      = {description = "Enable rapidxml support for xml serializer support.", type = "boolean", default = false,  deps = {"rapidxml"}, until = "0.2.5"},

        -- >= 0.3.0 有效；dev 也有效
        enable_pugixml       = {description = "Enable pugixml support for xml serializer support.",  type = "boolean", default = false, deps = {"pugixml"},  since = "0.3.0"},

        enable_jsonrpc       = {description = "Enable jsonrpc module.",                              type = "boolean", default = true,  deps = {"ilias"}},
        enable_protocol      = {description = "Enable protocol support.",                            type = "boolean", default = true,  deps = {}}
    }

    local function _is_devver(package)
        local ver = package:version_str()
        return not ver or ver == "" or ver == "dev" or ver == "main" or ver == "master"
    end

    local function _version_ge(package, ver)
        if _is_devver(package) then
            return true
        end
        local semver = import("core.base.semver")
        return semver.compare(package:version_str(), ver) >= 0
    end

    local function _version_le(package, ver)
        if _is_devver(package) then
            -- 你的规则：dev >= 所有版本号，所以 dev 不满足 <= 任意 release
            return false
        end
        local semver = import("core.base.semver")
        return semver.compare(package:version_str(), ver) <= 0
    end

    local function _config_available(package, name, info)
        if info.since and not _version_ge(package, info.since) then
            return false, ("requires version >= %s"):format(info.since)
        end
        if info.until and not _version_le(package, info.until) then
            return false, ("was removed after %s"):format(info.until)
        end
        return true
    end

    local function _config_value(package, name, info, opt)
        opt = opt or {}

        local raw = package:config(name)
        local ok, reason = _config_available(package, name, info)

        if not ok then
            -- 只有带 since/until 的配置才不设置 add_configs 默认值，所以 raw ~= nil 基本可视为用户显式传入
            if opt.warn and raw ~= nil then
                wprint(("package(neko-proto-tools): config.%s is ignored, because it %s in version %s")
                    :format(name, reason, package:version_str() or "dev"))
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

        -- 普通选项可以直接给默认值；
        -- 带版本生命周期的选项不直接给默认值，用 _config_value() 在当前版本下计算默认值。
        if not info.since and not info.until then
            conf.default = info.default
        end

        add_configs(name, conf)
    end

    on_load(function (package)
        local added_deps = {}

        for name, info in pairs(configsOption) do
            local enabled = _config_value(package, name, info, {warn = true})
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

        -- 如果上游 xmake.lua 支持 --kind=shared/static，可以这样传
        table.insert(configs, "--kind=" .. (package:config("shared") and "shared" or "static"))

        for name, info in pairs(configsOption) do
            local value, available = _config_value(package, name, info)
            if available then
                table.insert(configs, "--" .. name .. "=" .. tostring(value and true or false))
            end
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
    end)