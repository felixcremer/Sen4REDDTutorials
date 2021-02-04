### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ d6f3a824-54c0-11eb-3c46-a14787b7e9cb
using Makie

# ╔═╡ 465db3e0-54c2-11eb-2813-b3b17c127256
using ESDL

# ╔═╡ b63d1246-54c2-11eb-2d18-27ada42bc46c
using Statistics

# ╔═╡ 1707f218-54c5-11eb-2797-21099d2c4bb1
using DisplayAs

# ╔═╡ 4318b24a-b40f-4e52-af93-d10c5cc293f0


# ╔═╡ ba4590fc-54c2-11eb-3e95-79031fc4619b
cube = Cube("../data/s1cube_hidalgo/");

# ╔═╡ 2a75fa99-cb1d-4f61-b39f-a864eb0ce58b
cube |> DisplayAs.Text

# ╔═╡ 30e44fb4-031f-4cdc-9133-b9823553614a
data = subsetcube(cube, time=(Date(2017,3,1), Date(2019,3,1)));

# ╔═╡ 407343d9-bc88-4301-b122-3b9828261631
data |> DisplayAs.Text

# ╔═╡ 9b412e29-3093-4944-aa73-d345cb0a0bea
begin
smalldata = subsetcube(data, lat=(20.691, 20.690), lon=(-98.68,-98.67)) 
DisplayAs.Text(smalldata)
end

# ╔═╡ 853f9d8b-b41a-4285-8815-244af36c9e89
begin
	dB(x) = 10 * log10(x)
	dB(x::AbstractArray) = dB.(x)
end

# ╔═╡ 312c0ee7-6fda-4df3-b3a1-53408594c4f3
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

# ╔═╡ 298ead86-d57d-4266-92b4-d88cb9f910b8
@time prange_dB = mapCube(prange, data, .05,  indims = InDims("Time"), outdims = OutDims());

# ╔═╡ 6b375410-9590-4ab2-bd9c-ef95ba037899
@timed prange_dB_small = mapCube(prange, smalldata, .05,  indims = InDims("Time"), outdims = OutDims())

# ╔═╡ 29a7b748-16b1-4eb9-a69f-ab4b95e0ff87


function clombscargle(xout, xin, times)
    ind = .!ismissing.(xin)
    ts = collect(nonmissingtype(eltype(xin)), xin[ind])
    x = times[ind]
    if length(ts) < 10
        @show length(ts)
        xout .= missing
        return
    end
    datediff = Date.(x) .- Date(x[1])
    dateint = getproperty.(datediff, :value)
    pl = LombScargle.plan(dateint, ts)
    #@show pl
    pgram = LombScargle.lombscargle(pl)
    lsperiod= findmaxperiod(pgram)
    lspower = findmaxpower(pgram)
    lsnum = LombScargle.M(pgram)
    #@show lsperiod, lspower
    #@show findmaxfreq(pgram), findmaxpower(pgram)
    xout .= [lsnum, lsperiod[1], lspower]
end

# ╔═╡ dfb679bc-5b09-11eb-3525-8f3da9f5b574
Threads.nthreads()

# ╔═╡ Cell order:
# ╠═d6f3a824-54c0-11eb-3c46-a14787b7e9cb
# ╠═465db3e0-54c2-11eb-2813-b3b17c127256
# ╠═b63d1246-54c2-11eb-2d18-27ada42bc46c
# ╠═1707f218-54c5-11eb-2797-21099d2c4bb1
# ╠═4318b24a-b40f-4e52-af93-d10c5cc293f0
# ╠═ba4590fc-54c2-11eb-3e95-79031fc4619b
# ╠═2a75fa99-cb1d-4f61-b39f-a864eb0ce58b
# ╠═30e44fb4-031f-4cdc-9133-b9823553614a
# ╠═407343d9-bc88-4301-b122-3b9828261631
# ╠═312c0ee7-6fda-4df3-b3a1-53408594c4f3
# ╠═298ead86-d57d-4266-92b4-d88cb9f910b8
# ╠═9b412e29-3093-4944-aa73-d345cb0a0bea
# ╠═6b375410-9590-4ab2-bd9c-ef95ba037899
# ╠═853f9d8b-b41a-4285-8815-244af36c9e89
# ╠═29a7b748-16b1-4eb9-a69f-ab4b95e0ff87
# ╠═dfb679bc-5b09-11eb-3525-8f3da9f5b574
