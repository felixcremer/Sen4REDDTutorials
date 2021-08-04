### A Pluto.jl notebook ###
# v0.15.1

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
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
	using Revise
	using ESDL # Handling of the datacubes
	using Plots # Plotting of the data
	using RecurrenceAnalysis # Computation of the recurrence plots
	using PlutoUI # Gives you sliders for Pluto
	using Distributions: Normal #Handles the probability distribution
	using DisplayAs # Enable nice show methods for cubes in Pluto
	using StatsBase: sample
	using Statistics
	using GeoData
	using YAXArrayBase
	using HypertextLiteral
	plotlyjs() # Load the plotlyjs backend 
	md" Load the necessary packages for the notebook"
end

# ╔═╡ 956027b4-5f14-11eb-1bce-b34251214616
md"""# How to use Recurrence Quantification Analysis to detect deforestation in Sentinel-1 data

by **Felix Cremer**
"""

# ╔═╡ 37e28ce6-6149-11eb-3844-5f1db380b79a
md"## What are Recurrence Plots"

# ╔═╡ 05a869c7-caf8-4059-9125-10beee96d138
md"
## Recurrence Plot of the time series"

# ╔═╡ f80d16cf-28eb-4414-b3a3-1daf7f841b98
md"## Recurrence Rate metric"

# ╔═╡ c3998137-4810-4a1a-bf8d-a5c12cb667b0
md"## RQA Trend Metric"

# ╔═╡ fba80a56-614d-11eb-2a34-c74887bf33ce
md"## Recurrenceplot of Sentinel-1 data"

# ╔═╡ f8bbacdf-ec8a-47a5-a6b6-6ab3ccae7fe8
cube = Cube("../data/s1_hidalgo_deforstation_example.zarr/");

# ╔═╡ b77eb106-fc57-4e53-aeb8-77d9524ba862
begin
	forestpath = "../data/hidalgo_forest_2017_2018.shp"
	forestcube = cubefromshape(forestpath, cube, wrap=nothing)
	deforpath = "../data/hidalgo_change_2017_2018.shp"
	deforcube = cubefromshape(deforpath, cube, wrap=nothing);
	cube |> DisplayAs.Text
end

# ╔═╡ 280d193b-4439-4d90-bafb-834ad70a273b
md"## Visual Comparison Reference Data"

# ╔═╡ 7a32d88d-d72f-4ff6-930f-a94a8612946e
begin
orbitnames = ["a" => "Ascending", "d" => "Descending"]
dorb = Dict(orbitnames)
polorbselect = 	md"""
Select the polarisation and the orbit for the analysis: 

$(@bind pol Select(["VV", "VH"]))
$(@bind orbit Select(orbitnames))
"""
end

# ╔═╡ 216c4c11-5eec-40e2-b0bc-abac71fd8a4e
md"## Visual Comparison Percentile Range"

# ╔═╡ d3e0e52c-401f-4d20-9a4c-50802d63622d
polorbselect

# ╔═╡ 6cde6711-0c79-4d69-97d3-2978e6667bbe
md"## Visual Comparison RQA Trend"

# ╔═╡ 46fc5c3d-ba39-4029-aad1-436024fd13e9
polorbselect

# ╔═╡ fd921a4d-00a5-4ee8-ae2a-f34528cbcf32
md"""
# Thanks for your attention
"""


# ╔═╡ bf2afd83-beb1-4ec5-9891-fbabd1f9e4ae
md"## Auxillary functions"

# ╔═╡ 1fa2a0ba-a84b-4d0b-acdc-f7886a18a285
s1slider = md"""
Threshold S1: $(@bind thresholds1 PlutoUI.Slider(0.0:0.1:4, default=1.5, show_value=true))
"""

# ╔═╡ ea27711c-5063-40d3-8f9f-fd3b81280867
s1slider

# ╔═╡ fb0d1d25-d031-4fe1-bbd1-d2716f073d88
s1slider

# ╔═╡ edd605fe-f6e8-4589-877b-a4a183750331
s1slider

# ╔═╡ 077e5e31-71ee-44ef-a7d1-356dac5b9e6a
varval = join(["sentinel1", lowercase(pol), orbit], "_")

# ╔═╡ 862a1d4a-2284-4f3a-a581-71272e0bb422
funcnames = Dict("sumsin"=>"Sum of two sines", "trend"=>"Sine with overlaid trend", "step"=>"Step function with noise")

# ╔═╡ b8797b4f-3f66-4c10-9255-87abd8fc21e8
varname = Dict("sumsin" => "Phase difference", "trend"=> "Slope of the trend", "step" => "Mean of the first step")

