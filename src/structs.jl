"""
    Mesh

Object that contains all the information and datasets from a Legacy VTK file that has been read.

# Fields
- `data::Array{Float64,4}`: 4-dimensional array of `Float64` that holds the datasets of the vtk file.
- `title::String`: Title of the VTK file
- `nx::Int32`: Number of cells in the `x` direction.
- `ny::Int32`: Number of cells in the `y` direction.
- `nz::Int32`: Number of cells in the `z` direction.
- `dx::Float64`: Cell size in the `x` direction.
- `dy::Float64`: Cell size in the `y` direction.
- `dz::Float64`: Cell size in the `z` direction.
- `x0::Float64`: Position of origin in the `x` direction.
- `y0::Float64`: Position of origin in the `y` direction.
- `z0::Float64`: Position of origin in the `z` direction.
- `x::Vector{Float64}`: Cell positions in the `x` direction.
- `y::Vector{Float64}`: Cell positions in the `y` direction.
- `z::Vector{Float64}`: Cell positions in the `z` direction.
- `dimensions::Vector{Int64}`: Number of cells in each dimension: `[nx,ny,nz]`.
- `spacing::Vector{Float64}`: Cell size in each dimension: `[dx,dy,dz]`.
- `origin::Vector{Float64}`: Origin of the mesh: `[x0,y0,z0]`.
- `dataNames::Vector{String}`: Names of the datasets in the VTK file.
- `dataAttributes::Vector{String}`: Attribute of each dataset in the VTK file.
- `dictionary::Dict{String,Union{Int64,UnitRange{Int64}}}`: Dictionary with the `dataNames` as the `keys` and the indexes of `data` as the `values`. 
"""
mutable struct Mesh
    data::Array{Union{Float64,Float32,Int32,Int16},4}
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
    Mesh() = new()
end