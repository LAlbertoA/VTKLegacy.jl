"""
    LoadVTK(filename::String)

Read the VTK file `filename` in to an object of type `StructuredPoints` or `UnstructuredGrid`.
Currently only StructuredPoints and UnstructuredGrid are supported.
"""
function LoadVTK(fp::String)
    open(fp) do f
        title = ""
        for i in 1:4
            s = readline(f)
            if i == 2
                title = s
            elseif i == 4
                sp = split(s)
                if sp[2] == "STRUCTURED_POINTS"
                    m = StructuredPoints()
                    loadSP(f, m, title)
                    return m
                elseif sp[2] == "UNSTRUCTURED_GRID"
                    m = UnstructuredGrid()
                    loadUSG(f, m, title)
                    return m
                elseif sp[2] == "STRUCTURED_GRID"
                    m = StructuredGrid()
                    loadSG(f, m, title)
                    return m
                elseif sp[2] == "RECTILINEAR_GRID"
                    m = RectilinearGrid()
                    loadRG(f, m, title)
                    return m
                end
            end
        end
    end
end
## Internal function. Only intended to be used inside LoadVTK function
function loadSP(f::IOStream, m::StructuredPoints, title::String)
    m.title = title
    m.cellDict = Dict{String,IntOrRng}()
    m.pointDict = Dict{String,IntOrRng}()
    ## Reading mesh size, spacing and origin
    for i in 1:3
        s = split(readline(f))
        if s[1] == "DIMENSIONS"
            m.nx = parse(Int32,s[2])
            m.ny = parse(Int32,s[3])
            m.nz = parse(Int32,s[4])
        elseif s[1] == "ORIGIN"
            m.x0 = parse(Float64,s[2])
            m.y0 = parse(Float64,s[3])
            m.z0 = parse(Float64,s[4])
        elseif s[1] == "SPACING"
            m.dx = parse(Float64,s[2])
            m.dy = parse(Float64,s[3])
            m.dz = parse(Float64,s[4])
        end
    end
    ## Reading Datasets in VTK file to m.data
    ccd = 0
    cpd = 0
    while ! eof(f)
        sp = split(readline(f))
        if length(sp) != 0
            if sp[1] == "CELL_DATA"
                ccd = 1
                read_cell_data(f, m)
            elseif sp[1] == "POINT_DATA"
                cpd = 1
                read_point_data(f, m)
            end
        end
    end
    GC.gc()
    if ccd != 1
        m.cellData = nothing
        m.cellDataNames = ["Nothing"]
        m.cellDataAttributes = ["Nothing"]
    end
    if cpd != 1
        m.pointData = nothing
        m.pointDataNames = ["Nothing"]
        m.pointDataAttributes = ["Nothing"]
    end
    m.dimensions = [m.nx,m.ny,m.nz]
    m.spacing = [m.dx,m.dy,m.dz]
    m.origin = [m.x0,m.y0,m.z0]
    m.x = m.x0.+collect(1:m.nx).*m.dx.-m.dx/2
    m.y = m.y0.+collect(1:m.ny).*m.dy.-m.dy/2
    m.z = m.z0.+collect(1:m.nz).*m.dz.-m.dz/2
    println("Title: $(m.title)")
    println("Dimensions: $(m.dimensions)")
    println("Spacing: $(m.spacing)")
    println("Origin: $(m.origin)")
    println("Name of cell datasets: $(m.cellDataNames)")
    println("Cell data types: $(m.cellDataAttributes)")
    println("Name of point datasets: $(m.pointDataNames)")
    println("Point data types: $(m.pointDataAttributes)")
end

