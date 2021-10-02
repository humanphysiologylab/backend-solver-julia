using HTTP
using JSON3
using Sockets

include("solve.jl")


function func_solve_model(req::HTTP.Request)

    body = JSON3.read(IOBuffer(HTTP.payload(req)))
    name_cellml_model = body["model"]

    sol_dict = solve_cellml_model(name_cellml_model)
    return HTTP.Response(200, JSON3.write(sol_dict))

end


function func_get_model_states_params(req::HTTP.Request)

    body = JSON3.read(IOBuffer(HTTP.payload(req)))
    name_cellml_model = body["model"]

    cellml_model = load_cellml_model(name_cellml_model)

    response = Dict("states" => get_states_dicts(cellml_model),
                    "params" => get_params_dicts(cellml_model))

    return HTTP.Response(200, JSON3.write(response))

end


function func_post(req::HTTP.Request)
    body = JSON3.read(IOBuffer(HTTP.payload(req)))
    response = Dict("dummy" => "post", 
                    "recieved_body" => body)
    return HTTP.Response(200, JSON3.write(response))
end


function func_get(req::HTTP.Request)
    response = Dict("dummy" => "get")
    return HTTP.Response(200, JSON3.write(response))
end


const router = HTTP.Router()

HTTP.@register(router, "POST", "/dummy_post", func_post)
HTTP.@register(router, "GET",  "/dummy_get",  func_get)

HTTP.@register(router, "POST", "/solve_cellml_model",
               func_solve_model)
HTTP.@register(router, "POST", "/get_model_states_params",
               func_get_model_states_params)

HTTP.serve(router, Sockets.localhost, 2021;  access_log = logfmt"$remote_addr $request")
println("Ready to serve!")s
