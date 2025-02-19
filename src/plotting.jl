"""
    probe(filename::String, save::Bool = false, fig = Figure())

Generate heatmaps of each dataset in the VTK file `filename` at `nz/2`. If there are Vector datasets, plot the magnitude of the Vector array.
"""
function probe(fp::String, sv::Bool = false, fig = Figure(size = (1200,800)))
    m = LoadVTK(fp)
    sq = sqrt(length(m.dataAttributes))
    xmax = ceil(Int64,sq)
    xpos = 1
    ypos = 1
    for n in 1:length(m.dataAttributes)
        if m.dataAttributes[n] == "SCALARS"
            heatmapcb(m.data[m.dictionary[m.datanames[n]],:,:,round(Int64,m.nz/2)],m.datanames[n],m.x,m.y,fig[ypos,xpos])
        elseif m.dataAttributes[n] == "VECTORS"
            heatmapcb(magnitude(m,m.datanames[n][1:end-1])[:,:,round(Int64,m.nz/2)],m.datanames[n][1:end-1],m.x,m.y,fig[ypos,xpos])
        end
        xpos = xpos + 1
        if xpos > xmax
            xpos = 1
            ypos = ypos + 1
        end
    end
    GC.gc()
    if sv == false
        display(fig)
    else
        ind = findlast('/', fp)
        if ind == nothing
            save("probe.png",fig)
        else
            save(fp[1:ind]*"probe.png",fig)
        end
    end
end

function heatmapcb(arr::Array{Float64,2},sn::String,xaxis::Vector{Float64},yaxis::Vector{Float64},f = Figure())
    ax = Axis(f[1,1], xtickformat = "{:.1e}", ytickformat = "{:.1e}")
    hm = heatmap!(ax,xaxis,yaxis,arr)
    cb = Colorbar(f[1,2],hm, label = "$(sn)",tickformat = "{:.1e}")
    f
end