function loadSG(f::IOStream, m::StructuredGrid, title::String)
    m.title = title
    m.cellDict = Dict{String,IntOrRng}()
    m.pointDict = Dict{String,IntOrRng}()
    ## Reading mesh size, spacing and origin
    for i in 1:2
        s = split(readline(f))
        if s[1] == "DIMENSIONS"
            m.nx = parse(Int32,s[2])
            m.ny = parse(Int32,s[3])
            m.nz = parse(Int32,s[4])
        elseif s[1] == "POINTS"
            m.npoints = parse(Int32,s[2])
            temp = Array{dt[sp[3]],4}(undef,3,m.nx,m.ny,m.nz)
            read!(f,temp)
            m.points = ntoh.(temp)
        end
    end
    ## Reading Datasets in VTK file to m.data
    ccd = 0
    cpd = 0
    while ! eof(f)
        sp = split(readline(f))
        if length(sp) != 0
            if sp[1] == "CELL_DATA"
                ccd = 1
                read_cell_data(f, m)
            elseif sp[1] == "POINT_DATA"
                cpd = 1
                read_point_data(f, m)
            end
        end
    end
    GC.gc()
    if ccd != 1
        m.cellData = nothing
        m.cellDataNames = ["Nothing"]
        m.cellDataAttributes = ["Nothing"]
    end
    if cpd != 1
        m.pointData = nothing
        m.pointDataNames = ["Nothing"]
        m.pointDataAttributes = ["Nothing"]
    end
    m.dimensions = [m.nx,m.ny,m.nz]
    println("Title: $(m.title)")
    println("Dimensions: $(m.dimensions)")
    println("Name of cell datasets: $(m.cellDataNames)")
    println("Cell data types: $(m.cellDataAttributes)")
    println("Name of point datasets: $(m.pointDataNames)")
    println("Point data types: $(m.pointDataAttributes)")
end

function loadRG(f::IOStream, m::RectilinearGrid, title::String)
    m.title = title
    m.cellDict = Dict{String,IntOrRng}()
    m.pointDict = Dict{String,IntOrRng}()
    ## Reading mesh size, spacing and origin
    s = split(readline(f))
    m.nx = parse(Int32,s[2])
    m.ny = parse(Int32,s[3])
    m.nz = parse(Int32,s[4])
    ## Reading Datasets in VTK file to m.data
    ccd = 0
    cpd = 0
    while ! eof(f)
        sp = split(readline(f))
        if length(sp) != 0
            if sp[1] == "X_COORDINATES"
                temp = Vector{dt[sp[3]]}(undef,m.nx)
                read!(f,temp)
                m.xCoordinates = ntoh.(temp)
            elseif sp[1] == "Y_COORDINATES"
                temp = Vector{dt[sp[3]]}(undef,m.ny)
                read!(f,temp)
                m.yCoordinates = ntoh.(temp)
            elseif sp[1] == "Z_COORDINATES"
                temp = Vector{dt[sp[3]]}(undef,m.nz)
                read!(f,temp)
                m.zCoordinates = ntoh.(temp)
            elseif sp[1] == "CELL_DATA"
                ccd = 1
                read_cell_data(f, m)
            elseif sp[1] == "POINT_DATA"
                cpd = 1
                read_point_data(f, m)
            end
        end
    end
    GC.gc()
    if ccd != 1
        m.cellData = nothing
        m.cellDataNames = ["Nothing"]
        m.cellDataAttributes = ["Nothing"]
    end
    if cpd != 1
        m.pointData = nothing
        m.pointDataNames = ["Nothing"]
        m.pointDataAttributes = ["Nothing"]
    end
    m.dimensions = [m.nx,m.ny,m.nz]
    println("Title: $(m.title)")
    println("Dimensions: $(m.dimensions)")
    println("Name of cell datasets: $(m.cellDataNames)")
    println("Cell data types: $(m.cellDataAttributes)")
    println("Name of point datasets: $(m.pointDataNames)")
    println("Point data types: $(m.pointDataAttributes)")
end