# ╔═╡ e898b7da-57ef-47c9-b3f8-59d0aba0a6cf
trendfun(x, slope) = sin.(x) .+ slope .* x .* 0.02

# ╔═╡ 734a0de4-ebeb-4532-ae95-b035a4ad13d6
ts1fun(x, freq) = sin.(x) .+ sin.(freq .* x)


# ╔═╡ 486d19dc-2e8e-412a-8002-a6b58afb62d4
function stepfun(x, m)
    ts2 = zero(x)
    ts2[1:div(end,2)] .= rand.(Normal(m,1))
    ts2[div(end,2):end] .= rand.(Normal(0,1))
    ts2 
end

# ╔═╡ a2011593-3226-4c05-9ec3-75a702a126ff
funcs = Dict("sumsin" => ts1fun, "trend"=> trendfun, "step" => stepfun)

# ╔═╡ de319b86-6148-11eb-072b-f3045ea1826c
begin 
	x= range(0,40,length=200)
	md"""

$(funselect = @bind tsfun Select([string(k) => funcnames[k] for (k, v) in funcs]))
"""
end

# ╔═╡ cf93a4e6-40cc-4b74-af61-711c181d2fdf
md"""
$(funselect)
"""

# ╔═╡ 6c3d7dfa-71e8-45cc-9dbf-3b0be24865d5
funselect

# ╔═╡ 80ed25a3-f09f-4af9-bbd9-8aa7c852e156
funselect

# ╔═╡ 638c7022-614d-11eb-34ed-5f72d2df75fb
begin 
	thresholds = 0.0:0.1:5
	threshslider = md"Threshold:
$(threshslider = @bind threshold PlutoUI.Slider(thresholds, default=0.2, show_value=true))"
	phaseslider = md"""

 $(varname[tsfun]): $(@bind phase PlutoUI.Slider(0.0:0.5:4, show_value=true, default=2))
"""
	"Slider definitions"
end

# ╔═╡ 2b9c6c8c-614b-11eb-0076-eb86e0e7cf3d
begin
ts = funcs[tsfun](x,phase);
	plot(x, ts)
end

# ╔═╡ b5c2b607-27ce-4ec6-9858-dd31d9e5dda1
phaseslider

# ╔═╡ ee6ef41c-614d-11eb-0380-5d3a352bcf09
begin 
	rp1 = RecurrenceMatrix(ts, threshold);
	heatmap(.!rp1.data, xticks=false, yticks=false,ylabel="Time stamp", xlabel = "Time stamp")
end

# ╔═╡ 48aea51e-22a9-4fa8-8a31-69a876864835
threshslider

# ╔═╡ 2de634f9-de91-4d48-813e-482905d53187
phaseslider

# ╔═╡ ce98b516-ab29-450d-bc48-7fe8ced85a0d
plot(thresholds, recurrencerate.(Ref(ts), thresholds), xlabel="Threshold", ylabel="Recurrence Rate", label=join([funcnames[tsfun], phase], " "))


# ╔═╡ 18adcf18-b14d-45f4-bb14-0899d39ba54d
phaseslider

# ╔═╡ 3b123cca-f6aa-4a4d-a4de-6915e4bb8b79
plot(thresholds, trend.(Ref(ts), thresholds), xlabel="Threshold", ylabel="RQA Trend", label=join([funcnames[tsfun], phase], " "))

# ╔═╡ 6eed8319-2e05-4f8a-a0fe-c427a4987d19
phaseslider

# ╔═╡ 6904aefc-9d7c-4831-b595-9c45377f1ded
begin
	"""
		dB(x)
	Convert x into the logarithmic dB scale
	"""
	dB(x) = 10 * log10(x)
	dB(x::AbstractArray) = dB.(x)
end

# ╔═╡ c9fef127-04bf-459e-8b29-6ff7b5255368
function makerpplot(timeseriesvec, eps;ylabel="timesteps")

    rps = RecurrenceMatrix.(dB(timeseriesvec), Ref(eps))
    #@show typeof(grayscale.(rp1s))
    rpsum = sum(grayscale.(rps))

	rpplot = heatmap(25 .- rotl90(rpsum), c=colormap("Grays"))
	plot!(rpplot; xlabel="timesteps",ylabel)
	return rpplot
end

