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
	#using WebIO
	using Blink
	plotlyjs() # Load the plotlyjs backend 
end


# ╔═╡ b0afaa6f-e328-4e51-b61c-8245e225e0ff
html"<button onclick='present()'>present</button>"

# ╔═╡ 956027b4-5f14-11eb-1bce-b34251214616
md"""# How to use Recurrence Quantification Analysis to detect deforestation in Sentinel-1 data

by **Felix Cremer**
"""

# ╔═╡ abe1de9c-5f14-11eb-0eda-eb58e533b723
md"""
## Introduction

In this tutorial we explore how we can use Recurrence Quantification Analysis on every pixel to detect deforestations. Further details of the method and the results can be found in this paper:
[Potential of Recurrence Metrics from Sentinel-1 Time Series for Deforestation Mapping](https://doi.org/10.1109/jstars.2020.3019333)
"""

# ╔═╡ 2f3cc2a0-88e7-4810-99f1-d197ea1da7cf
md"## Load necessary packages"

# ╔═╡ 37e28ce6-6149-11eb-3844-5f1db380b79a
md"## What are Recurrence Plots"

# ╔═╡ 05c7d0b4-6149-11eb-212f-5d35c354540f
x= range(0,40,length=200)

# ╔═╡ 638c7022-614d-11eb-34ed-5f72d2df75fb
md"Threshold for the computation of the recurrence plot:

$(@bind threshold PlutoUI.Slider(0.0:0.1:4, default=0.2, show_value=true))"

# ╔═╡ fba80a56-614d-11eb-2a34-c74887bf33ce
md"## Recurrenceplot of Sentinel-1 data"

# ╔═╡ 2b3746ea-7953-40ee-abcd-642a9e12bc7f
path = "../data/s1cube_hidalgo/"

# ╔═╡ 4bdf7b8e-bd2d-4d28-8b2a-557cdc7aedc2
cube = Cube(path);

# ╔═╡ 4ebc72f0-b8cc-4382-abdf-30a903b37d45
cube |> DisplayAs.Text

# ╔═╡ db337bb9-da29-4fe6-9063-420da3d563ef
begin
	leftup  = (-98.625861,20.619612)
	rightdown= (-98.611149,20.610433)
	lonlims = (leftup[1], rightdown[1])
	latlims = (leftup[2], rightdown[2])
	subcube = cube[lon=lonlims, lat=latlims]
end;

# ╔═╡ a09f4a4d-b50b-4e9c-8837-174c9f490182
subcube |> DisplayAs.Text

# ╔═╡ ad177970-1b80-4b01-ab8e-da82b2295329
missinds = ismissing.(subcube[1,1,:,4]) .* ismissing.(subcube[1,1,:,1])

# ╔═╡ 99c1d142-38ef-4e3c-946a-f3812e2be34e
#timesubcube = YAXArray(subaxes, subcube[:,:,findall(.!missinds),:]);

# ╔═╡ f8bbacdf-ec8a-47a5-a6b6-6ab3ccae7fe8
timesubcube = Cube("../data/s1_hidalgo_deforstation_example.zarr/")

# ╔═╡ 1fba7525-291e-4b26-8161-db276b228072
timesubcube |> DisplayAs.Text

# ╔═╡ d03fd0f0-819d-4380-871c-4b69c671b7bd
begin
	subaxes = copy(caxes(subcube))
	taxis = getAxis("time", subcube)
	subaxes[3] = RangeAxis("time", taxis.values[.!missinds])
end

# ╔═╡ b1d6efa2-ff2e-4649-8038-71dddf7b328e


# ╔═╡ a243e3eb-be3a-4191-8ed8-017146c8e7bf
begin
	forestpath = "../data/hidalgo_forest_2017_2018.shp"
	forestcube = cubefromshape(forestpath, timesubcube, wrap=nothing)
end;

