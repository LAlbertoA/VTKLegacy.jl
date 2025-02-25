"""
    probe(filename::String, save::Bool = false, fig = Figure(); kwarg...)

Generate heatmaps of each dataset in the VTK file `filename` at `nz/2`. If there are Vector datasets, plot the magnitude of the Vector array. 
If `save` is unspecified, the figure will show at the default output stream `stdout`. Leaving `fig` unspecified will generate a plot with size (1200,800).

# Keyword arguments

- `image_name::String`: When `save = true` the function will save the plot generated in the same folder `filename` is at.
- `axis_slice::String`: Accepted values are \"x\", \"y\" and \"z\". Default value is \"z\".
- `cell_slice::Int64`: Cell at which the slice is created. If nothing is given, the slice will be generated at the midle of the array in the axis given in `axis_slice`.
"""
function probe(fp::String, sv::Bool = false, fig = Figure(size = (1200,800)); image_name::String = "probe.png", axis_slice::String ="z", cell_slice::Union{Int64,Nothing} = nothing)
    m = LoadVTK(fp)
    sq = sqrt(length(m.dataAttributes))
    xmax = ceil(Int64,sq)
    xpos = 1
    ypos = 1
    sl = 0
    for n in 1:length(m.dataAttributes)
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
            heatmapcb(arr,m.dataNames[n],ax1,ax2,fig[ypos,xpos])
        elseif m.dataAttributes[n] == "VECTORS"
            heatmapcb(magnitude(arr),m.dataNames[n],ax1,ax2,fig[ypos,xpos])
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

function heatmapcb(arr,sn::String,xaxis::Vector{Float64},yaxis::Vector{Float64},f = Figure())
    ax = Axis(f[1,1], xtickformat = "{:.1e}", ytickformat = "{:.1e}")
    hm = heatmap!(ax,xaxis,yaxis,arr)
    Colorbar(f[1,2],hm, label = "$(sn)",tickformat = "{:.1e}")
    f
end
