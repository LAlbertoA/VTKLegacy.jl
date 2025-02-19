"""
    LoadVTK(filename::String)

Read the VTK file `filename` in to an object of type `Mesh`. Currently only StructuredPoints are supported.
"""
function LoadVTK(fp::String)
    open(fp) do f
        title = ""
        for i in 1:4
            s = readline(f)
            if i == 2
                title = s
            elseif i == 4
                sp = split(s)
                if sp[2] == "STRUCTURED_POINTS"
                    m = Mesh()
                    loadSP(f, m, title)
                    return m
                elseif sp[2] == "UNSTRUCTURED_GRID"
                    loadUSG(f, m, title)
                end
            end
        end
    end
end
## Internal function. Only intended to be used inside LoadVTK function
function loadSP(f::IOStream, m::Mesh, title::String)
    m.title = title
    names = String[]
    dtype = String[]
    d = Dict{String,IntOrRng}()
    ## Reading mesh size, spacing and origin
    for i in 1:3
        s = split(readline(f))
        if s[1] == "DIMENSIONS"
            m.nx = parse(Int32,s[2])
            m.ny = parse(Int32,s[3])
            m.nz = parse(Int32,s[4])
        elseif s[1] == "ORIGIN"
            m.x0 = parse(Float64,s[2])
            m.y0 = parse(Float64,s[3])
            m.z0 = parse(Float64,s[4])
        elseif s[1] == "SPACING"
            m.dx = parse(Float64,s[2])
            m.dy = parse(Float64,s[3])
            m.dz = parse(Float64,s[4])
        end
    end
    ## Reading Datasets in VTK file to m.data
    while ! eof(f)
        s = split(readline(f))
        if length(s) != 0 && s[1] == "SCALARS"
            if length(names) == 0
                m.data = Array{dt[s[3]],4}(undef,1,m.nx,m.ny,m.nz)
                readline(f)
                read!(f,m.data)
            else
                temp = Array{dt[s[3]],4}(undef,1,m.nx,m.ny,m.nz)
                readline(f)
                read!(f,temp)
                m.data = cat(m.data,temp,dims=1)
            end
            push!(names, s[2])
            push!(dtype, s[1])
            d[s[2]] = length(names)           
        elseif length(s) != 0 && s[1] == "VECTORS"
            if length(names) == 0
                m.data = Array{dt[s[3]],4}(undef,3,m.nx,m.ny,m.nz)
                read!(f,m.data)
            else
                temp = Array{dt[s[3]],4}(undef,3,m.nx,m.ny,m.nz)
                read!(f,temp)
                m.data = cat(m.data,temp,dims=1)
            end
            push!(names,s[2]*"x")
            d[s[2]*"x"] = length(names)
            push!(names,s[2]*"y")
            d[s[2]*"y"] = length(names)
            push!(names,s[2]*"z")
            d[s[2]*"z"] = length(names)
            push!(dtype, s[1])
            d[s[2]] = length(names)-2:length(names)
        end
    end
    ## Inverting endianess and defining other usefull fields
    m.data = ntoh.(m.data)
    m.dimensions = [m.nx,m.ny,m.nz]
    m.spacing = [m.dx,m.dy,m.dz]
    m.origin = [m.x0,m.y0,m.z0]
    m.dataNames = names
    m.dataAttributes = dtype
    m.dictionary = d
    m.x = m.x0.+collect(1:m.nx).*m.dx.-m.dx/2
    m.y = m.y0.+collect(1:m.ny).*m.dy.-m.dy/2
    m.z = m.z0.+collect(1:m.nz).*m.dz.-m.dz/2
    println("Title: $(m.title)")
    println("Dimensions: $(m.dimensions)")
    println("Spacing: $(m.spacing)")
    println("Origin: $(m.origin)")
    println("Name of the data: $(m.dataNames)")
    println("Data type: $(m.dataAttributes)")
end