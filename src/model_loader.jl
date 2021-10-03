using CellMLToolkit

include("parsers.jl")

const dirname_cellml_models = "models/cellml/"

model_name_to_filename = Dict{String,String}()
model_name_to_filename["BR"] = "beeler_reuter_1977/beeler_reuter_1977.cellml"
model_name_to_filename["ORd"] = "ohara_rudy/ohara_rudy_cipa_v1_2017.cellml"
model_name_to_filename["Maleckar"] = "maleckar_greenstein_trayanova_giles_2009/maleckar_greenstein_trayanova_giles_2009.cellml"


function load_cellml_model(
    model_name::String;
    model_name_to_filename::Dict{String,String} = model_name_to_filename,
)

    if haskey(model_name_to_filename, model_name)
        filename = model_name_to_filename[model_name]
        filename_cellml_model = joinpath(dirname_cellml_models, filename)
        cellml_model = CellModel(filename_cellml_model)
        return cellml_model
    else
        msg = """$model_name is not found in models storage"""
        throw(msg)
    end

end


function get_params_dicts(cellml_model::CellModel)
    cellml_model |> list_params |> parse_params
end


function get_states_dicts(cellml_model::CellModel)
    cellml_model |> list_states |> parse_states
end