# ╔═╡ fcf048d8-1e3a-4f9d-ab98-b5aaacdd54ba
"""
	pixeltrend(pix_trend, pix, dist)
Compute the pixeltrend for the time series `pix` based on the threshold dist.
The results is saved in pix_trend.
This function is for the usage as a user defined function in the ESDL Cube mapCube function
"""
function pixeltrend(pix_trend, pix, dist)
      zero_ind = pix .<=0
      zero_ind[ismissing.(zero_ind)] .=false
      pix[collect(skipmissing(zero_ind))] .= missing
      ts = dB(collect(skipmissing(pix)))
   rp = RecurrenceMatrix(ts, dist)
   pix_trend .= trend(rp)
end

# ╔═╡ 3303f644-5fd6-4111-8e38-09d53c525689
trendsub = mapCube(pixeltrend, cube[variable=varval], thresholds1; indims=InDims("time"), outdims=OutDims());

# ╔═╡ 64461cae-1f68-471f-8a14-249acff1ab3f
function prange(pix_prange, pix,threshold)
    zero_ind = pix .<= 0
    zero_ind .+= isnan.(pix)
    zero_ind[ismissing.(zero_ind)] .=false
   # @show length(pix), length(zero_ind)
    pix[collect(skipmissing(zero_ind))] .= missing
    ts = dB(collect(skipmissing(pix)))
    #@show ts
    if any(isnan.(ts))
      #@show ts
      #@show findall(isnan, ts)
   end
   if size(ts,1) == 0
       return missing
   end
   q5, q95 = quantile(ts, [threshold, 1-threshold])
    pix_prange .=q95 - q5
end

# ╔═╡ 7bb176c2-64d2-4784-93b1-db35d22749be
prangesub = mapCube(prange, cube[variable=varval], 0.05; indims=InDims("time"), outdims=OutDims());

# ╔═╡ d6a90bdb-dfa9-49a8-8ecc-8c3707a0c967
begin
	forgeo = let 
		forestsub = cubefromshape(forestpath, cube; wrap=nothing);
		geo = yaxconvert(GeoArray, forestsub)
		swapdims(geo, (Lon, Lat))
	end;
	trendgeo = let 
		geo = yaxconvert(GeoArray, trendsub)
		swapdims(geo, (Lon, Lat))
	end;
	prangegeo = let 
		geo = yaxconvert(GeoArray, prangesub)
		swapdims(geo, (Lon, Lat))
	end;
	defgeo = let 
		sub = cubefromshape(deforpath, cube; wrap=nothing);
		geo = yaxconvert(GeoArray, sub)
		swapdims(geo, (Lon, Lat))
	end;
	md"Convert the YAXArrays into GeoArrays for plotting"
end

# ╔═╡ 72cde1c6-7878-40f2-bb89-8eb9e0aa0965
begin
	plot(defgeo, color="red", legend=false)
	plot!(forgeo, color="green", legend=false, title="Reference area",xlabel="Easting", ylabel="Northing")
end

# ╔═╡ 410db013-392c-40e4-aa9a-056986917a63
plot(prangegeo[Dim{:Variable}("something")],c=cgrad(:batlow),
title=join([pol, dorb[orbit],  "Percentile Range"], " "),xlabel="Easting", ylabel="Northing")

# ╔═╡ 99a5879b-1ca5-46b6-b45a-91569762f0a0
	plot(trendgeo[Dim{:Variable}(varval)], c=cgrad(:batlow,rev=true),
			title=join([pol, dorb[orbit],  "RQA Trend"], " "),xlabel="Easting", ylabel="Northing")

# ╔═╡ a0ff7a19-8ee4-427e-960d-1f915e4b786d
function neg2miss!(pix)
    zero_ind = pix .<= 1e-4
    zero_ind[ismissing.(zero_ind)] .=false
    pix[collect(skipmissing(zero_ind))] .=missing
    pix
end

# ╔═╡ b46ed5d7-1e50-41af-834b-bb4e8a77cf63
begin 
	RecurrenceAnalysis.trend(pixel::AbstractVector, threshold) = trend(RecurrenceMatrix(pixel, threshold))
RecurrenceAnalysis.recurrencerate(pixel::AbstractVector, threshold) = recurrencerate(RecurrenceMatrix(pixel, threshold))
end

# ╔═╡ 69466cd2-8fec-40aa-8a6c-d196407d676e
function harmonize(tsset)
    maxlen = minimum(length.(tsset))
    tsset = getindex.(tsset, Ref(1:maxlen))
end

