using VTKLegacy
using Test

@testset "VTKLegacy.jl" begin
    m = LoadVTK("../VTK_examples/StructuredPointsExample.vtk");
    um = LoadVTK("../VTK_examples/UnstructuredGridExample.vtk");
    @test typeof(m) == StructuredPoints
    @test m.data.size == (length(m.dataNames), m.nx, m.ny, m.nz)
    @test length(unique(m.dataAttributes)) == 2
    @test count(x->x=="VECTORS",m.dataAttributes)*3+count(x->x=="SCALARS",m.dataAttributes) == length(m.dataNames)

    @test typeof(um) == UnstructuredGrid
    @test um.cellData.size == (length(um.cellDataNames), um.ncells)
    @test count(x->x=="VECTORS",um.cellDataAttributes)*3+count(x->x=="SCALARS",um.cellDataAttributes) == length(um.cellDataNames)
end
