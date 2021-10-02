using JSON3
using DifferentialEquations, Sundials, CellMLToolkit


function dictify_solution(sol, state_names)
    n = size(sol)[1]
    @assert n == length(state_names)
    z = zip(state_names, (sol[i, :] for i in 1: n))
    d = Dict{String, Vector{Float64}}(z)
end


function jsonify_solution(sol, state_names)
    d = dictify_solution(sol, state_names)
    s = JSON3.write(d)
end


function parse_params(params)
    
    strs = map(string, first.(params))
    vals = last.(params)

    dlm = "₊"  # component_name₊variable_name
    strs = map(x -> split(x, dlm), strs)

    return strs, vals

end


function parse_states(states)

    strs, vals = parse_params(states)
    
    time_str = "(time)"
    for row in strs
        row[end] = row[end][1: end - length(time_str)]
    end

    return strs, vals

end


function dictify_params(strs, vals)
    z = zip(strs, vals)
    f = x -> Dict("component" => x[1][1],
                  "variable"  => x[1][2],
                  "value"     => x[2])
    return map(f, z)
end


function load_cellml_model(model_name)

    dirname_cellml_models = "models/cellml/"

    if model_name == "BR"
        filename = "beeler_reuter_1977/beeler_reuter_1977.cellml"
        filename_cellml_model = joinpath(dirname_cellml_models,
                                         filename)
        cellml_model = CellModel(filename_cellml_model)
        return cellml_model
    else
        msg = """your model $model_name is not found"""
        throw(msg)
    end

end


function get_params_dicts(cellml_model)
    p = list_params(cellml_model)
    return dictify_params(parse_params(p)...)
end


function get_states_dicts(cellml_model)
    s = list_states(cellml_model)
    return dictify_params(parse_states(s)...)
end


function solve_cellml_model(model_name::String;
                            kwargs_problem::Dict=Dict(),
                            kwargs_solve::Dict=Dict())
                            
    if model_name == "DUMMY"
        sol = Dict("time"          => [0., 1.],
                   "solution"      => [42., 3.14])
    else
        cellml_model = load_cellml_model(model_name)
        sol = solve_cellml_model(cellml_model;
                                 kwargs_problem=kwargs_problem,
                                 kwargs_solve=kwargs_solve)
    end

    return sol

end


function define_problem(cellml_model::CellModel;
                        kwargs_problem::Dict=Dict())

    tspan = Vector{Float64}(get(kwargs_problem, "tspan", (0., 1000.0)))
    prob = ODEProblem(cellml_model, tspan)

    if haskey(kwargs_problem, "p")
        p = Vector{Float64}(kwargs_problem["p"])
        prob = remake(prob; p=p)
    else
        # FIX ME
        prob.p[4] = 0.  # offset for beeler_reuter_1977
    end

    if haskey(kwargs_problem, "u0")
        u0 = Vector{Float64}(kwargs_problem["u0"])
        prob = remake(prob; u0=u0)
    end

    return prob

end


function process_kwargs_solve(kwargs_solve::Dict=Dict())

    result = Dict{Symbol, Any}()

    for kw in ("abstol", "reltol", "dt", "dtmax", "dtmin")

        if haskey(kwargs_solve, kw)
            result[Symbol(kw)] = kwargs_solve[kw]
        end

    end

    return NamedTuple(result)

end


function dictify_solution(sol, cellml_model::CellModel)

    sol_dict = get_states_dicts(cellml_model)
    sol_columns = (sol[i, :] for i in 1: size(sol)[1])
    for (sol_item, column) in zip(sol_dict, sol_columns)
        sol_item["value"] = column
    end

    result = Dict("time"     => sol.t,
                  "solution" => sol_dict)

end


function solve_cellml_model(cellml_model::CellModel;
                            kwargs_problem::Dict=Dict(),
                            kwargs_solve::Dict=Dict())
    
    prob = define_problem(cellml_model; kwargs_problem=kwargs_problem)
    kwargs_solve_processed = process_kwargs_solve(kwargs_solve)

    solver_default = "CVODE_BDF"
    solver_name = get(kwargs_solve, "solver", solver_default)
    solver = eval(Meta.parse(solver_name * "()"))

    sol = solve(prob, solver;
                kwargs_solve_processed...
                )

    result = dictify_solution(sol, cellml_model)
    result["initial_state"] = prob.u0
    result["params"]        = prob.p
                 
    return result

end
