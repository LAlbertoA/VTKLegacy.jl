module VTKLegacy

    using LoopVectorization
    using CairoMakie

    export Mesh, LoadVTK, integrate, ranges, magnitude, probe

    include("structs.jl")
    include("stat_func.jl")
    include("load_func.jl")
    include("plotting.jl")
end