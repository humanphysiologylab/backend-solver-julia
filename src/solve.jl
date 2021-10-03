using DifferentialEquations, Sundials, CellMLToolkit

include("parsers.jl")
include("model_loader.jl")


function define_problem(cellml_model::CellModel; kwargs_problem::Dict = Dict())

    tspan = Vector{Float64}(get(kwargs_problem, "tspan", (0.0, 1000.0)))
    prob = ODEProblem(cellml_model, tspan)

    if haskey(kwargs_problem, "p")
        p = Vector{Float64}(kwargs_problem["p"])
        prob = remake(prob; p = p)
    end

    if haskey(kwargs_problem, "u0")
        u0 = Vector{Float64}(kwargs_problem["u0"])
        prob = remake(prob; u0 = u0)
    end

    return prob

end


function solve_cellml_model(
    model_name::String;
    kwargs_problem::Dict = Dict(),
    kwargs_solve::Dict = Dict(),
)

    if model_name == "DUMMY"
        sol = Dict("time" => [0.0, 1.0], "solution" => [42.0, 3.14])
    else
        cellml_model = load_cellml_model(model_name)
        sol = solve_cellml_model(
            cellml_model;
            kwargs_problem = kwargs_problem,
            kwargs_solve = kwargs_solve,
        )
    end

    return sol

end


function get_solver(kwargs_solve::Dict = Dict(), solver_name_default::String = "CVODE_BDF")

    solver_name = get(kwargs_solve, "solver", solver_name_default)
    solver = eval(Meta.parse(solver_name * "()"))
end


function solve_cellml_model(
    cellml_model::CellModel;
    kwargs_problem::Dict = Dict(),
    kwargs_solve::Dict = Dict(),
)

    prob = define_problem(cellml_model; kwargs_problem = kwargs_problem)
    solver = get_solver(kwargs_solve)
    kwargs_solve_opt = parse_opt_kwargs_solve(kwargs_solve)

    sol = solve(prob, solver; kwargs_solve_opt...)

    states_dict = get_states_dicts(cellml_model)
    result = dictify_solution(sol, states_dict)

    # for debugging purposes
    result["initial_state"] = prob.u0
    result["params"] = prob.p

    return result

end
