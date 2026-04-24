"""
    integrate(m::StructuredPoints,var::Union{Int64,String,Vector{Union{Int64,String}}}=1; data::Union{Symbol,Nothing}=nothing)

Compute the discrete integral of one or more variables stored in `m.pointData` or `m.cellData` using the following formula:

```math
I = \\sum_{(i,j,k)=(1,1,1)}^{N_x,N_y,N_z}\\text{var}_{(i,j,k)}\\Delta x\\Delta y\\Delta z.
```

Use `data=:point` to integrate fields from `POINT_DATA`.
Use `data=:cell` to integrate fields from `CELL_DATA`.

If `var` is unspecified, and there is only point/cell data available, integrate the first available dataset.
If there is point and cell data available, and `var` is unspecified, throws an error.

The function returns a dictionary with the variable names as keys and their corresponding integrals as values. 
If `var` is a vector of variable names or indices, the returned dictionary will contain an entry for each variable.
Examples
```julia
integrate(m)
integrate(m, "rho")
integrate(m, ["rho", "pressure"])
integrate(m, "rho"; data=:cell)
"""
function integrate(m::StructuredPoints,var::Union{IntOrStr,Vector{<:IntOrStr}}=1;
    data::Union{Symbol,Nothing}=nothing)

    vars = var isa Vector ? var : [var]

    vtkdata, dictionary, data_kind = _select_data_for_integrate(m, vars; data=data)

    if vtkdata === nothing
        error("No $(data_kind)Data available in this StructuredPoints object.")
    end

    dx, dy, dz = m.spacing
    dV = dx * dy * dz

    reverse_dict = Dict(value => key for (key, value) in dictionary)

    results = Dict{String,Any}()

    for v in vars
        idx = v isa String ? dictionary[v] : v

        if idx isa Integer
            integral = sum(@view vtkdata[idx, :, :, :]) * dV
            name = get(reverse_dict, idx, string(idx))

            results[name] = integral

        elseif idx isa AbstractRange
            integral = [sum(@view vtkdata[q, :, :, :]) * dV for q in idx]
            name = get(reverse_dict, idx, string(idx))

            results[name] = integral

        else
            error("Unsupported index type: $(typeof(idx)). Expected Integer or Range.")
        end
    end

    return results
end

"""
    ranges(m::StructuredPoints, io::Union{IO,Nothing}=nothing; data::Symbol=:both)

Print the maximum and minimum values of each dataset in `m`.

Use `data=:point` for POINT_DATA, `data=:cell` for CELL_DATA, or
`data=:both` for both sections.

If `io` is unspecified, prints to `stdout`.
"""
function ranges(m::StructuredPoints,io::Union{IO,Nothing}=nothing;
    data::Symbol=:both)
    out = isnothing(io) ? stdout : io

    if data == :both
        if m.pointData !== nothing
            _ranges_section(m.pointData, m.pointDataNames, m.pointDict, out, "POINT_DATA")
        end

        if m.cellData !== nothing
            _ranges_section(m.cellData, m.cellDataNames, m.cellDict, out, "CELL_DATA")
        end

        return nothing

    elseif data == :point
        if m.pointData === nothing
            error("No POINT_DATA available in this StructuredPoints object.")
        end

        _ranges_section(m.pointData, m.pointDataNames, m.pointDict, out, "POINT_DATA")
        return nothing

    elseif data == :cell
        if m.cellData === nothing
            error("No CELL_DATA available in this StructuredPoints object.")
        end

        _ranges_section(m.cellData, m.cellDataNames, m.cellDict, out, "CELL_DATA")
        return nothing

    else
        error("Invalid value for keyword `data`. Use `data=:point`, `data=:cell`, or `data=:both`.")
    end
end

