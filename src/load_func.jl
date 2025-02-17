"""
    LoadVTK(filename::String)

Read the VTK file `filename` in to an object of type `Mesh`. Currently only StructuredPoints are supported.
"""
function LoadVTK(fp::String)
    m = Mesh()
    names = String[]
    dtype = String[]
    d = Dict{String,Union{Int64,UnitRange{Int64}}}()
    open(fp) do f
        for i in 1:8
        s = readline(f)
        if i == 5
                s = split(s)
                m.nx = parse(Int32,s[2])
                m.ny = parse(Int32,s[3])
                m.nz = parse(Int32,s[4])
            elseif i == 6
                s = split(s)
                m.x0 = parse(Float64,s[2])
                m.y0 = parse(Float64,s[3])
                m.z0 = parse(Float64,s[4])
            elseif i == 7
                s = split(s)
                m.dx = parse(Float64,s[2])
                m.dy = parse(Float64,s[3])
                m.dz = parse(Float64,s[4])
            end
        end
        m.data = Array{Float64,4}(undef,1,m.nx,m.ny,m.nz)
        s = readline(f)
        s = split(s)
        if s[1] == "SCALARS"
            push!(names, s[2])
            push!(dtype, s[1])
            d[s[2]] = length(names)
            readline(f)
            read!(f,m.data)
        elseif s[1] == "VECTORS"
            push!(names,s[2]*"x")
            push!(names,s[2]*"y")
            push!(names,s[2]*"z")
            push!(dtype, s[1])
            d[s[2]] = length(names)-2:length(names)
            temp = Array{Float64,4}(undef,3,m.nx,m.ny,m.nz)
            read!(f,temp)
            @views m.data = temp[1,:,:,:]
            @views m.data = cat(m.data,temp[2:3,:,:,:],dims=1)
        end
        while ! eof(f)
            s = readline(f)
            s = split(s)
            if length(s)!= 0 && s[1] == "SCALARS"
                push!(names, s[2])
                push!(dtype, s[1])
                d[s[2]] = length(names)
                readline(f)
                temp = Array{Float64,4}(undef,1,m.nx,m.ny,m.nz)
                read!(f,temp)
                m.data = cat(m.data,temp,dims=1)
            elseif length(s)!= 0 && s[1] == "VECTORS"
                push!(names,s[2]*"x")
                push!(names,s[2]*"y")
                push!(names,s[2]*"z")
                push!(dtype, s[1])
                d[s[2]] = length(names)-2:length(names)
                temp = Array{Float64,4}(undef,3,m.nx,m.ny,m.nz)
                read!(f,temp)
                m.data = cat(m.data,temp,dims=1)
            end
        end
    end
    m.data = ntoh.(m.data)
    m.dimensions = [m.nx,m.ny,m.nz]
    m.spacing = [m.dx,m.dy,m.dz]
    m.origin = [m.x0,m.y0,m.z0]
    m.datanames = names
    m.dataattribute = dtype
    m.dictionary = d
    m.x = m.x0.+collect(1:m.nx).*m.dx.-m.dx/2
    m.y = m.y0.+collect(1:m.ny).*m.dy.-m.dy/2
    m.z = m.z0.+collect(1:m.nz).*m.dz.-m.dz/2
    println("Dimensions: $(m.dimensions)")
    println("Spacing: $(m.spacing)")
    println("Origin: $(m.origin)")
    println("Name of the data: $(m.datanames)")
    println("Data type: $(m.dataattribute)")
    return m
end
