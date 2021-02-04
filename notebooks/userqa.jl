### A Pluto.jl notebook ###
# v0.12.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ cc5b671a-5f14-11eb-07a9-2983f852a373
begin 
	using ESDL
md"We are using the Earth System Data Lab (ESDL) to analyse the data"
end


# ╔═╡ e04ab276-5f14-11eb-0673-0d41040235b0
begin 
	using RecurrenceAnalysis
md"The RecurrenceAnalysis package provides the computation of the recurrence quantification analysis and the computation of the recurrence plots."
end

# ╔═╡ 00a44ba4-5f15-11eb-2406-0114243261e4
begin 
	using Makie
	md"We are using the Makie package to plot the data"
end

# ╔═╡ 4e96d508-6149-11eb-3339-b547760ba1fd
begin 
	using PlutoUI
	md"The PlutoUI package provides user interface elements like sliders and drop down menus"
end

# ╔═╡ 956027b4-5f14-11eb-1bce-b34251214616
md"# How to use Recurrence Quantification Analysis to detect deforestation in Sentinel-1 data"

# ╔═╡ abe1de9c-5f14-11eb-0eda-eb58e533b723
md"In this tutorial we explore how we can use Recurrence Quantification Analysis on every pixel to detect deforestations"

# ╔═╡ c4dbb706-5f14-11eb-253d-9786a9a88ce2
md"First we need to load the relevant packages to work with."

# ╔═╡ 37e28ce6-6149-11eb-3844-5f1db380b79a
md"## Exemplary timeseries"

# ╔═╡ ce4961b8-6148-11eb-0d2b-5f513fbc3924
md"First we are plotting examplary time series to understand the idea of a recurrence plot and what we can see in them."


# ╔═╡ de319b86-6148-11eb-072b-f3045ea1826c
md"X is the underlying data which we are going to transform based on different functions"

# ╔═╡ 05c7d0b4-6149-11eb-212f-5d35c354540f
x = range(0,100,length=10000)

# ╔═╡ 204c08c6-6149-11eb-1514-a145e0e3d219
md"
First we look at the sum of two different sine functions"

# ╔═╡ 263224c0-6156-11eb-0f67-3fd682a21be1
md"Select a threshold value for the recurrence plot generation"

# ╔═╡ 638c7022-614d-11eb-34ed-5f72d2df75fb
@bind threshold PlutoUI.Slider(0.0:0.1:4, default=0.2, show_value=true)

# ╔═╡ 4076a7d0-6149-11eb-1fab-5dc82edd411a
@bind phase PlutoUI.Slider(0.0:0.5:4, show_value=true, default=2)

# ╔═╡ 2b9c6c8c-614b-11eb-0076-eb86e0e7cf3d
ts1 = sin.(x) .+ sin.(phase .*x)

# ╔═╡ a489b848-614b-11eb-1e1a-971105ef9bcc
lines(x, ts1)

# ╔═╡ a7dd2a1a-614c-11eb-1a96-796b12fec389
rp1 = RecurrenceMatrix(ts1, threshold);

# ╔═╡ ee6ef41c-614d-11eb-0380-5d3a352bcf09
heatmap(collect(rp1.data))

# ╔═╡ fba80a56-614d-11eb-2a34-c74887bf33ce
a = collect(rp1.data)

# ╔═╡ Cell order:
# ╠═956027b4-5f14-11eb-1bce-b34251214616
# ╠═abe1de9c-5f14-11eb-0eda-eb58e533b723
# ╠═c4dbb706-5f14-11eb-253d-9786a9a88ce2
# ╠═cc5b671a-5f14-11eb-07a9-2983f852a373
# ╠═e04ab276-5f14-11eb-0673-0d41040235b0
# ╠═00a44ba4-5f15-11eb-2406-0114243261e4
# ╠═4e96d508-6149-11eb-3339-b547760ba1fd
# ╟─37e28ce6-6149-11eb-3844-5f1db380b79a
# ╠═ce4961b8-6148-11eb-0d2b-5f513fbc3924
# ╠═de319b86-6148-11eb-072b-f3045ea1826c
# ╠═05c7d0b4-6149-11eb-212f-5d35c354540f
# ╠═204c08c6-6149-11eb-1514-a145e0e3d219
# ╠═2b9c6c8c-614b-11eb-0076-eb86e0e7cf3d
# ╠═a489b848-614b-11eb-1e1a-971105ef9bcc
# ╟─263224c0-6156-11eb-0f67-3fd682a21be1
# ╠═638c7022-614d-11eb-34ed-5f72d2df75fb
# ╠═a7dd2a1a-614c-11eb-1a96-796b12fec389
# ╠═4076a7d0-6149-11eb-1fab-5dc82edd411a
# ╠═ee6ef41c-614d-11eb-0380-5d3a352bcf09
# ╠═fba80a56-614d-11eb-2a34-c74887bf33ce