function loadUSG(f::IOStream, m::UnstructuredGrid, title::String)
    m.title = title
    ccd = 0
    cpd = 0
    m.cellDict = Dict{String,IntOrRng}()
    m.pointDict = Dict{String,IntOrRng}()
    while ! eof(f)
        sp = split(readline(f))
        if length(sp) != 0
            if sp[1] == "POINTS"
                m.npoints = parse(Int32,sp[2])
                temp = Array{dt[sp[3]],2}(undef,3,parse(Int32,sp[2]))
                read!(f,temp)
                m.points = ntoh.(temp)
            elseif sp[1] == "CELLS"
                m.ncells = parse(Int32, sp[2])
                temp = Array{Int32,1}(undef,parse(Int32,sp[3]))
                read!(f,temp)
                m.cells = ntoh.(temp)
            elseif sp[1] == "CELL_TYPES"
                temp = Array{Int32,1}(undef,parse(Int32,sp[2]))
                read!(f,temp)
                m.cellTypes = ntoh.(temp)
            elseif sp[1] == "CELL_DATA"
                ccd = 1
                read_cell_data(f, m)
            elseif sp[1] == "POINT_DATA"
                cpd = 1
                read_point_data(f, m)
            end
        end
    end
    GC.gc()
    if ccd != 1
        m.cellData = nothing
        m.cellDataNames = ["Nothing"]
        m.cellDataAttributes = ["Nothing"]
    end
    if cpd != 1
        m.pointData = nothing
        m.pointDataNames = ["Nothing"]
        m.pointDataAttributes = ["Nothing"]
    end
    println("Title: $(m.title)")
    println("Number of Cells: $(m.ncells)")
    println("Name of cell datasets: $(m.cellDataNames)")
    println("Cell data types: $(m.cellDataAttributes)")
    println("Number of Points: $(m.npoints)")
    println("Name of point datasets: $(m.pointDataNames)")
    println("Point data types: $(m.pointDataAttributes)")
end
## Reading point data and cell data from STRUCTURED_POINTS, STRUCTURED_GRID and RECTILINEAR_GRID
function read_point_data(f::IOStream, m::Union{RectilinearGrid,StructuredPoints,StructuredGrid})
    pointNames = String[]
    pointTypes = String[]
    sp = "READING POINT DATA"
    c = 0
    while ! eof(f) && sp[1] != "CELL_DATA"
        sp = split(readline(f)*" .")
        if length(sp) != 0 && sp[1] == "SCALARS"
            if length(pointNames) == 0
                temp = Array{dt[sp[3]],4}(undef,1,m.nx,m.ny,m.nz)
                readline(f)
                read!(f,temp)
                m.pointData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],4}(undef,1,m.nx,m.ny,m.nz)
                readline(f)
                read!(f,temp)
                m.pointData = cat(m.pointData,ntoh.(temp),dims=1)
            end
            c += 1
            push!(pointNames,sp[2])
            push!(pointTypes,sp[1])
            m.pointDict[sp[2]] = c
        elseif length(sp) != 0 && sp[1] == "VECTORS"
            if length(pointNames) == 0
                temp = Array{dt[sp[3]],4}(undef,3,m.nx,m.ny,m.nz)
                read!(f,temp)
                m.pointData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],4}(undef,3,m.nx,m.ny,m.nz)
                read!(f,temp)
                m.pointData = cat(m.pointData,ntoh.(temp),dims=1)
            end
            c += 3
            push!(pointNames,sp[2])
            m.pointDict[sp[2]*"_x"] = c-2
            m.pointDict[sp[2]*"_y"] = c-1
            m.pointDict[sp[2]*"_z"] = c
            push!(pointTypes, sp[1])
            m.pointDict[sp[2]] = c-2:c
        end
    end
    m.pointDataNames = pointNames
    m.pointDataAttributes = pointTypes
end

function read_cell_data(f::IOStream, m::Union{StructuredPoints,RectilinearGrid,StructuredGrid})
    cellNames = String[]
    cellTypes = String[]
    sp = "READING CELL DATA"
    c = 0
    while ! eof(f) && sp[1] != "POINT_DATA"
        sp = split(readline(f)*" .") 
        if length(sp) != 0 && sp[1] == "SCALARS"
            if length(cellNames) == 0
                temp = Array{dt[sp[3]],4}(undef,1,m.nx-1,m.ny-1,m.nz-1)
                readline(f)
                read!(f,temp)
                m.cellData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],4}(undef,1,m.nx-1,m.ny-1,m.nz-1)
                readline(f)
                read!(f,temp)
                m.cellData = cat(m.cellData,ntoh.(temp),dims=1)
            end
            c += 1
            push!(cellNames,sp[2])
            push!(cellTypes,sp[1])
            m.cellDict[sp[2]] = c
        elseif length(sp) != 0 && sp[1] == "VECTORS"
            if length(cellNames) == 0
                temp = Array{dt[sp[3]],4}(undef,3,m.nx-1,m.ny-1,m.nz-1)
                read!(f,temp)
                m.cellData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],4}(undef,3,m.nx-1,m.ny-1,m.nz-1)
                read!(f,temp)
                m.cellData = cat(m.cellData,ntoh.(temp),dims=1)
            end
            c += 3
            push!(cellNames,sp[2])
            m.cellDict[sp[2]*"_x"] = c-2
            m.cellDict[sp[2]*"_y"] = c-1
            m.cellDict[sp[2]*"_z"] = c
            push!(cellTypes, sp[1])
            m.cellDict[sp[2]] = c-2:c
        end
    end
    m.cellDataNames = cellNames
    m.cellDataAttributes = cellTypes
