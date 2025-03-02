"""
    probe(filename::String, save::Bool = false, fig = Figure(); kwarg...)
    probe(SP::StructuredPoints, save::Bool = false, fig = Figure(); kwarg...)

Generate heatmaps of each dataset in the VTK file `filename` at `nz/2`. If there are Vector datasets, plot the magnitude of the Vector array. 
If `save` is unspecified, the figure will show at the default output stream `stdout`. Leaving `fig` unspecified will generate a plot with size (1200,800).

# Keyword arguments

- `image_name::String`: When `save = true` the function will save the plot generated in the same folder `filename` is at.
- `axis_slice::String`: Accepted values are \"x\", \"y\" and \"z\". Default value is \"z\".
- `cell_slice::Int64`: Cell at which the slice is created. If nothing is given, the slice will be generated at the middle of the array in the axis given in `axis_slice`.
- `color_map`: Name of the colormap to use in each plot. Can be one name (e.g. `:inferno`) or a vector of names (e.g. `[:jet,:inferno]`). If a vector of names is given \
then the number of elements in `color_map` must be equal to the number of plots to generate. Default `:viridis`
- `color_range`: Maximum and minimum values of each plot given as a vector. If multiple values are given (e.g. `[[0,10],[2,9]]`) the number of elements in `color_range` \
must be equal to the number of plots to generate.
- `color_scale`: The color transform function of each plot. Defaults to `identity`.
"""
function probe(fp::Union{String,StructuredPoints}, sv::Bool = false, fig = Figure(size = (1200,800)); image_name::String = "probe.png", axis_slice::String ="z", cell_slice::Union{Int64,Nothing} = nothing, 
    color_map::Union{Symbol,Vector{Symbol}} = :viridis, color_range = Makie.automatic, color_scale = Makie.identity)
    if fp isa String
        m = LoadVTK(fp)
    else
        m = fp
    end
    nplt = length(m.dataAttributes)
    if color_map isa Vector && length(color_map) != nplt
        ArgumentError("The number of elements in color_map should be $nplt")
    elseif !(color_map isa Vector)
        color_map = fill(color_map,nplt)
    end
    if color_range isa Union{Vector{Vector{Int64}},Vector{Vector{Float64}}} && length(color_range) != nplt
        ArgumentError("The number of elements in color_range should be $nplt")
    elseif !(color_range isa Union{Vector{Vector{Int64}},Vector{Vector{Float64}}})
        color_range = fill(color_range,nplt)
    end
    if color_scale isa Vector && length(color_scale) != nplt
        ArgumentError("The number of elements in color_scale should be $nplt")
    elseif !(color_scale isa Vector)
        color_scale = fill(color_scale,nplt)
    end
    sq = sqrt(nplt)
    xmax = ceil(Int64,sq)
    xpos = 1
    ypos = 1
    sl = 0
    for n in 1:nplt
        if axis_slice == "x"
            if isnothing(cell_slice)
                sl = round(Int64,m.nx/2)
            else
                sl = cell_slice
            end
            ax1 = m.y
            ax2 = m.z
            arr = m.data[m.dictionary[m.dataNames[n]],sl,:,:]
        elseif axis_slice == "y"
            if isnothing(cell_slice)
                sl = round(Int64,m.ny/2)
            else
                sl = cell_slice
            end
            ax1 = m.x
            ax2 = m.z
            arr = m.data[m.dictionary[m.dataNames[n]],:,sl,:]
        elseif axis_slice == "z"
            if isnothing(cell_slice)
                sl = round(Int64,m.nz/2)
            else
                sl = cell_slice
            end
            ax1 = m.x
            ax2 = m.y
            arr = m.data[m.dictionary[m.dataNames[n]],:,:,sl]
        else
            ArgumentError("Unrecognized axis \"$(axis_slice)\". Accepted axis_slice values are \"x\", \"y\" and \"z\"")
        end
        if m.dataAttributes[n] == "SCALARS"
            heatmapcb(arr,m.dataNames[n],ax1,ax2,color_map[n],color_range[n],color_scale[n],fig[ypos,xpos])
        elseif m.dataAttributes[n] == "VECTORS"
            heatmapcb(magnitude(arr),m.dataNames[n],ax1,ax2,color_map[n],color_range[n],color_scale[n],fig[ypos,xpos])
        end
        xpos = xpos + 1
        if xpos > xmax
            xpos = 1
            ypos = ypos + 1
        end
    end
    GC.gc()
    fig[0,:] = Label(fig,"Slice in axis $(axis_slice) at $(sl)")
    if sv == false
        return fig
    else
        ind = findlast('/', fp)
        if isnothing(ind)
            save(image_name,fig)
        else
            save(fp[1:ind]*image_name,fig)
        end
    end
end

function heatmapcb(arr,sn::String,xaxis::Vector{Float64},yaxis::Vector{Float64}, cm, cr, cs, f = Figure())
    ax = Axis(f[1,1], xtickformat = "{:.1e}", ytickformat = "{:.1e}")
    hm = heatmap!(ax,xaxis,yaxis,arr, colormap = cm, colorrange = cr, colorscale = cs)
    Colorbar(f[1,2],hm, label = "$(sn)",tickformat = "{:.1e}")
    f
end
