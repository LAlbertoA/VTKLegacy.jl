var documenterSearchIndex = {"docs":
[{"location":"#VTKLegacy.jl-Documentation","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.jl Documentation","text":"","category":"section"},{"location":"","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.jl Documentation","text":"CurrentModule = VTKLegacy","category":"page"},{"location":"","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.jl Documentation","text":"Modules = [VTKLegacy]","category":"page"},{"location":"#VTKLegacy.StructuredPoints","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.StructuredPoints","text":"StructuredPoints\n\nObject that contains all the information and datasets from a Legacy VTK file with a STRUCTURED_POINTS geometry/topology.\n\nFields\n\ndata::Array{Float64,4}: 4-dimensional array of Float64 that holds the datasets of the vtk file.\ntitle::String: Title of the VTK file.\nnx::Int32: Number of cells in the x direction.\nny::Int32: Number of cells in the y direction.\nnz::Int32: Number of cells in the z direction.\ndx::Float64: Cell size in the x direction.\ndy::Float64: Cell size in the y direction.\ndz::Float64: Cell size in the z direction.\nx0::Float64: Position of origin in the x direction.\ny0::Float64: Position of origin in the y direction.\nz0::Float64: Position of origin in the z direction.\nx::Vector{Float64}: Cell positions in the x direction.\ny::Vector{Float64}: Cell positions in the y direction.\nz::Vector{Float64}: Cell positions in the z direction.\ndimensions::Vector{Int64}: Number of cells in each dimension: [nx,ny,nz].\nspacing::Vector{Float64}: Cell size in each dimension: [dx,dy,dz].\norigin::Vector{Float64}: Origin of the mesh: [x0,y0,z0].\ndataNames::Vector{String}: Names of the datasets in the VTK file.\ndataAttributes::Vector{String}: Attribute of each dataset in the VTK file.\ndictionary::Dict{String,Union{Int64,UnitRange{Int64}}}: Dictionary with the dataNames as the keys and the indexes of data as the values. \n\n\n\n\n\n","category":"type"},{"location":"#VTKLegacy.UnstructuredGrid","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.UnstructuredGrid","text":"UnstructuredGrid\n\nObject that contains all the information and datasets from a Legacy VTK file with a UNSTRUCTURED_GRID geometry/topology.\n\nFields\n\ntitle::String: Title of the VTK file.\nnpoints::Int32: Number of points that define the cells.\nncells::Int32: Number of cells in the file.\npoints::Array{AbstractFloat,2}: Array containing the coordinates of the points in the grid.\ncells::Vector{Int32}: Number and indexes of points defining each cell.\ncellTypes::Vector{Int32}: Type of each cell. Integer value between 1 and 16 \ncellData::Array{AbstractFloat,2}: Array containing each dataset in the CELL_DATA section.\ncellDataNames::Vector{String}: Name of each dataset in the CELL_DATA section.\ncellDataAttributes::Vector{String}: Attribute of each dataset in the CELL_DATA section.\ncellDict::Dict{String,IntOrRng}: Dictionary with the cellDataNames as the keys and the indexes of cellData as the values.\npointData::Array{AbstractFloat,2}: Array containing each dataset in the POINT_DATA section.\npointDataNames::Vector{String}: Name of each dataset in the POINT_DATA section.\npointDataAttributes::Vector{String}: Attribute of each dataset in the POINT_DATA section.\npointDict::Dict{String,IntOrRng}: Dictionary with the pointDataNames as the keys and the indexes of pointData as the values.\n\n\n\n\n\n","category":"type"},{"location":"#Base.getindex-Tuple{StructuredPoints, String}","page":"VTKLegacy.jl Documentation","title":"Base.getindex","text":"getindex(m::StructuredPoints, name::String)\n\nRetrieve the array stored in the m.data field with name name. The name should be an element of m.dataNames.  The syntax m[\"dataname\"] is converted by the compiler to getindex(m,\"dataname\").\n\n\n\n\n\n","category":"method"},{"location":"#Base.show-Tuple{StructuredPoints}","page":"VTKLegacy.jl Documentation","title":"Base.show","text":"show(m::StructuredPoints)\n\nPrint header information of the VTK file contained in the StructuredPoints object m\n\n\n\n\n\n","category":"method"},{"location":"#VTKLegacy.LoadVTK-Tuple{String}","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.LoadVTK","text":"LoadVTK(filename::String)\n\nRead the VTK file filename in to an object of type StructuredPoints or UnstructuredGrid. Currently only StructuredPoints and UnstructuredGrid are supported.\n\n\n\n\n\n","category":"method"},{"location":"#VTKLegacy.integrate","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.integrate","text":"integrate(m::StructuredPoints,var::Union{Int64,String,Vector{Union{Int64,String}}}=1)\n\nCompute the discrete integral of var in the whole mesh m as: \n\nI = sum_(ijk)=(111)^N_xN_yN_ztextvar_(ijk)Delta xDelta yDelta z\n\nIf var is unspecified, integrate only the dataset with index 1 in m.data\n\n\n\n\n\n","category":"function"},{"location":"#VTKLegacy.magnitude-Tuple{StructuredPoints, String}","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.magnitude","text":"magnitude(m::StructuredPoints,dataname::String)\n\nCompute the magnitude of a dataset in m with name dataname and attribute Vector.\n\n\n\n\n\n","category":"method"},{"location":"#VTKLegacy.probe","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.probe","text":"probe(filename::String, save::Bool = false, fig = Figure())\n\nGenerate heatmaps of each dataset in the VTK file filename at nz/2. If there are Vector datasets, plot the magnitude of the Vector array.\n\n\n\n\n\n","category":"function"},{"location":"#VTKLegacy.ranges","page":"VTKLegacy.jl Documentation","title":"VTKLegacy.ranges","text":"ranges(m::StructuredPoints,io::Union{IOStream,Nothing}=nothing)\n\nObtain the maximum and minimum values of each dataset in m and print them to io followed by a newline.\n\nIf io is unspecified, prints the values to the default output stream stdout.\n\n\n\n\n\n","category":"function"}]
}
