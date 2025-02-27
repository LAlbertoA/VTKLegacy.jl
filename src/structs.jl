"""
    StructuredPoints

Object that contains all the information and datasets from a Legacy VTK file with a STRUCTURED_POINTS geometry/topology.

# Fields
- `data::Array{Float64,4}`: 4-dimensional array of `Float64` that holds the datasets of the vtk file.
- `title::String`: Title of the VTK file.
- `nx::Int32`: Number of points in the `x` direction.
- `ny::Int32`: Number of points in the `y` direction.
- `nz::Int32`: Number of points in the `z` direction.
- `dx::Float64`: Distance between points in the `x` direction.
- `dy::Float64`: Distance between points in the `y` direction.
- `dz::Float64`: Distance between points in the `z` direction.
- `x0::Float64`: Position of origin in the `x` direction.
- `y0::Float64`: Position of origin in the `y` direction.
- `z0::Float64`: Position of origin in the `z` direction.
- `x::Vector{Float64}`: Points positions in the `x` direction.
- `y::Vector{Float64}`: Points positions in the `y` direction.
- `z::Vector{Float64}`: Points positions in the `z` direction.
- `dimensions::Vector{Int64}`: Number of points in each dimension: `[nx,ny,nz]`.
- `spacing::Vector{Float64}`: Spacing size in each dimension: `[dx,dy,dz]`.
- `origin::Vector{Float64}`: Origin of the mesh: `[x0,y0,z0]`.
- `dataNames::Vector{String}`: Names of the datasets in the VTK file.
- `dataAttributes::Vector{String}`: Attribute of each dataset in the VTK file.
- `dictionary::Dict{String,Union{Int64,UnitRange{Int64}}}`: Dictionary with the `dataNames` as the `keys` and the indexes of `data` as the `values`. 
"""
mutable struct StructuredPoints
    data::Array{Float64,4}
    title::String
    nx::Int32
    ny::Int32
    nz::Int32
    dx::Float64
    dy::Float64
    dz::Float64
    x0::Float64
    y0::Float64
    z0::Float64
    x::Vector{Float64}
    y::Vector{Float64}
    z::Vector{Float64}
    dimensions::Vector{Int32}
    spacing::Vector{Float64}
    origin::Vector{Float64}
    dataNames::Vector{String}
    dataAttributes::Vector{String}
    dictionary::Dict{String,IntOrRng}
    StructuredPoints() = new()
end

"""
    UnstructuredGrid

Object that contains all the information and datasets from a Legacy VTK file with a UNSTRUCTURED_GRID geometry/topology.

# Fields
- `title::String`: Title of the VTK file.
- `npoints::Int32`: Number of points that define the cells.
- `ncells::Int32`: Number of cells in the file.
- `points::Array{AbstractFloat,2}`: Array containing the coordinates of the points in the grid.
- `cells::Vector{Int32}`: Number and indexes of points defining each cell.
- `cellTypes::Vector{Int32}`: Type of each cell. Integer value between 1 and 16 
- `cellData::Array{AbstractFloat,2}`: Array containing each dataset in the CELL_DATA section.
- `cellDataNames::Vector{String}`: Name of each dataset in the CELL_DATA section.
- `cellDataAttributes::Vector{String}`: Attribute of each dataset in the CELL_DATA section.
- `cellDict::Dict{String,IntOrRng}`: Dictionary with the `cellDataNames` as the `keys` and the indexes of `cellData` as the `values`.
- `pointData::Array{AbstractFloat,2}`: Array containing each dataset in the POINT_DATA section.
- `pointDataNames::Vector{String}`: Name of each dataset in the POINT_DATA section.
- `pointDataAttributes::Vector{String}`: Attribute of each dataset in the POINT_DATA section.
- `pointDict::Dict{String,IntOrRng}`: Dictionary with the `pointDataNames` as the `keys` and the indexes of `pointData` as the `values`.
"""
mutable struct UnstructuredGrid
    title::String
    npoints::Int32
    ncells::Int32
    points::Array{Float64,2}
    cells::Vector{Int32}
    cellTypes::Vector{Int32}
    cellData::Union{Array{Float64,2}, Nothing}
    cellDataNames::Vector{String}
    cellDataAttributes::Vector{String}
    cellDict::Dict{String,IntOrRng}
    pointData::Union{Array{Float64,2}, Nothing}
    pointDataNames::Vector{String}
    pointDataAttributes::Vector{String}
    pointDict::Dict{String,IntOrRng}
    UnstructuredGrid() = new()
end