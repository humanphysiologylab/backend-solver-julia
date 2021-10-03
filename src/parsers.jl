function parse_param_name(name)
    dlm = "₊"  # component_name₊variable_name
    component_name, variable_name = split(name, dlm)
    time_str = "(time)"
    if endswith(variable_name, time_str)
        variable_name = variable_name[1:end-length(time_str)]
    end
    return component_name, variable_name
end


function dictify_params(strs, vals)
    z = zip(strs, vals)
    f = x -> Dict("component" => x[1][1], "variable" => x[1][2], "value" => x[2])
    return map(f, z)
end


function parse_params(params)

    strs = params .|> first .|> string .|> parse_param_name
    vals = last.(params)

    return dictify_params(strs, vals)

end


function parse_observables(cellml::CellModel)

    obs = observed(cellml.sys)  # looks like:
    # slow_inward_current_f_gate₊V(time) ~ membrane₊V(time)
    # time_independent_outward_current₊i_K1(time) ~ membrane₊i_K1(time)

    obs_lhs = map(x -> x.lhs, obs)

    obs_strs = obs_lhs .|> string .|> parse_param_name
    vals = zeros(size(obs_strs))

    return dictify_params(obs_strs, vals)

end


function dictify_solution(sol, states_dict::Vector{Dict{String,Any}})

    sol_columns = (sol[i, :] for i = 1:size(sol)[1])
    for (sol_item, column) in zip(states_dict, sol_columns)
        sol_item["value"] = column
    end

    result = Dict("time" => sol.t, "solution" => states_dict)

end


function parse_opt_kwargs_solve(kwargs_solve::Dict = Dict())

    result = Dict{Symbol,Any}()

    for kw in ("abstol", "reltol", "dt", "dtmax", "dtmin")

        if haskey(kwargs_solve, kw)
            result[Symbol(kw)] = kwargs_solve[kw]
        end

    end

    return NamedTuple(result)

end
