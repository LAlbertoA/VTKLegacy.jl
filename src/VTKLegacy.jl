module VTKLegacy

    using LoopVectorization                                    ## Usefull package to optimize some for-loops
    using CairoMakie                                           ## Visualization package for some functions

    import Base.getindex, Base.show                            ## importing Base functions to extend them

    export Mesh, LoadVTK, integrate, ranges, magnitude, probe  ## Exported names from this package

    const IntOrStr = Union{Int64,String}                       ## Custom Union Types
    const IntOrRng = Union{Int64,UnitRange{Int64}}             ## "

    dt = Dict{String,DataType}("float"=>Float32,
        "double"=>Float64,"int"=>Int16,"short"=>Int16,         ## Data types supported by VTK files
        "long"=>Int32)

    include("structs.jl")
    include("stat_func.jl")
    include("load_func.jl")
    include("plotting.jl")

    """
        getindex(m::Mesh, name::String)

    Retrieve the array stored in the `m.data` field with name `name`. The `name` should be an element of `m.datanames`. 
    The syntax `m["dataname"]` is converted by the compiler to `getindex(m,"dataname")`.
    """
    function getindex(m::Mesh, name::String)
        return m.data[m.dictionary[name],:,:,:]
    end

    """
        show(m::Mesh)

    Print header information of the VTK file contained in the Mesh object `m`
    """
    function show(m::Mesh)
        println("Title: $(m.title)")
        println("Dimensions: $(m.dimensions)")
        println("Spacing: $(m.spacing)")
        println("Origin: $(m.origin)")
        println("Name of the data: $(m.dataNames)")
        println("Data type: $(m.dataAttributes)")
    end
end