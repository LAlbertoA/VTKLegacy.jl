module VTKLegacy

    using LoopVectorization
    using CairoMakie

    export Mesh, LoadVTK, integrate, ranges, magnitude, probe

    const IntOrStr = Union{Int64,String}
    const IntOrRng = Union{Int64,UnitRange{Int64}}

    include("structs.jl")
    include("stat_func.jl")
    include("load_func.jl")
    include("plotting.jl")
end