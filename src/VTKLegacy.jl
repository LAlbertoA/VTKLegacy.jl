module VTKLegacy

    import Base.getindex, Base.show                            ## importing Base functions to extend them

    export StructuredPoints, LoadVTK, integrate, ranges
    export magnitude, UnstructuredGrid, RectilinearGrid        ## Exported names from this package
    export StructuredGrid, VTKDataSet, WriteVTK

    const IntOrStr = Union{Int64,String}                       ## Custom Union Types
    const IntOrRng = Union{Int64,UnitRange{Int64}}

    dt = Dict{String,DataType}("float"=>Float32,
        "double"=>Float64,"int"=>Int16,"short"=>Int16,         ## Data types supported by VTK files
        "long"=>Int32)

    include("structs.jl")
    include("stat_func.jl")
    include("load_func.jl")
    #include("plotting.jl")
    include("write_func.jl")

    """
        getindex(m::VTKDataSet, name::String)

    Retrieve the array stored in the `m.pointData` or `m.cellData` field with name `name`. The 
    `name` should be an element of `m.pointDataNames` or `m.cellDataNames`, if not throws an error. If the 
    `name` is an element of both throws an error. The syntax `m["name"]` is converted by the compiler 
    to `getindex(m,"name")`.
    """
    function getindex(m::VTKDataSet, name::String)
        if name in m.pointDataNames && name in m.cellDataNames
            error("Point dataset and cell dataset with same name. Use index number in pointData or 
            cellData field to retrieve specific array.")
        elseif name in m.pointDataNames
            if typeof(m) == UnstructuredGrid
                return m.pointData[m.pointDict[name],:]
            else
                return m.pointData[m.pointDict[name],:,:,:]
            end
        elseif name in m.cellDataNames
            if typeof(m) == UnstructuredGrid
                return m.cellData[m.cellDict[name],:]
            else
                return m.cellData[m.cellDict[name],:,:,:]
            end
        else
            error("Dataset with name $(name) not found in $(typeof(m)) object")
        end
    end

    """
        show(m::VTKDataSet)

    Print general information of the VTK file contained in the object `m`
    """
    function show(m::VTKDataSet)
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