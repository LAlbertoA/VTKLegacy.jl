module VTKLegacy

    using CairoMakie                                           ## Visualization package for some functions

    import Base.getindex, Base.show                            ## importing Base functions to extend them

    export StructuredPoints, LoadVTK, integrate, ranges
    export magnitude, probe, UnstructuredGrid                  ## Exported names from this package

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
        getindex(m::StructuredPoints, name::String)

    Retrieve the array stored in the `m.data` field with name `name`. The `name` should be an element of `m.dataNames`. 
    The syntax `m["dataname"]` is converted by the compiler to `getindex(m,"dataname")`.
    """
    function getindex(m::StructuredPoints, name::String)
        return m.data[m.dictionary[name],:,:,:]
    end

    """
        show(m::Union{StructuredPoints,UnstructuredGrid})

    Print general information of the VTK file contained in the object `m`
    """
    function show(m::Union{StructuredPoints,UnstructuredGrid,RectilinearGrid,StructuredGrid})
        t = typeof(m)
        if t == StructuredPoints
            println("Title: $(m.title)")
            println("Dimensions: $(m.dimensions)")
            println("Spacing: $(m.spacing)")
            println("Origin: $(m.origin)")
            println("Name of cell datasets: $(m.cellDataNames)")
            println("Cell data types: $(m.cellDataAttributes)")
            println("Name of point datasets: $(m.pointDataNames)")
            println("Point data types: $(m.pointDataAttributes)")
        elseif t == UnstructuredGrid
            println("Title: $(m.title)")
            println("Number of Cells: $(m.ncells)")
            println("Name of cell datasets: $(m.cellDataNames)")
            println("Cell data types: $(m.cellDataAttributes)")
            println("Number of Points: $(m.npoints)")
            println("Name of point datasets: $(m.pointDataNames)")
            println("Point data types: $(m.pointDataAttributes)")
        elseif t == StructuredGrid
            println("Title: $(m.title)")
            println("Dimensions: $(m.dimensions)")
            println("Name of cell datasets: $(m.cellDataNames)")
            println("Cell data types: $(m.cellDataAttributes)")
            println("Name of point datasets: $(m.pointDataNames)")
            println("Point data types: $(m.pointDataAttributes)")
        elseif t == RectilinearGrid
            println("Title: $(m.title)")
            println("Dimensions: $(m.dimensions)")
            println("Name of cell datasets: $(m.cellDataNames)")
            println("Cell data types: $(m.cellDataAttributes)")
            println("Name of point datasets: $(m.pointDataNames)")
            println("Point data types: $(m.pointDataAttributes)")
        end
    end
end