# ╔═╡ 069b6f7a-3c74-40b0-875b-ca7f9e0c2f73
"""
	plot_ts_rp_many(ts1, ts2, eps1=1, eps2=1;vertlines=[], plottitle="", ylimit=(-20,-10))

plot the vectors of time series as recurrence plots and the time series on top.
"""
function plot_ts(ts1; title="", color=:blue, ylimit=(-20,-10), ylabel="γ⁰ dB")
    #fig = figure(figsize=(12,8))
	ts1 = harmonize(ts1)
    m1 = mean(ts1)
    ts1plot = plot(dB(ts1[1]); color="grey", title, label="")
	for ts in ts1
		plot!(ts1plot, dB(ts), label="",color="grey", ylim=ylimit)
	end   
	plot!(ts1plot, dB(m1), color=color, label="")
	
	plot!(ts1plot;ylabel)
	return ts1plot
end

# ╔═╡ 4fffb92d-e60b-41a6-b603-84203619bef9
getinds(x, i) = findall(isequal.(x.data,i))

# ╔═╡ 56679531-9ce7-471e-a9e6-ca9090ef53ea
begin
	forinds = getinds(forestcube, 1)
	definds = getinds(deforcube, 1)
	defindssample = sample(definds, 25, replace=false)
	forindssample = sample(forinds, 25, replace=false)
	fortimeseries = [collect(skipmissing(neg2miss!(cube[variable=varval][i.I..., :]))) for i in forindssample]
	defortimeseries = [collect(skipmissing(neg2miss!(cube[variable=varval][i.I..., :]))) for i in defindssample]
end

# ╔═╡ 585fc67a-1bcc-4a79-bef3-9e96ef6ced29
begin
	lay = @layout [a b;c d];
	ylim = (dB(min(minimum.(fortimeseries)...,minimum.(defortimeseries)...)),
	dB(max(maximum.(fortimeseries)...,maximum.(defortimeseries)...)))
	fortsplot = plot_ts(fortimeseries, color=:green, title="Stable Forest", ylimit=ylim)
	defortsplot = plot_ts(defortimeseries, color=:red, title="Deforestation", ylabel="", ylimit=ylim)
	forrpplot = makerpplot(fortimeseries, thresholds1);
	defrpplot = makerpplot(defortimeseries, thresholds1;ylabel="");
plot(fortsplot, defortsplot, forrpplot, defrpplot, layout=lay)
end

# ╔═╡ 9e5e8469-fa65-4667-a0dc-b8b66cf9eda5
PresentationSwitch(text="Present") = @htl("""
<div>
<button>$(text)</button>

<script>

	// Select elements relative to `currentScript`
	var div = currentScript.parentElement
	var button = div.querySelector("button")

	// we wrapped the button in a `div` to hide its default behaviour from Pluto

	var count = false

	button.addEventListener("click", (e) => {
		count = count != true
		present()
		// we dispatch the input event on the div, not the button, because 
		// Pluto's `@bind` mechanism listens for events on the **first element** in the
		// HTML output. In our case, that's the div.

		div.value = count
		div.dispatchEvent(new CustomEvent("input"))
		e.preventDefault()
	})

	// Set the initial value
	div.value = count

</script>
</div>
""")

# ╔═╡ b0afaa6f-e328-4e51-b61c-8245e225e0ff
@bind presentation PresentationSwitch()

# ╔═╡ abe1de9c-5f14-11eb-0eda-eb58e533b723
let
	if presentation
md"""
## Introduction 
- Use RQA for Sentinel-1 data
- [Potential of Recurrence Metrics from Sentinel-1 Time Series for Deforestation Mapping](https://doi.org/10.1109/jstars.2020.3019333)
	"""
	else	
md"""
## Introduction

In this tutorial we explore how we can use Recurrence Quantification Analysis on every pixel to detect deforestations. Further details of the method and the results can be found in this paper:
[Potential of Recurrence Metrics from Sentinel-1 Time Series for Deforestation Mapping](https://doi.org/10.1109/jstars.2020.3019333)
"""
	end
end

# ╔═╡ fd6443cd-2506-467d-aebb-f34b1457f50f
if !presentation
md"""
	This is the example time series that we are looking at to get a better feeling for the parameters of the Recurrence Plot generation. Feel free to play around with different functions and different parameters.
	"""
end