# ╔═╡ e9f14a33-8518-4c3f-98e6-38da99679f52
forestcube |> DisplayAs.Text

# ╔═╡ b77eb106-fc57-4e53-aeb8-77d9524ba862
begin
	deforpath = "../data/hidalgo_change_2017_2018.shp"
	deforcube = cubefromshape(deforpath, timesubcube, wrap=nothing);
end;

# ╔═╡ 7947588b-23d1-49c5-8945-6818120fdf3b
deforcube |> DisplayAs.Text

# ╔═╡ 42d57e34-8eb6-4bc2-acb9-0b9d4052bcdd
ct = CubeTable(ts = timesubcube, include_axes=("time","lat", "lon"), forest=forestcube, defor=deforcube);

# ╔═╡ 56679531-9ce7-471e-a9e6-ca9090ef53ea


# ╔═╡ bca5b386-8a52-44b5-b5c5-c77eacf801a7
timesubcube |> DisplayAs.Text

# ╔═╡ 6553a52c-e88d-42ef-882f-4cd4e60f7fe7


# ╔═╡ 6e5c2b08-0c08-484f-8bf0-374f3cdd1cc8
#plot_ts_rp_many(defortimeseries, fortimeseries)

# ╔═╡ 3c16db45-4f5a-45a7-80cf-a6ed813a562e


# ╔═╡ 910bb753-7467-4ae8-a129-b80ab0c3b05c
#ts1 = harmonize(fortimeseries)

# ╔═╡ 1fa2a0ba-a84b-4d0b-acdc-f7886a18a285
md"""
Threshold for the computation of the Recurrence Plot

$(@bind thresholds1 PlutoUI.Slider(0.0:0.1:4, default=1.5, show_value=true))
"""

# ╔═╡ 7a32d88d-d72f-4ff6-930f-a94a8612946e
begin
orbitnames = ["a" => "Ascending", "d" => "Descending"]
dorb = Dict(orbitnames)
end

# ╔═╡ 1378cb57-1923-4cad-8018-51f91b461488
md"""
Select the polarisation and the orbit for the following analysis: 

$(@bind pol Select(["VV", "VH"]))
$(@bind orbit Select(orbitnames))
"""

# ╔═╡ 077e5e31-71ee-44ef-a7d1-356dac5b9e6a
varval = join(["sentinel1", lowercase(pol), orbit], "_")

# ╔═╡ 5601f6db-1c67-4736-b380-06440415d7d5


# ╔═╡ 48681362-0e92-4a6b-b467-834aebde955f
Dict(orbitnames)

# ╔═╡ d6a90bdb-dfa9-49a8-8ecc-8c3707a0c967
forgeo = let 
	forestsub = cubefromshape(forestpath, subcube; wrap=nothing);
	geo = yaxconvert(GeoArray, forestsub)
	swapdims(geo, (Lon, Lat))
end;

# ╔═╡ cdf64ef4-f583-4486-9fdc-15cbe9ecd4ef
defgeo = let 
	sub = cubefromshape(deforpath, subcube; wrap=nothing);
	geo = yaxconvert(GeoArray, sub)
	swapdims(geo, (Lon, Lat))
end;

# ╔═╡ 72cde1c6-7878-40f2-bb89-8eb9e0aa0965
begin
	plot(defgeo, color="red")
	plot!(forgeo, color="green", legend=nothing)
end

# ╔═╡ 02cba164-ec51-4b9c-8ff3-d4d470d3776f
Show the comparison map maybe with a selection of the polygons or with a few selected aresas. But maybe this is not needed. 

# ╔═╡ 7aa5070b-c95b-479f-b60b-89e71aeb9d50
html"<button onclick='present()'>present</button>"

# ╔═╡ fd921a4d-00a5-4ee8-ae2a-f34528cbcf32
md"""
## 

### Thanks for your attention
"""


