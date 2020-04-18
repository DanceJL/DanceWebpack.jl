#!/usr/bin/env julia

using Test, SafeTestsets


@time begin
@time @safetestset "Project.toml append values to package.json" begin include("project_toml_append_values_test.jl") end
@time @safetestset "Webpack integration to existing project" begin include("project_integration_test.jl") end
end
