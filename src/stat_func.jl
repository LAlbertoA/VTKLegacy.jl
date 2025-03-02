"""
    integrate(m::StructuredPoints,var::Union{Int64,String,Vector{Union{Int64,String}}}=1)

Compute the discrete integral of `var` in the whole mesh `m` as: 

```math
I = \\sum_{(i,j,k)=(1,1,1)}^{N_x,N_y,N_z}\\text{var}_{(i,j,k)}\\Delta x\\Delta y\\Delta z.
```

If `var` is unspecified, integrate only the dataset with index 1 in `m.data`
"""
function integrate(m::StructuredPoints,var::Union{IntOrStr,Vector{IntOrStr}}=1)
    (nx, ny, nz) = m.dimensions
    (dx, dy, dz) = m.spacing
    prs = []
    d = Dict(map(reverse,collect(m.dictionary)))
    if typeof(var) == Vector{IntOrStr} || typeof(var) == Vector{Int64} || typeof(var) == Vector{String}
        for p in eachindex(var)
            if typeof(var[p]) == Int64
                push!(prs,var[p])
            else
                push!(prs,m.dictionary[var[p]])
            end
            sum = 0
            for i in 1:nx
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
        for i in 1:nx
            for j in 1:ny
                for k in 1:nz
                    sum = sum + m.data[prs[1],i,j,k]*dx*dy*dz
                end
            end
        end
        println(d[prs[1]], " ", sum)
    end
end
"""
    ranges(m::StructuredPoints,io::Union{IOStream,Nothing}=nothing)

Obtain the maximum and minimum values of each dataset in `m` and print them to `io` followed by a newline.

If `io` is unspecified, prints the values to the default output stream `stdout`.
"""
function ranges(m::StructuredPoints,io::Union{IOStream,Nothing}=nothing)
    ndata = length(m.data[:,1,1,1])
    if isnothing(io)
        for i in 1:ndata
            @views mx = maximum(m.data[i,:,:,:])
            @views mn = minimum(m.data[i,:,:,:])
            println("$(m.dataNames[i]): Max = ", mx, ", Min = ", mn)
        end
    else
        for i in 1:ndata
            @views mx = maximum(m.data[i,:,:,:])
            @views mn = minimum(m.data[i,:,:,:])
            println(io,"$(m.dataNames[i]): Max = ", mx, ", Min = ", mn)
        end
    end
end

"""
    magnitude(m::StructuredPoints,dataname::String)

Returns the magnitude of a dataset in `m` with name `dataname` and attribute Vector.
"""
function magnitude(m::StructuredPoints,vector::String)
    magarr = zeros(m.nx,m.ny,m.nz)
    rng = m.dictionary[vector]
    for i in 1:m.nx
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

"""
    magnitude(arr::Array{AbstractFloat,4})

Returns the magnitude of a vector dataset of size (axis,nx,ny,nz) where `axis` is 3 (\"x\", \"y\" and \"z\" dimensions) and nx, ny and nz are the number of cells in each axis.
"""
function magnitude(arr::Array{Float64,4})
    sz = arr.size
    magarr = zeros(sz[2],sz[3],sz[4])
    for i in 1:sz[2]
        for j in 1:sz[3]
            for k in 1:sz[4]
                sum = 0
                for n in 1:sz[1]
                    sum = sum + arr[n,i,j,k]^2
                end
                magarr[i,j,k] = sqrt(sum)
            end
        end
    end
    return magarr
end

"""
    magnitude(arr::Array{AbstractFloat,3})

Returns the magnitude of a vector dataset of size (axis,nx,ny) where `axis` is 3 (\"x\", \"y\" and \"z\" dimensions) and nx and ny are the number of cells in each axis.
"""
function magnitude(arr::Array{Float64,3})
    sz = arr.size
    magarr = zeros(sz[2],sz[3])
    for i in 1:sz[2]
        for j in 1:sz[3]
            sum = 0
            for n in 1:sz[1]
                sum = sum + arr[n,i,j]^2
            end
            magarr[i,j] = sqrt(sum)
        end
    end
    return magarr
end