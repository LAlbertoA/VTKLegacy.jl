using VTKLegacy
using Test

@testset "VTKLegacy.jl" begin
    m = LoadVTK("../VTK_examples/StructuredPointsExample.vtk");
    um = LoadVTK("../VTK_examples/UnstructuredGridExample.vtk");
    @test typeof(m) == StructuredPoints
    @test size(m.data) == (count(x->x=="VECTORS",m.dataAttributes)*3+count(x->x=="SCALARS",m.dataAttributes), m.nx, m.ny, m.nz)
    @test length(unique(m.dataAttributes)) == 2

    @test typeof(um) == UnstructuredGrid
    @test size(um.cellData) == (length(um.cellDataNames), um.ncells)
    @test count(x->x=="VECTORS",um.cellDataAttributes)*3+count(x->x=="SCALARS",um.cellDataAttributes) == length(um.cellDataNames)
end
