using HTTP
using Sockets: localhost
using JSON3

include("service_functions.jl")


const router = HTTP.Router()

# source: https://juliaweb.github.io/HTTP.jl/stable/public_interface/#HTTP.Handlers
function JSONHandler(req::HTTP.Request)
    # first check if there's any request body
    body = IOBuffer(HTTP.payload(req))
    if eof(body)
        # no request body
        response_body = HTTP.Handlers.handle(router, req)
    else
        # there's a body, so pass it on to the handler we dispatch to
        response_body = HTTP.Handlers.handle(router, req, JSON3.read(body, Dict))
    end
    return HTTP.Response(200, JSON3.write(response_body))
end


HTTP.@register(router, "POST", "/dummy_post", dummy_post)
HTTP.@register(router, "GET", "/dummy_get", dummy_get)

HTTP.@register(router, "GET", "/get_available_models", get_available_models)
HTTP.@register(router, "POST", "/get_model_params", get_model_params)
HTTP.@register(router, "POST", "/solve_problem", solve_problem)

println("Ready to serve!")
HTTP.serve(JSONHandler, localhost, 2021; access_log = logfmt"$remote_addr $request")
