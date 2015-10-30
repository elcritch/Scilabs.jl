module PyPlotHelpers

using PyCall
@pyimport matplotlib.ticker as ticker

export configure_matplotlib_publication_style, remove_top_right_borders, remove_all_borders, set_max_ticks, hide_plot, cleanup_graph_axis

function configure_matplotlib_publication_style(rc)

    ## NSF Grant Settings
    rc("axes", linewidth=2)                                # but this works

    rc("font", size=18, family="serif", variant="normal", weight="heavy", serif=["Times New Roman"])
    rc("text", color="k")
    rc("axes", facecolor="white", color_cycle="k", labelsize= 16, labelcolor= "k", linewidth= 1, edgecolor="k")

    rc("figure", facecolor="white")
    rc("figure", figsize=(6,4))
    rc("savefig", facecolor="white", edgecolor="white", dpi=300)

    rc("figure.subplot", wspace=0.4)

    rc("xtick.major", pad=5)
    rc("ytick.major", pad=5)

    rc("legend", frameon=true, handlelength=1.5)
    rc("text", usetex=false)

    rc("grid", linestyle="-", color="lightgrey" )
    rc("axes", grid = true)
    rc("axes", labelweight="normal" )
    rc("axes.formatter", use_mathtext=false )

    rc("font", weight="normal")
    rc("xtick", labelsize=15)
    rc("ytick", labelsize=15)
    rc("legend", scatterpoints = 1)

    return;
end

function remove_top_right_borders(ax)
    ax[:spines]["right"][:set_visible](false)
    ax[:spines]["top"][:set_visible](false)
    ax
end

function remove_all_borders(ax)
    ax[:spines]["right"][:set_visible](false)
    ax[:spines]["top"][:set_visible](false)
    ax[:spines]["left"][:set_visible](false)
    ax[:spines]["bottom"][:set_visible](false)
    ax
end

function set_max_ticks(ax)
	
    ax[:yaxis][:set_major_locator](ticker.MaxNLocator(5) )
    ax[:xaxis][:set_major_locator](ticker.MaxNLocator(5) )
    ax
end

function hide_plot(ax)
    ax[:spines]["top"][:set_color]("none")
    ax[:spines]["bottom"][:set_color]("none")
    ax[:spines]["left"][:set_color]("none")
    ax[:spines]["right"][:set_color]("none")
    ax[:tick_params](labelcolor="none", top="off", bottom="off", left="off", right="off")

    ax
end

function cleanup_graph_axis(ax)
    ax |> remove_top_right_borders |> set_max_ticks
end
    

end