# ╔═╡ Cell order:
# ╠═b0afaa6f-e328-4e51-b61c-8245e225e0ff
# ╟─956027b4-5f14-11eb-1bce-b34251214616
# ╟─abe1de9c-5f14-11eb-0eda-eb58e533b723
# ╠═cc5b671a-5f14-11eb-07a9-2983f852a373
# ╟─37e28ce6-6149-11eb-3844-5f1db380b79a
# ╟─2b9c6c8c-614b-11eb-0076-eb86e0e7cf3d
# ╟─de319b86-6148-11eb-072b-f3045ea1826c
# ╟─b5c2b607-27ce-4ec6-9858-dd31d9e5dda1
# ╠═fd6443cd-2506-467d-aebb-f34b1457f50f
# ╟─05a869c7-caf8-4059-9125-10beee96d138
# ╟─ee6ef41c-614d-11eb-0380-5d3a352bcf09
# ╟─cf93a4e6-40cc-4b74-af61-711c181d2fdf
# ╟─48aea51e-22a9-4fa8-8a31-69a876864835
# ╟─2de634f9-de91-4d48-813e-482905d53187
# ╟─f80d16cf-28eb-4414-b3a3-1daf7f841b98
# ╟─ce98b516-ab29-450d-bc48-7fe8ced85a0d
# ╟─6c3d7dfa-71e8-45cc-9dbf-3b0be24865d5
# ╠═18adcf18-b14d-45f4-bb14-0899d39ba54d
# ╟─c3998137-4810-4a1a-bf8d-a5c12cb667b0
# ╟─3b123cca-f6aa-4a4d-a4de-6915e4bb8b79
# ╟─80ed25a3-f09f-4af9-bbd9-8aa7c852e156
# ╠═6eed8319-2e05-4f8a-a0fe-c427a4987d19
# ╟─fba80a56-614d-11eb-2a34-c74887bf33ce
# ╠═f8bbacdf-ec8a-47a5-a6b6-6ab3ccae7fe8
# ╟─b77eb106-fc57-4e53-aeb8-77d9524ba862
# ╟─585fc67a-1bcc-4a79-bef3-9e96ef6ced29
# ╟─ea27711c-5063-40d3-8f9f-fd3b81280867
# ╟─280d193b-4439-4d90-bafb-834ad70a273b
# ╠═72cde1c6-7878-40f2-bb89-8eb9e0aa0965
# ╟─3303f644-5fd6-4111-8e38-09d53c525689
# ╟─7bb176c2-64d2-4784-93b1-db35d22749be
# ╟─7a32d88d-d72f-4ff6-930f-a94a8612946e
# ╟─216c4c11-5eec-40e2-b0bc-abac71fd8a4e
# ╠═410db013-392c-40e4-aa9a-056986917a63
# ╟─d3e0e52c-401f-4d20-9a4c-50802d63622d
# ╟─fb0d1d25-d031-4fe1-bbd1-d2716f073d88
# ╟─6cde6711-0c79-4d69-97d3-2978e6667bbe
# ╟─99a5879b-1ca5-46b6-b45a-91569762f0a0
# ╟─46fc5c3d-ba39-4029-aad1-436024fd13e9
# ╟─edd605fe-f6e8-4589-877b-a4a183750331
# ╟─fd921a4d-00a5-4ee8-ae2a-f34528cbcf32
# ╟─bf2afd83-beb1-4ec5-9891-fbabd1f9e4ae
# ╟─1fa2a0ba-a84b-4d0b-acdc-f7886a18a285
# ╟─d6a90bdb-dfa9-49a8-8ecc-8c3707a0c967
# ╟─077e5e31-71ee-44ef-a7d1-356dac5b9e6a
# ╟─56679531-9ce7-471e-a9e6-ca9090ef53ea
# ╟─069b6f7a-3c74-40b0-875b-ca7f9e0c2f73
# ╟─862a1d4a-2284-4f3a-a581-71272e0bb422
# ╠═c9fef127-04bf-459e-8b29-6ff7b5255368
# ╟─a2011593-3226-4c05-9ec3-75a702a126ff
# ╟─638c7022-614d-11eb-34ed-5f72d2df75fb
# ╟─b8797b4f-3f66-4c10-9255-87abd8fc21e8
# ╠═e898b7da-57ef-47c9-b3f8-59d0aba0a6cf
# ╟─734a0de4-ebeb-4532-ae95-b035a4ad13d6
# ╟─486d19dc-2e8e-412a-8002-a6b58afb62d4
# ╠═fcf048d8-1e3a-4f9d-ab98-b5aaacdd54ba
# ╠═64461cae-1f68-471f-8a14-249acff1ab3f
# ╠═6904aefc-9d7c-4831-b595-9c45377f1ded
# ╠═a0ff7a19-8ee4-427e-960d-1f915e4b786d
# ╠═b46ed5d7-1e50-41af-834b-bb4e8a77cf63
# ╟─69466cd2-8fec-40aa-8a6c-d196407d676e
# ╟─4fffb92d-e60b-41a6-b603-84203619bef9
# ╟─9e5e8469-fa65-4667-a0dc-b8b66cf9eda5
