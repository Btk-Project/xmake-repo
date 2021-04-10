package("btk")
    set_homepage("https://btk-project.github.io/")
    set_description("GUI Tookit based on SDL and nanovg")

    add_urls("https://github.com/BusyStudent/Btk.git")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)
    