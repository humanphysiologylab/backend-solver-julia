function parse_params(params)

    strs = map(string, first.(params))
    vals = last.(params)

    dlm = "₊"  # component_name₊variable_name
    strs = map(x -> split(x, dlm), strs)

    return dictify_params(strs, vals)

end


function parse_states(states)

    states_dict = parse_params(states)

    time_str = "(time)"
    for item in states_dict
        item["variable"] = item["variable"][1:end-length(time_str)]
    end

    return states_dict
end


function dictify_params(strs, vals)
    z = zip(strs, vals)
    f = x -> Dict("component" => x[1][1], "variable" => x[1][2], "value" => x[2])
    return map(f, z)
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
