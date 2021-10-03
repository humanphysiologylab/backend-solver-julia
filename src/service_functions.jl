using HTTP
using Parameters: @unpack

include("solve.jl")


function solve_problem(req::HTTP.Request, req_body::Dict)

    @unpack model_name, kwargs_problem, kwargs_solve = req_body

    sol_dict = solve_cellml_model(
        model_name;
        kwargs_problem = kwargs_problem,
        kwargs_solve = kwargs_solve,
    )
end


function get_model_states_params(req::HTTP.Request, req_body::Dict)

    @unpack model_name = req_body

    if model_name == "DUMMY"
        response = Dict("states" => "dummy states", "params" => "dummy params")
    else
        cellml_model = load_cellml_model(model_name)
        response = Dict(
            "states" => get_states_dicts(cellml_model),
            "params" => get_params_dicts(cellml_model),
        )
    end

    return response

end


function get_available_models(req::HTTP.Request)
    collect(keys(model_name_to_filename))
end


function dummy_post(req::HTTP.Request, req_body::Dict)
    response = Dict("dummy" => "post", "received_body" => req_body)
end


function dummy_get(req::HTTP.Request)
    response = Dict("dummy" => "get")
end
