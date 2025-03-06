# Loading VTK legacy files

The motivation behind VTKLegacy is the ability to extract the contents of a VTK file written in legacy format and load the data to an object deppending of the geometry/topology of the datasets.
The data must be written in binary and, currently, only "STRUCTURED\_POINTS", "STRUCTURED\_GRID", "RECTILINEAR\_GRID" and "UNSTRUCTURED\_GRID" with "POINT\_DATA" and "CELL\_DATA" are supported.

To load the content of a VTK file, use the function `LoadVTK`:

```julia
julia> vtk = LoadVTK("path/to/file.vtk");
```

This will load the VTK file in a custom object deppending on the VTK file geometry/topology. When working with files with "STRUCTURED\_POINTS", the load function will create
a `StructuredPoints` object that contains all the information in the file in it's fields and print to `stdout` a summary of the data. The `vtk.pointData` and `vtk.cellData` fields will contain all of the datasets in the file. Accesing `m.pointData` (or `m.cellData`) will return an array with shape `(ndata,nx,ny,nz)` where `ndata = SCALARS+3*VECTORS` (the number of SCALARS datasets plus 3 times the number of VECTORS datasets, one for each component of the vector) and nx, ny and nz the number of points in each axis. Using the example file `StructuredPointsExample.vtk` we get:

```julia
julia> vtk = LoadVTK("VTK_examples/StructuredPointsExample.vtk");
Title: output from Diable
Dimensions: Int32[50, 50, 50]
Spacing: [0.04, 0.04, 0.04]
Origin: [-1.0, -1.0, -1.0]
Name of cell datasets: ["Nothing"]
Cell data types: ["Nothing"]
Name of point datasets: ["Density", "Pressure", "Velocity"]
Point data types: ["SCALARS", "SCALARS", "VECTORS"]

julia> vtk.pointData.size
(5, 50, 50, 50)

julia> vtk.pointDataAttributes
3-element Vector{String}:
 "SCALARS"
 "SCALARS"
 "VECTORS"

julia> vtk.dimensions
3-element Vector{Int32}:
 50
 50
 50
```

To retrieve a dataset from `m.pointData` you can index like with any array or with the dataset name directly from the `StructuredPoints` object:

```julia
julia> vtk.pointData[1,:,:,:] == vtk["Density"]
true
```
You can index by dataset name any of the 4 `VTKDataSet` objects. To print the general info showed when loading the file:

```julia
julia> show(vtk)
Title: output from Diable
Dimensions: Int32[50, 50, 50]
Spacing: [0.04, 0.04, 0.04]
Origin: [-1.0, -1.0, -1.0]
Name of cell datasets: ["Nothing"]
Cell data types: ["Nothing"]
Name of point datasets: ["Density", "Pressure", "Velocity"]
Point data types: ["SCALARS", "SCALARS", "VECTORS"]
```

If the file(s) topology is "UNSTRUCTURED\_GRID", the load function will create an `UnstructuredGrid` object. Since this type of file can contain any type of [dataset attribute format](https://docs.vtk.org/en/latest/design_documents/VTKFileFormats.html) without any type of regular structure, data will be stored in a field for each dataset attribute format (currently only supporting "POINT\_DATA" and "CELL\_DATA"). For example loading the file `UnstructuredGridExample.vtk` we get:

```julia
julia> vtk = LoadVTK("VTK_examples/UnstructuredGridExample.vtk");
Title: Output from Walicxe3D
Number of Cells: 36864
Name of cell datasets: ["rho", "velx", "vely", "velz", "P"]
Cell data types: ["SCALARS", "VECTORS", "SCALARS"]
Number of Points: 294912
Name of point datasets: ["Nothing"]
Point data types: ["Nothing"]
```

Since this file only contains "CELL_DATA" `vtk.pointData` will return `nothing` but `vtk.cellData` will return the array with the datasets:

```julia
julia> vtk.pointData == nothing
true

julia> vtk.cellData
5×36864 Matrix{AbstractFloat}:
 98.009      155.998      …      50001.6      50002.7
   ⋮                     ⋱                       ⋮
  1.60406f6    1.47006f6  …       9623.2       9651.74
```
