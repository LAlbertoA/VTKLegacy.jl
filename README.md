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
Also it will print general information of the file.
