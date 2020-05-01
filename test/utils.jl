function add_project_toml() :: Int64
    touch("Project.toml")

    open("Project.toml", "w") do io_project
        open("../sample/Project.toml") do io_sample
            write(io_project, io_sample)
        end
    end
end


function compare_http_header(headers::Array, key::String, value::String) :: Nothing
    for item in headers
        if item[1]==key
            @test item[2]==value
        end
    end
end


function delete_project() :: Nothing
    cd("../..")
    rm("demo", recursive=true)
    Dance.Router.delete_routes!()
    nothing
end


function extract_html_body_content(html_body::Array{UInt8,1}) :: String
    return split(
        split(String(html_body), "<div id=\"js-dance-json-data\">")[2],
        "</div>"
    )[1]
end


function get_webpack_bundle_id() :: String
    bundle_id::String = ""

    for line in eachline(open("../html/base.html", "r"))
        if occursin("<script src=\"/static/main.", line) && occursin(".js", line)
            bundle_id = split(split(line, "<script src=\"/static/main.")[2], ".js\"></script>")[1]
        end
    end

    cd("..")
    return bundle_id
end


function project_settings_and_launch() :: Bool
    cd("settings")

    touch("dev.jl")
    open("dev.jl", "w") do io
        write(io, ":dev = true \n")
    end

    open("Global.jl", "a+") do io
        write(io, "include(\"dev.jl\")")
    end

    cd("..")
    Dance.pre_launch(joinpath(abspath(@__DIR__), "demo"))
end


function static_files_append_content() :: Int64
    open("src/js/main.js", "a") do io_js
        write(io_js, "\$('#js-button').click(function() {\n  console.log(\"Button clicked\");\n});")
    end

    open("src/css/main.css", "a") do io_css
        write(io_css, "#js-button {\n  color: red;\n}")
    end
end
