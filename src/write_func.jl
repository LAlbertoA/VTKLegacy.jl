"""
    WriteVTK(filename::String, m::VTKDataSet)
Write a VTK file with with name `filename` with the contents of `m`. The file will have 
geometry/topology according with `typeof(m)`.
"""
function WriteVTK(fp::String, m::VTKDataSet)
    open(fp, "w") do f
        write(f, "# vtk DataFile Version 2.0\n")
        write(f, m.title*"\n")
        write(f, "BINARY\n")
        if typeof(m) == StructuredPoints
            write(f, "DATASET STRUCTURED_POINTS\n")
            writeSP(f,m)
        elseif typeof(m) == StructuredGrid
            write(f, "DATASET STRUCTURED_GRID\n")
            writeSG(f,m)
        elseif typeof(m) == RectilinearGrid
            write(f, "DATASET RECTILINEAR_GRID\n")
            writeRG(f,m)
        elseif typeof(m) == UnstructuredGrid
            write(f, "DATASET UNSTRUCTURED_GRID\n")
            writeUSG(f,m)
        end
    end
end
# Internal function to write STRUCTURED_POINTS VTK file
function writeSP(f::IOStream,m::StructuredPoints)
    write(f,"DIMENSIONS "*string(m.nx)*" "*string(m.ny)*" "*string(m.nz)*"\n")
    write(f,"ORIGIN "*string(m.x0)*" "*string(m.y0)*" "*string(m.z0)*"\n")
    write(f,"SPACING "*string(m.dx)*" "*string(m.dy)*" "*string(m.dz)*"\n")
    # Writing point data
    if !isnothing(m.pointData)
        write(f, "POINT_DATA "*string(m.nx*m.ny*m.nz)*"\n")
        for i in eachindex(m.pointDataNames)
            if m.pointDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.pointDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:,:,:]))
                write(f, "\n")
            elseif m.pointDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.pointDataNames[i]*" double\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:,:,:]))
                write(f, "\n")
            end
        end
    end
    # Writing cell data
    if !isnothing(m.cellData)
        write(f, "CELL_DATA "*string((m.nx-1)*(m.ny-1)*(m.nz-1))*"\n")
        for i in eachindex(m.cellDataNames)
            if m.cellDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.cellDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.cellData[m.cellDict[m.cellDataNames[i]],:,:,:]))
                write(f, "\n")
            elseif m.cellDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.cellDataNames[i]*" double\n")
                write(f, hton(m.cellData[m.cellDict[m.cellDataNames[i]],:,:,:]))
                write(f, "\n")
            end
        end
    end
end
# Internal function to write STRUCTURED_GRID VTK file
function writeSG(f::IOStream,m::StructuredGrid)
    write(f,"DIMENSIONS "*string(m.nx)*" "*string(m.ny)*" "*string(m.nz)*"\n")
    write(f,"POINTS "*string(m.npoints)*" double\n")
    write(f, hton.(m.points))
    write(f, "\n")
    # Writing point data
    if !isnothing(m.pointData)
        write(f, "POINT_DATA "*string(m.nx*m.ny*m.nz)*"\n")
        for i in eachindex(m.pointDataNames)
            if m.pointDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.pointDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:,:,:]))
                write(f, "\n")
            elseif m.pointDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.pointDataNames[i]*" double\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:,:,:]))
                write(f, "\n")
            end
        end
    end
    # Writing cell data
    if !isnothing(m.cellData)
        write(f, "CELL_DATA "*string((m.nx-1)*(m.ny-1)*(m.nz-1))*"\n")
        for i in eachindex(m.cellDataNames)
            if m.cellDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.cellDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.cellData[m.cellDict[m.cellDataNames[i]],:,:,:]))
                write(f, "\n")
            elseif m.cellDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.cellDataNames[i]*" double\n")
                write(f, hton(m.cellData[m.cellDict[m.cellDataNames[i]],:,:,:]))
                write(f, "\n")
            end
        end
    end
end
# Internal function to write RECTILINEAR_GRID VTK file
function writeRG(f::IOStream,m::RectilinearGrid)
    write(f,"DIMENSIONS "*string(m.nx)*" "*string(m.ny)*" "*string(m.nz)*"\n")
    write(f,"X_COORDINATES "*string(m.nx)*" double\n")
    write(f, hton.(m.xCoordinates))
    write(f, "\n")
    write(f,"Y_COORDINATES "*string(m.ny)*" double\n")
    write(f, hton.(m.yCoordinates))
    write(f, "\n")
    write(f,"Z_COORDINATES "*string(m.nz)*" double\n")
    write(f, hton.(m.zCoordinates))
    write(f, "\n")
    # Writing point data
    if !isnothing(m.pointData)
        write(f, "POINT_DATA "*string(m.nx*m.ny*m.nz)*"\n")
        for i in eachindex(m.pointDataNames)
            if m.pointDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.pointDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:,:,:]))
                write(f, "\n")
            elseif m.pointDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.pointDataNames[i]*" double\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:,:,:]))
                write(f, "\n")
            end
        end
    end
    # Writing cell data
    if !isnothing(m.cellData)
        write(f, "CELL_DATA "*string((m.nx-1)*(m.ny-1)*(m.nz-1))*"\n")
        for i in eachindex(m.cellDataNames)
            if m.cellDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.cellDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.cellData[m.cellDict[m.cellDataNames[i]],:,:,:]))
                write(f, "\n")
            elseif m.cellDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.cellDataNames[i]*" double\n")
                write(f, hton(m.cellData[m.cellDict[m.cellDataNames[i]],:,:,:]))
                write(f, "\n")
            end
        end
    end
end
# Internal function to write UNSTRUCTURED_GRID VTK file
function writeUSG(f::IOStream,m::UnstructuredGrid)
    write(f,"POINTS "*string(m.npoints)*" double\n")
    write(f, hton.(m.points))
    write(f, "\n")
    write(f,"CELLS "*string(m.ncells)*" "*string(length(m.cells))*"\n")
    write(f, hton.(m.cells))
    write(f, "\n")
    write(f,"CELL_TYPES "*string(m.ncells)*"\n")
    write(f, hton.(m.cellTypes))
    write(f, "\n")
    # Writing point data
    if !isnothing(m.pointData)
        write(f, "POINT_DATA "*string(m.nx*m.ny*m.nz)*"\n")
        for i in eachindex(m.pointDataNames)
            if m.pointDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.pointDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:]))
                write(f, "\n")
            elseif m.pointDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.pointDataNames[i]*" double\n")
                write(f, hton.(m.pointData[m.pointDict[m.pointDataNames[i]],:]))
                write(f, "\n")
            end
        end
    end
    # Writing cell data
    if !isnothing(m.cellData)
        write(f, "CELL_DATA "*string((m.nx-1)*(m.ny-1)*(m.nz-1))*"\n")
        for i in eachindex(m.cellDataNames)
            if m.cellDataAttributes[i] == "SCALARS"
                write(f, "SCALARS "*m.cellDataNames[i]*" double 1\n")
                write(f, "LOOKUP_TABLE default\n")
                write(f, hton.(m.cellData[m.cellDict[m.cellDataNames[i]],:]))
                write(f, "\n")
            elseif m.cellDataAttributes[i] == "VECTORS"
                write(f, "VECTORS "*m.cellDataNames[i]*" double\n")
                write(f, hton(m.cellData[m.cellDict[m.cellDataNames[i]],:]))
                write(f, "\n")
            end
        end
    end
end