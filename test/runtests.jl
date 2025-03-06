using VTKLegacy
using Test

@testset "VTKLegacy.jl" begin
    m = LoadVTK("../VTK_examples/StructuredPointsExample.vtk");
    um = LoadVTK("../VTK_examples/UnstructuredGridExample.vtk");
    @test typeof(m) == StructuredPoints
    @test size(m.pointData) == (count(x->x=="VECTORS",m.pointDataAttributes)*3+count(x->x=="SCALARS",m.pointDataAttributes), m.nx, m.ny, m.nz)
    @test length(unique(m.pointDataAttributes)) == 2

    @test typeof(um) == UnstructuredGrid
    @test size(um.cellData) == (count(x->x=="VECTORS",um.cellDataAttributes)*3+count(x->x=="SCALARS",um.cellDataAttributes), um.ncells)
end