# ╔═╡ bf2afd83-beb1-4ec5-9891-fbabd1f9e4ae
md"## Auxillary functions"

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
md"""

$(@bind tsfun Select([string(k) => funcnames[k] for (k, v) in funcs]))



"""

# ╔═╡ 5948cd7a-0040-404f-acc5-707237904924
md"""

 $(varname[tsfun]):

$(@bind phase PlutoUI.Slider(0.0:0.5:4, show_value=true, default=2))


"""

# ╔═╡ 2b9c6c8c-614b-11eb-0076-eb86e0e7cf3d
begin
ts = funcs[tsfun](x,phase);
	plot(x, ts)
end

# ╔═╡ a7dd2a1a-614c-11eb-1a96-796b12fec389
rp1 = RecurrenceMatrix(ts, threshold);

# ╔═╡ ee6ef41c-614d-11eb-0380-5d3a352bcf09
md"
### Recurrence Plot of the time series
$(heatmap(.!rp1.data))"

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
trendsub = mapCube(pixeltrend, subcube[variable=varval], thresholds1; indims=InDims("time"), outdims=OutDims());

# ╔═╡ e7c7bfc1-2c02-4c50-ba7d-c29544f10a19
trendsub |> DisplayAs.Text

# ╔═╡ 4cfc44b4-ba4f-451c-8776-ff15f81000d7
trendgeo = begin 
	geo = yaxconvert(GeoArray, trendsub)
	swapdims(geo, (Lon, Lat))
end

# ╔═╡ 79df7ef9-21a9-44ac-95af-28772fc1422f
plot(trendgeo[Dim{:Variable}(varval)])

# ╔═╡ 99a5879b-1ca5-46b6-b45a-91569762f0a0
	pltrend = plot(trendgeo[Dim{:Variable}(varval)], c=cgrad(:batlow,rev=true),
			title=join([pol, dorb[orbit],  "RQA Trend"], " "))

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
prangesub = mapCube(prange, subcube[variable=varval], 0.05; indims=InDims("time"), outdims=OutDims());

# ╔═╡ a43538a8-08ef-41a5-88eb-db9a1f7b8976
prangegeo = let 
	geo = yaxconvert(GeoArray, prangesub)
	swapdims(geo, (Lon, Lat))
end;

# ╔═╡ 410db013-392c-40e4-aa9a-056986917a63
plot(prangegeo[Dim{:Variable}("something")],c=cgrad(:batlow),
title=join([pol, dorb[orbit],  "Percentile Range"], " "))

# ╔═╡ a0ff7a19-8ee4-427e-960d-1f915e4b786d
function neg2miss!(pix)
    zero_ind = pix .<= 1e-4
    zero_ind[ismissing.(zero_ind)] .=false
    pix[collect(skipmissing(zero_ind))] .=missing
    pix
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

# ╔═╡ cad1a7d6-a616-4751-8651-22fcd4fcd58e
function kram()

    subplot2grid((3,2), (0,1))
	ts2 = harmonize(ts2)
	@show length.(ts2)
	m2 = mean(ts2)
    PyPlot.plot.(ts2, color="grey")
    PyPlot.plot(m2, color="green")
	PyPlot.ylim(ylimit)
	PyPlot.tick_params(labelsize=13)
	PyPlot.title("(b)", fontsize=25)

    for l in vertlines
    	PyPlot.axvline(x=l[1], color="orange",label=l[2])
	PyPlot.text(l[1], 0, l[2], rotation=90)
    end
    rp2s = RecurrenceMatrix.(ts2, Ref(eps2))
    @show typeof(rp2s)
    #@show typeof(grayscale.(rp1s))
    rp2 = sum(grayscale.(rp2s))
    @show size(rp2)
    subplot2grid((3,2), (1,1), rowspan=2)
    PyPlot.imshow(rp2, cmap="binary_r", extent = (1, size(rp2)[1], 1, size(rp2)[2]))
	PyPlot.tick_params(labelsize=13)
	PyPlot.xlabel("timesteps")

	PyPlot.suptitle(plottitle)
