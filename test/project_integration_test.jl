import Dance
import DanceWebpack
import HTTP

include("utils.jl")


# Dance by default does not automatically add Project.toml
# => test here with no values specified
Dance.start_project("demo")
cd("demo")
project_settings_and_launch()
@test_logs (:info, "Webpack files added to `static` dir in project.\nPlease cd into `static` dir and add dependencies by installing NodeJS and running `npm install`") DanceWebpack.setup()


# Todo: fix for TravisCI Windows
if !Sys.iswindows()
    cd("static")
    run(`npm install`)
    static_files_append_content()


    #= Test Prod mode content is properly served =#
    run(`npm run build`)
    bundle_id = get_webpack_bundle_id()
    Dance.Router.delete_routes!()
    Dance.pre_launch(joinpath(abspath(@__DIR__), "demo"))

    @testset "HTTP.listen" begin
        @async Dance.launch(true)

        r = HTTP.request("GET", "http://127.0.0.1:8000/")
        @test r.status==200
        compare_http_header(r.headers, "content_type", "text/html; charset=UTF-8")
        @test extract_html_body_content(r.body)=="Hello World"

        r = HTTP.request("GET", "http://127.0.0.1:8000/static/main.$bundle_id.js")
        @test r.status==200
        compare_http_header(r.headers, "content_type", "text/javascript")

        r = HTTP.request("GET", "http://127.0.0.1:8000/static/vendors~main.$bundle_id.js")
        @test r.status==200
        compare_http_header(r.headers, "content_type", "text/javascript")

        r = HTTP.request("GET", "http://127.0.0.1:8000/static/main.$bundle_id.css")
        @test r.status==200
        compare_http_header(r.headers, "content_type", "text/css")
    end

    cd("static")


    #= Test over-writting `base.html` with Dev mode =#
    @testset "npm run develop" begin
        @async run(`npm run develop`)
        sleep(5)
        html_file = read("../html/base.html", String)
        @test occursin("<script src=\"http://localhost:3000/main.js\"></script>", html_file)
    end


    #= Test over-writting `base.html` with Prod mode =#
    run(`npm run build`)
    html_file = read("../html/base.html", String)
    @test occursin("<link rel=\"stylesheet\" href=\"/static/main.", html_file)
    @test occursin("<script src=\"/static/main.", html_file)
    @test occursin("<script src=\"/static/vendors~main.", html_file)
end


delete_project()
