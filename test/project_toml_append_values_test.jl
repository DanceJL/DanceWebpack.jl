import DanceWebpack
import Pkg

include("utils.jl")

# TODO: remove
Pkg.add(Pkg.PackageSpec(url="https://github.com/DanceJL/Dance.jl"))
import Dance


Dance.start_project("demo")
cd("demo")
add_project_toml()
@test_logs (:info, "Webpack files added to `static` dir in project.\nPlease cd into `static` dir and add dependencies by installing NodeJS and running `npm install`") DanceWebpack.setup()

for line in readlines("Project.toml")
    for item in [
        ["authors", "[\"Chris \\\"Yoh\\\" Meyers <48554065+yoh-meyers@users.noreply.github.com>\"]"],
        ["name", "Demo"],
        ["version", "1.0.1"]
    ]
        if occursin(item[1], line)
            value::String = strip(strip(split(line, '=')[2]), '"')
            @test value==item[2]
        end
    end
end

delete_project()
