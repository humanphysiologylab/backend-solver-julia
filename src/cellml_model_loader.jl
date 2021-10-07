using CellMLToolkit
using LRUCache

include("parsers.jl")

const dirname_cellml_models = "models/cellml/"

model_name_to_filename = Dict{String,String}()
model_name_to_filename["BR"] = "beeler_reuter_1977/beeler_reuter_1977.cellml"
model_name_to_filename["ORd"] = "ohara_rudy/ohara_rudy_cipa_v1_2017.cellml"
model_name_to_filename["Maleckar"] = "maleckar_greenstein_trayanova_giles_2009/maleckar_greenstein_trayanova_giles_2009.cellml"
model_name_to_filename["LR2"] = "luo_rudy_1994/luo_rudy_1994.cellml"

lru_cellml_model = LRU{String,CellModel}(maxsize = 42)


function load_cellml_model(
    model_name::String;
    model_name_to_filename::Dict{String,String} = model_name_to_filename,
)
    @debug "loading $model_name"

    if haskey(model_name_to_filename, model_name)

        # cached version
        get!(lru_cellml_model, model_name) do
            filename = model_name_to_filename[model_name]
            filename_cellml_model = joinpath(dirname_cellml_models, filename)
            cellml_model = CellModel(filename_cellml_model)
        end

    else
        msg = """$model_name is not found in models storage"""
        throw(msg)
    end

end
