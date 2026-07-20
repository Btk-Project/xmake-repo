package("ilias-sql")
    set_description("Ilias SQL library")

    add_urls("https://github.com/Btk-Project/IliasMySql.git", {alias = "git"})
    add_urls("https://github.com/Btk-Project/IliasMySql/archive/refs/tags/v$(version).tar.gz", {alias = "github"})

    add_versions("git:0.1.0", "f1ab36d7d5ab2511d542125f3a0e812c58b516eb")

    add_versions("git:dev", "main")

    local configsOption = {
        stdcxx = {description = "C++ standard version for building.",                    type = "number",  default = 23,       values = {20, 23, 26}},
        enable_mysql = {description = "Enable MySQL support, need mariadb-connector-c.", type = "boolean", default = false,     deps = {"mariadb-connector-c"}},
        enable_sqlite = {description = "Enable SQLite support.",                         type = "string",  default = "sqlite", values = {"disable", "sqlite", "sqlcipher"}, deps = {"", "sqlite3", "sqlcipher"}},
        enable_postgres = {description = "Enable PostgreSQL support, need libpq.",       type = "boolean", default = false,    deps = {"libpq"}},
        enable_orm_interface = {description = "Enable ORM interface.",                   type = "boolean", default = true},
        dynamic_plugin = {description = "Build dynamic plugins using this library.",     type = "boolean", default = false}
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
            if opt.warn and raw ~= nil then
                print("warning: package(neko-proto-tools): config." .. name ..
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
        add_configs(name, {
            description = info.description,
            type = info.type,
            default = info.default,
            values = info.values
        })
    end

    local function add_dep_once(package, added, dep)
        if not added[dep] then
            package:add("deps", dep)
            added[dep] = true
        end
    end

    on_load(function (package)
        local added = {}

        if package:config("dynamic_plugin") and not package:config("shared") then
            print("warning: package(ilias-sql): dynamic_plugin builds shared target in upstream xmake.lua, configs.shared=false may be ignored by upstream")
        end
        for name, info in pairs(configsOption) do
            local value, enabled = config_value(package, name, info, {warn = true})
            if enabled then
                if name == "enable_sqlite" then
                    if not (value == "disable") then 
                        -- 获取values对应下标的deps
                        local idx = nil
                        for i, v in ipairs(info.values) do
                            if v == value then
                                idx = i
                                break
                            end
                        end
                        if idx then
                            add_dep_once(package, added, info.deps[idx])
                        end
                    end
                else
                    for _, dep in ipairs(info.deps or {}) do
                        add_dep_once(package, added, dep)
                    end
                end
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--kind=" .. (package:config("shared") and "shared" or "static"))

        local function config_to_arg(value, info)
            if info.type == "boolean" then
                return tostring(value and true or false)
            end
            return tostring(value)
        end

        for name, info in pairs(configsOption) do
            local value, available = config_value(package, name, info)
            if available then
                table.insert(configs, "--" .. name .. "=" .. config_to_arg(value, info))
            end
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- assert(package:check_cxxsnippets({test = [[
        --     #include <ilias/sql/interfaces.hpp>
        --     void test() {}
        -- ]]}, {configs = {languages = "c++" .. tostring(package:config("stdcxx"))}}))
    end)
