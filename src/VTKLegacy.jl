module VTKLegacy

    using LoopVectorization                                    ## Usefull package to optimize some for-loops
    using CairoMakie                                           ## Visualization package for some functions

    import Base.getindex, Base.show                            ## importing Base functions to extend them

    export Mesh, LoadVTK, integrate, ranges, magnitude, probe  ## Exported names from this package

    const IntOrStr = Union{Int64,String}                       ## Custom Union Types
    const IntOrRng = Union{Int64,UnitRange{Int64}}             ## "

    include("structs.jl")
    include("stat_func.jl")
    include("load_func.jl")
    include("plotting.jl")

    function getindex(m::Mesh, name::String)
        return m.data[m.dictionary[name],:,:,:]
    end

    function show(m::Mesh)
        println("Title: $(m.title)")
        println("Dimensions: $(m.dimensions)")
        println("Spacing: $(m.spacing)")
        println("Origin: $(m.origin)")
        println("Name of the data: $(m.datanames)")
        println("Data type: $(m.dataattribute)")
    end
end