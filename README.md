# VTKLegacy

[![Build Status](https://github.com/LAlbertoA/VTKLegacy.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LAlbertoA/VTKLegacy.jl/actions/workflows/CI.yml?query=branch%3Amain)

VTKLegacy is a Julia package that allows you to read in data from VTK files writen in Legacy format. To read data from VTK XML files [ReadVTK.jl](https://github.com/JuliaVTK/ReadVTK.jl) is the way to go.

*Note: VTKLegacy is under development and originally designed to read VTK files produced by [Walicxe3D](https://github.com/meithan/walicxe3d), [Guacho](https://github.com/esquivas/guacho) and [Tlaloque]().
Currently only supporting reading data stored as cells and points, but community contributions to improve this package are welcome!*

## Usage

First, install and load package as any other:
```julia
import Pkg; Pkg.add("VTKLegacy")
using VTKLegacy
```
Then load a VTK file by using the `LoadVTK` function
```julia
vtk = LoadVTK("path/to/file.vtk")
```
This will create a `StructuredPoints` or `UnstructuredGrid` object that contains all the information and datasets of the file.
Also it will print general information of the file to the default output stream:

```julia
julia> vtk = LoadVTK("VTK_examples/StructuredPointsExample.vtk");
Title: output from Diable
Dimensions: Int32[50, 50, 50]
Spacing: [0.04, 0.04, 0.04]
Origin: [-1.0, -1.0, -1.0]
Name of the data: ["Density", "Pressure", "Velocity"]
Data type: ["SCALARS", "SCALARS", "VECTORS"]
```

To acces the data from a vtk file with STRUCTURED_POINTS, you can index the `data` field of the `StructuredPoints` object with the index number or the data name of the dataset you want:

```julia
julia> vtk.data[1,:,:,:]
50×50×50 Array{AbstractFloat, 3}:
[:, :, 1] =
 0.147356  0.158636  …  0.158553  0.147354
 ⋮                  ⋱                  ⋮
 0.147354  0.158548  …  0.158462  0.147353
;;; …
[:, :, 50] =
 0.147354  0.158548  …  0.158462  0.147353
 ⋮                  ⋱                  ⋮
 0.147353  0.158452  …  0.158379  0.147362

 julia> vtk["Density"]
50×50×50 Array{AbstractFloat, 3}:
[:, :, 1] =
 0.147356  0.158636  …  0.158553  0.147354
 ⋮                  ⋱                  ⋮
 0.147354  0.158548  …  0.158462  0.147353
;;; …
[:, :, 50] =
 0.147354  0.158548  …  0.158462  0.147353
 ⋮                  ⋱                  ⋮
 0.147353  0.158452  …  0.158379  0.147362
```

The number of cells in each direction, size of each cell and origin of the grid can be obtained through the fields `vtk.dimensions`, `vtk.spacing` and `vtk.origin`:

```julia
julia> vtk.dimensions
3-element Vector{Int32}:
 50
 50
 50

julia> vtk.spacing
3-element Vector{Float64}:
 0.04
 0.04
 0.04

julia> vtk.origin
3-element Vector{Float64}:
 -1.0
 -1.0
 -1.0
```
The same information shown when loading the file can be shown again using the `show` function by passing the `StructuredPoints` or `UnstructuredGrid` object:

```julia
julia> show(vtk)
Title: output from Diable
Dimensions: Int32[50, 50, 50]
Spacing: [0.04, 0.04, 0.04]
Origin: [-1.0, -1.0, -1.0]
Name of the data: ["Density", "Pressure", "Velocity"]
Data type: ["SCALARS", "SCALARS", "VECTORS"]
```

The latest VTKLegacy documentation can be found on [github pages](https://lalbertoa.github.io/VTKLegacy.jl)