end

# ╔═╡ 4fffb92d-e60b-41a6-b603-84203619bef9
getinds(x, i) = findall(isequal.(x.data,i))

# ╔═╡ e24a60a5-d13b-46e6-961f-dfe6c7913586
forinds = getinds(forestcube, 1)

# ╔═╡ d449e225-d6c5-485a-a06c-9465e397ff11
forindssample = sample(forinds, 25, replace=false)

# ╔═╡ f2210a9a-4561-4cc2-80f5-c232d37e48ee
fortimeseries = [collect(skipmissing(neg2miss!(timesubcube[variable=varval][i.I..., :]))) for i in forindssample]

# ╔═╡ 7b43e252-a019-463a-a42c-2f5baa6435e7
definds = getinds(deforcube, 1)

# ╔═╡ 825bca9e-eb8c-4072-8394-854a29bc5e87
defindssample = sample(definds, 25, replace=false)

# ╔═╡ 7bc200c8-fdb1-483d-97f6-5c5c82a1d041
defortimeseries = [collect(skipmissing(neg2miss!(timesubcube[variable=varval][i.I..., :]))) for i in defindssample]

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

# ╔═╡ Cell order:
# ╟─b0afaa6f-e328-4e51-b61c-8245e225e0ff
# ╟─956027b4-5f14-11eb-1bce-b34251214616
# ╠═abe1de9c-5f14-11eb-0eda-eb58e533b723
# ╟─2f3cc2a0-88e7-4810-99f1-d197ea1da7cf
# ╠═cc5b671a-5f14-11eb-07a9-2983f852a373
# ╟─37e28ce6-6149-11eb-3844-5f1db380b79a
# ╟─de319b86-6148-11eb-072b-f3045ea1826c
# ╟─5948cd7a-0040-404f-acc5-707237904924
# ╟─05c7d0b4-6149-11eb-212f-5d35c354540f
# ╟─2b9c6c8c-614b-11eb-0076-eb86e0e7cf3d
# ╟─638c7022-614d-11eb-34ed-5f72d2df75fb
# ╟─a7dd2a1a-614c-11eb-1a96-796b12fec389
# ╠═ee6ef41c-614d-11eb-0380-5d3a352bcf09
# ╟─fba80a56-614d-11eb-2a34-c74887bf33ce
# ╟─2b3746ea-7953-40ee-abcd-642a9e12bc7f
# ╟─4bdf7b8e-bd2d-4d28-8b2a-557cdc7aedc2
# ╟─4ebc72f0-b8cc-4382-abdf-30a903b37d45
# ╠═db337bb9-da29-4fe6-9063-420da3d563ef
# ╟─a09f4a4d-b50b-4e9c-8837-174c9f490182
# ╠═ad177970-1b80-4b01-ab8e-da82b2295329
# ╠═99c1d142-38ef-4e3c-946a-f3812e2be34e
# ╠═1fba7525-291e-4b26-8161-db276b228072
# ╠═f8bbacdf-ec8a-47a5-a6b6-6ab3ccae7fe8
# ╠═d03fd0f0-819d-4380-871c-4b69c671b7bd
# ╠═b1d6efa2-ff2e-4649-8038-71dddf7b328e
# ╠═a243e3eb-be3a-4191-8ed8-017146c8e7bf
# ╠═e9f14a33-8518-4c3f-98e6-38da99679f52
# ╠═b77eb106-fc57-4e53-aeb8-77d9524ba862
# ╟─7947588b-23d1-49c5-8945-6818120fdf3b
# ╠═42d57e34-8eb6-4bc2-acb9-0b9d4052bcdd
# ╠═56679531-9ce7-471e-a9e6-ca9090ef53ea
# ╠═e24a60a5-d13b-46e6-961f-dfe6c7913586
# ╠═7b43e252-a019-463a-a42c-2f5baa6435e7
# ╠═825bca9e-eb8c-4072-8394-854a29bc5e87
# ╠═d449e225-d6c5-485a-a06c-9465e397ff11
# ╠═f2210a9a-4561-4cc2-80f5-c232d37e48ee
# ╠═7bc200c8-fdb1-483d-97f6-5c5c82a1d041
# ╠═bca5b386-8a52-44b5-b5c5-c77eacf801a7
# ╠═6553a52c-e88d-42ef-882f-4cd4e60f7fe7
# ╠═6e5c2b08-0c08-484f-8bf0-374f3cdd1cc8
# ╠═069b6f7a-3c74-40b0-875b-ca7f9e0c2f73
# ╠═3c16db45-4f5a-45a7-80cf-a6ed813a562e
# ╠═910bb753-7467-4ae8-a129-b80ab0c3b05c
# ╠═1fa2a0ba-a84b-4d0b-acdc-f7886a18a285
# ╟─585fc67a-1bcc-4a79-bef3-9e96ef6ced29
# ╠═79df7ef9-21a9-44ac-95af-28772fc1422f
# ╠═72cde1c6-7878-40f2-bb89-8eb9e0aa0965
# ╠═3303f644-5fd6-4111-8e38-09d53c525689
# ╠═e7c7bfc1-2c02-4c50-ba7d-c29544f10a19
# ╠═7bb176c2-64d2-4784-93b1-db35d22749be
# ╟─077e5e31-71ee-44ef-a7d1-356dac5b9e6a
# ╠═4cfc44b4-ba4f-451c-8776-ff15f81000d7
# ╠═1378cb57-1923-4cad-8018-51f91b461488
# ╠═7a32d88d-d72f-4ff6-930f-a94a8612946e
# ╠═5601f6db-1c67-4736-b380-06440415d7d5
# ╠═48681362-0e92-4a6b-b467-834aebde955f
# ╠═410db013-392c-40e4-aa9a-056986917a63
# ╠═99a5879b-1ca5-46b6-b45a-91569762f0a0
# ╠═d6a90bdb-dfa9-49a8-8ecc-8c3707a0c967
# ╠═a43538a8-08ef-41a5-88eb-db9a1f7b8976
# ╠═cdf64ef4-f583-4486-9fdc-15cbe9ecd4ef
# ╠═02cba164-ec51-4b9c-8ff3-d4d470d3776f
# ╟─7aa5070b-c95b-479f-b60b-89e71aeb9d50
# ╟─fd921a4d-00a5-4ee8-ae2a-f34528cbcf32
# ╟─bf2afd83-beb1-4ec5-9891-fbabd1f9e4ae
# ╟─862a1d4a-2284-4f3a-a581-71272e0bb422
# ╟─c9fef127-04bf-459e-8b29-6ff7b5255368
# ╟─cad1a7d6-a616-4751-8651-22fcd4fcd58e
# ╟─a2011593-3226-4c05-9ec3-75a702a126ff
# ╟─b8797b4f-3f66-4c10-9255-87abd8fc21e8
# ╠═e898b7da-57ef-47c9-b3f8-59d0aba0a6cf
# ╟─734a0de4-ebeb-4532-ae95-b035a4ad13d6
# ╟─486d19dc-2e8e-412a-8002-a6b58afb62d4
# ╠═fcf048d8-1e3a-4f9d-ab98-b5aaacdd54ba
# ╠═64461cae-1f68-471f-8a14-249acff1ab3f
# ╠═6904aefc-9d7c-4831-b595-9c45377f1ded
# ╟─a0ff7a19-8ee4-427e-960d-1f915e4b786d
# ╟─69466cd2-8fec-40aa-8a6c-d196407d676e
# ╟─4fffb92d-e60b-41a6-b603-84203619bef9
