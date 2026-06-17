package("ilias-sql")
    set_description("Ilias SQL library")

    add_urls("https://github.com/Btk-Project/IliasMySql.git", {alias = "git"})
    add_urls("https://github.com/Btk-Project/IliasMySql/archive/refs/tags/v$(version).tar.gz", {alias = "github"})

    add_versions("git:0.1.0", "d1dcf65dfe096aed272bae0ccb9ab9aa3ab248c8")

    add_versions("git:dev", "main")

    local configsOption = {
        stdcxx = {description = "C++ standard version for building.", type = "number", default = 23, values = {20, 23, 26}},
        enable_mysql = {description = "Enable MySQL support, need mariadb-connector-c.", type = "boolean", default = true},
        enable_sqlite = {description = "Enable SQLite support.", type = "string", default = "sqlite", values = {"disable", "sqlite", "sqlcipher"}},
        enable_postgres = {description = "Enable PostgreSQL support, need libpq.", type = "boolean", default = false},
        enable_orm_interface = {description = "Enable ORM interface.", type = "boolean", default = true},
        dynamic_plugin = {description = "Build dynamic plugins using this library.", type = "boolean", default = false}
    }

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
            if package:config(name) then
                add_dep_once(package, added, name)
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--kind=" .. (package:config("shared") and "shared" or "static"))

        for name, info in pairs(configsOption) do
            if package:config(name) then
                table.insert(configs, "--" .. name .. "=" .. tostring(value and true or false))
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