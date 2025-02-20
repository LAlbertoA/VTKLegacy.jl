push!(LOAD_PATH,"/home/luis/.julia/dev/VTKLegacy/src/")
using Documenter, VTKLegacy

makedocs(
    modules = [VTKLegacy],
    sitename="VTKLegacy.jl")
