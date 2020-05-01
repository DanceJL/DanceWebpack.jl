import Dance
import DanceWebpack


include("utils.jl")


Dance.start_project("demo")
cd("demo")
project_settings_and_launch()
add_project_toml()
@test_logs (:info, "Webpack files added to `static` dir in project.\nPlease cd into `static` dir and add dependencies by installing NodeJS and running `npm install`") DanceWebpack.setup()

cd("static")
for line in readlines("package.json")
    for item in [
        ["authors", "[\"Chris \\\"Yoh\\\" Meyers <48554065+yoh-meyers@users.noreply.github.com>\"]"],
        ["name", "Demo_1"],
        ["version", "1.0.1"]
    ]
        if occursin(item[1], line)
            value::String = strip(
                strip(
                    rstrip(split(line, ':')[2], ',')
                ),
                '"'
            )
            @test value==item[2]
        end
    end
end


delete_project()
