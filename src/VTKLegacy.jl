module VTKLegacy

    using LoopVectorization
    using CairoMakie

    """
        Mesh

    Object that contains all the information and datasets from a Legacy VTK file that has been read.

    # Fields
    - `data::Array{Float64,4}`: 4-dimensional array of `Float64` that holds the datasets of the vtk file.
    - `nx::Int32`: Number of cells in the `x` direction.
    - `ny::Int32`: Number of cells in the `y` direction.
    - `nz::Int32`: Number of cells in the `z` direction.
    - `dx::Float64`: Cell size in the `x` direction.
    - `dy::Float64`: Cell size in the `y` direction.
    - `dz::Float64`: Cell size in the `z` direction.
    - `x0::Float64`: Position of origin in the `x` direction.
    - `y0::Float64`: Position of origin in the `y` direction.
    - `z0::Float64`: Position of origin in the `z` direction.
    - `x::Vector{Float64}`: Cell positions in the `x` direction.
    - `y::Vector{Float64}`: Cell positions in the `y` direction.
    - `z::Vector{Float64}`: Cell positions in the `z` direction.
    - `dimensions::Vector{Int64}`: Number of cells in each dimension: `[nx,ny,nz]`.
    - `spacing::Vector{Float64}`: Cell size in each dimension: `[dx,dy,dz]`.
    - `origin::Vector{Float64}`: Origin of the mesh: `[x0,y0,z0]`.
    - `datanames::Vector{String}`: Names of the datasets in the VTK file.
    - `dataattribute::Vector{String}`: Attribute of each dataset in the VTK file.
    - `dictionary::Dict{String,Union{Int64,UnitRange{Int64}}}`: Dictionary with the `datanames` as the `keys` and the indexes of `data` as the `values`. 
    """
    mutable struct Mesh
        data::Array{Float64,4}
        nx::Int32
        ny::Int32
        nz::Int32
        dx::Float64
        dy::Float64
        dz::Float64
        x0::Float64
        y0::Float64
        z0::Float64
        x::Vector{Float64}
        y::Vector{Float64}
        z::Vector{Float64}
        dimensions::Vector{Int64}
        spacing::Vector{Float64}
        origin::Vector{Float64}
        datanames::Vector{String}
        dataattribute::Vector{String}
        dictionary::Dict{String,Union{Int64,UnitRange{Int64}}}
        Mesh() = new()
    end

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
    function heatmapcb(arr::Array{Float64,2},sn::String,xaxis::Vector{Float64},yaxis::Vector{Float64},f = Figure())
        ax = Axis(f[1,1], xtickformat = "{:.1e}", ytickformat = "{:.1e}")
        hm = heatmap!(ax,xaxis,yaxis,arr)
        cb = Colorbar(f[1,2],hm, label = "$(sn)",tickformat = "{:.1e}")
        f
    end
    function Integrate(m::Mesh,var::Union{Int64,String,Vector{Union{Int64,String}},Vector{Int64},Vector{String}}=1)
        (nx, ny, nz) = m.dimensions
        (dx, dy, dz) = m.spacing
        prs = []
        d = Dict(map(reverse,collect(m.dictionary)))
        if typeof(var) == Vector{Union{Int64,String}} || typeof(var) == Vector{Int64} || typeof(var) == Vector{String}
            for p in 1:length(var)
                if typeof(var[p]) == Int64
                    push!(prs,var[p])
                else
                    push!(prs,m.dictionary[var[p]])
                end
                sum = 0
                @turbo for i in 1:nx
                    for j in 1:ny
                        for k in 1:nz
                            sum = sum + m.data[prs[p],i,j,k]*dx*dy*dz
                        end
                    end
                end
                println(d[prs[p]], " ", sum)
            end
        else
            if typeof(var) == String
                push!(prs,m.dictionary[var])
            else
                push!(prs,var)
            end
            sum = 0
            @turbo for i in 1:nx
                for j in 1:ny
                    for k in 1:nz
                        sum = sum + m.data[prs[1],i,j,k]*dx*dy*dz
                    end
                end
            end
            println(d[prs[1]], " ", sum)
        end
    end
    function ranges(m::Mesh,io::Union{IOStream,Nothing}=nothing)
        ndata = length(m.data[:,1,1,1])
        if io == nothing
            for i in 1:ndata
                @views mx = maximum(m.data[i,:,:,:])
                @views mn = minimum(m.data[i,:,:,:])
                println("$(m.datanames[i]): Max = ", mx, ", Min = ", mn)
            end
        else
            for i in 1:ndata
                @views mx = maximum(m.data[i,:,:,:])
                @views mn = minimum(m.data[i,:,:,:])
                println(io,"$(m.datanames[i]): Max = ", mx, ", Min = ", mn)
            end
        end
    end
    function magnitude(m::Mesh,vector::String)
        magarr = zeros(m.nx,m.ny,m.nz)
        rng = m.dictionary[vector]
        @turbo for i in 1:m.nx
            for j in 1:m.ny
                for k in 1:m.nz
                    sum = 0
                    for n in rng
                        sum = sum + m.data[n,i,j,k]^2
                    end
                    magarr[i,j,k] = sqrt(sum)
                end
            end
        end
        return magarr
    end
    function probe(fp::String, fig = Figure(size = (1200,800)))
        m = LoadVTK(fp)
        sq = sqrt(length(m.dataattribute))
        xmax = ceil(Int64,sq)
        ymax = floor(Int64,sq)+floor(Int64,sq-floor(sq) + 0.5)
        xpos = 1
        ypos = 1
        for n in 1:length(m.dataattribute)
            if m.dataattribute[n] == "SCALARS"
                heatmapcb(m.data[m.dictionary[m.datanames[n]],:,:,round(Int64,m.nz/2)],m.datanames[n],m.x,m.y,fig[ypos,xpos])
            elseif m.dataattribute[n] == "VECTORS"
                heatmapcb(magnitude(m,m.datanames[n][1:end-1])[:,:,round(Int64,m.nz/2)],m.datanames[n][1:end-1],m.x,m.y,fig[ypos,xpos])
            end
            xpos = xpos + 1
            if xpos > xmax
                xpos = 1
                ypos = ypos + 1
            end
        end
        GC.gc()
        fig
    end

end