end
## Reading point data and cell data from UNSTRUCTURED_GRID
function read_cell_data(f::IOStream, m::UnstructuredGrid)
    cellNames = String[]
    cellTypes = String[]
    sp = "READING CELL DATA"
    c = 0
    while ! eof(f) && sp[1] != "POINT_DATA"
        sp = split(readline(f)*" .") 
        if length(sp) != 0 && sp[1] == "SCALARS"
            if length(cellNames) == 0
                temp = Array{dt[sp[3]],2}(undef,1,m.ncells)
                readline(f)
                read!(f,temp)
                m.cellData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],2}(undef,1,m.ncells)
                readline(f)
                read!(f,temp)
                m.cellData = cat(m.cellData,ntoh.(temp),dims=1)
            end
            c += 1
            push!(cellNames,sp[2])
            push!(cellTypes,sp[1])
            m.cellDict[sp[2]] = c
        elseif length(sp) != 0 && sp[1] == "VECTORS"
            if length(cellNames) == 0
                temp = Array{dt[sp[3]],2}(undef,3,m.ncells)
                read!(f,temp)
                m.cellData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],2}(undef,3,m.ncells)
                read!(f,temp)
                m.cellData = cat(m.cellData,ntoh.(temp),dims=1)
            end
            c += 3
            push!(cellNames,sp[2])
            m.cellDict[sp[2]*"_x"] = c-2
            m.cellDict[sp[2]*"_y"] = c-1
            m.cellDict[sp[2]*"_z"] = c
            push!(cellTypes, sp[1])
            m.cellDict[sp[2]] = c-2:c
        end
    end
    m.cellDataNames = cellNames
    m.cellDataAttributes = cellTypes
end

function read_point_data(f::IOStream, m::UnstructuredGrid)
    pointNames = String[]
    pointTypes = String[]
    sp = "READING POINT DATA"
    c = 0
    while ! eof(f) && sp[1] != "CELL_DATA"
        sp = split(readline(f)*" .")
        if length(sp) != 0 && sp[1] == "SCALARS"
            if length(pointNames) == 0
                temp = Array{dt[sp[3]],2}(undef,1,m.npoints)
                readline(f)
                read!(f,temp)
                m.pointData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],2}(undef,1,m.npoints)
                readline(f)
                read!(f,temp)
                m.pointData = cat(m.pointData,ntoh.(temp),dims=1)
            end
            c += 1
            push!(pointNames,sp[2])
            push!(pointTypes,sp[1])
            m.pointDict[sp[2]] = c
        elseif length(sp) != 0 && sp[1] == "VECTORS"
            if length(pointNames) == 0
                temp = Array{dt[sp[3]],2}(undef,3,m.npoints)
                read!(f,temp)
                m.pointData = ntoh.(temp)
            else
                temp = Array{dt[sp[3]],2}(undef,3,m.npoints)
                read!(f,temp)
                m.pointData = cat(m.pointData,ntoh.(temp),dims=1)
            end
            c += 3
            push!(pointNames,sp[2])
            m.pointDict[sp[2]*"_x"] = c-2
            m.pointDict[sp[2]*"_y"] = c-1
            m.pointDict[sp[2]*"_z"] = c
            push!(pointTypes, sp[1])
            m.pointDict[sp[2]] = c-2:c
        end
    end
    m.pointDataNames = pointNames
    m.pointDataAttributes = pointTypes
end