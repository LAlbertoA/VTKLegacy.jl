push!(LOAD_PATH,"/home/luis/.julia/dev/VTKLegacy/src/")
using Documenter, VTKLegacy

makedocs(
    modules = [VTKLegacy],
    sitename="VTKLegacy.jl",
    pages = [
           "Home" => "index.md",
           "Loading Files" => "loading.md",
           "Plotting" => "plotting.md",
           "API" => "reference.md"])

deploydocs(
    repo = "github.com/LAlbertoA/VTKLegacy.jl.git",
)