"""
    magnitude(m::StructuredPoints, vector::String; data::Union{Symbol,Nothing}=nothing)

Returns the magnitude of a vector dataset in `m`.

If `data` is unspecified, the function tries to find `vector` automatically
in `pointData` or `cellData`. If the same name exists in both sections, use
`data=:point` or `data=:cell`.
"""
function magnitude(m::StructuredPoints,vector::String;
    data::Union{Symbol,Nothing}=nothing)

    vtkdata, dictionary, data_kind = _select_data_for_magnitude(m, vector; data=data)

    if vtkdata === nothing
        error("No $(data_kind)Data available in this StructuredPoints object.")
    end

    rng = dictionary[vector]

    if !(rng isa AbstractRange)
        error("Dataset `$vector` is not a vector dataset. Its index is `$rng`, not a range.")
    end

    nx, ny, nz = size(vtkdata, 2), size(vtkdata, 3), size(vtkdata, 4)

    magarr = zeros(Float64,nx,ny,nz)

    for i in 1:nx
        for j in 1:ny
            for k in 1:nz
                s = 0.0
                for n in rng
                    s += vtkdata[n,i,j,k]^2
                end
                magarr[i,j,k] = sqrt(s)
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

#Little helper functions to select data for functions in these file

function _select_data_for_integrate(m::StructuredPoints,vars::Vector;
    data::Union{Symbol,Nothing}=nothing)

    if data == :point
        return m.pointData, m.pointDict, :point
    elseif data == :cell
        return m.cellData, m.cellDict, :cell
    elseif data !== nothing
        error("Invalid value for keyword `data`. Use `data=:point` or `data=:cell`.")
    end

    if any(v -> v isa Integer, vars)
        error("Please specify `data=:point` or `data=:cell` when using integer indices.")
    end

    in_point = [haskey(m.pointDict, v) for v in vars]
    in_cell  = [haskey(m.cellDict, v) for v in vars]

    if all(in_point) && !any(in_cell)
        return m.pointData, m.pointDict, :point
    elseif all(in_cell) && !any(in_point)
        return m.cellData, m.cellDict, :cell
    elseif any(in_point .& in_cell)
        repeated = vars[in_point .& in_cell]
        error("Variable(s) $(repeated) exist in both pointData and cellData. Specify `data=:point` or `data=:cell`.")
    elseif any(in_point) && any(in_cell)
        error("Requested variables are split between pointData and cellData. Call `integrate` separately for each data type.")
    else
        error("Variable(s) $(vars) were not found in pointData or cellData.")
    end
end

function _select_data_for_magnitude(m::StructuredPoints,name::String;
    data::Union{Symbol,Nothing}=nothing)

    if data == :point
        return m.pointData, m.pointDict, :point
    elseif data == :cell
        return m.cellData, m.cellDict, :cell
    elseif data !== nothing
        error("Invalid value for keyword `data`. Use `data=:point` or `data=:cell`.")
    end

    in_point = haskey(m.pointDict, name)
    in_cell  = haskey(m.cellDict, name)

    if in_point && !in_cell
        return m.pointData, m.pointDict, :point
    elseif in_cell && !in_point
        return m.cellData, m.cellDict, :cell
    elseif in_point && in_cell
        error("Dataset `$name` exists in both pointData and cellData. Specify `data=:point` or `data=:cell`.")
    else
        error("Dataset `$name` was not found in pointData or cellData.")
    end
end

function _ranges_section(vtkdata::Array{Float64,4},names::Vector{String},dictionary::Dict{String,IntOrRng},io::IO,label::String)
    for name in names
        idx = dictionary[name]

        if idx isa Integer
            @views mx = maximum(vtkdata[idx,:,:,:])
            @views mn = minimum(vtkdata[idx,:,:,:])

            println(io, "$label $name: Max = ", mx, ", Min = ", mn)

        elseif idx isa AbstractRange
            @views mx = maximum(vtkdata[idx,:,:,:])
            @views mn = minimum(vtkdata[idx,:,:,:])

            println(io, "$label $name: Max = ", mx, ", Min = ", mn)

        else
            error("Unsupported index type for dataset `$name`: $(typeof(idx)). Expected Integer or Range.")
        end
    end

    return nothing
end