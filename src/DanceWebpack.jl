module DanceWebpack

export setup


"""
    setup(project_path::String="."; html_base_file_path::String="html/base.html")

- Specify `html_base_file_path` if different from Dance project default location

- Copy sample files (`package.json`, `webpack.config.js`, `src` dir) to `static` dir in project
- Obtain `authors`, `name`, `version` from `Project.toml` and set in `package.json` (optional, values can be blank if no `Project.toml` found)
- Overwrite `html_file` in `webpack.config.js`
"""
function setup(project_path::String="."; html_base_file_path::String="html/base.html") :: Nothing
    copied_file_path::String = abspath(joinpath(project_path, "static"))

    # Copy Webpack files to project root
    sample_files_dir::String = joinpath(@__DIR__, "../files")
    cp(sample_files_dir, copied_file_path)
    run(`chmod 755 $copied_file_path`)

    # Obtain `authors`, `name`, `version` values from project Project.toml
    authors::String = ""
    name::String = ""
    version::String = ""
    try
        for line in readlines(joinpath(copied_file_path, "../Project.toml"))
            for item in [
                ["authors", authors],
                ["name", name],
                ["version", version]
            ]
                if occursin(item[1], line)
                    value::String = strip(split(line, '=')[2])
                    if item[1]=="authors"
                        authors = replace(value, "\\\"" => "*")  # temporary flag quotation escapes: \"
                        authors = replace(authors, "\"" => "\\\"")
                        authors = replace(authors, "*" => "\\\"")  # put back flag quotation escapes: \"
                    else
                        item[2] = strip(value, '"')
                        if item[1]=="name"
                            name = item[2]
                        elseif item[1]=="version"
                            version = item[2]
                        end
                    end
                end
            end
        end
    catch e
        nothing
    end

    # Overwrite `author`, `name`, `version` var tags in package.json
    file_string::String = ""
    package_json_file_path::String = joinpath(copied_file_path, "package.json")
    open(package_json_file_path, "r") do io
        file_string = read(io, String)
    end
    for item in [
        ["author", authors],
        ["name", name],
        ["version", version]
    ]
        idx::String = "\$" * item[1]
        file_string = replace(file_string, "$idx" => item[2])
    end
    open(package_json_file_path, "w") do io
        write(io, file_string)
    end

    # Overwrite `$html_file` in webpack.config.js
    webpack_config_file_path::String = joinpath(copied_file_path, "webpack.config.js")
    open(webpack_config_file_path, "r") do io
        file_string = read(io, String)
    end
    idx = "\$html_file"
    file_string = replace(file_string, "$idx" => "\"../" * html_base_file_path * "\"")
    open(webpack_config_file_path, "w") do io
        write(io, file_string)
    end

    @info "Webpack files added to `static` dir in project.\nPlease cd into `static` dir and add dependencies by installing NodeJS and running `npm install`"
end

end