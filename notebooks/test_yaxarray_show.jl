### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 465db3e0-54c2-11eb-2813-b3b17c127256
using ESDL


# ╔═╡ 1707f218-54c5-11eb-2797-21099d2c4bb1
using Pluto

# ╔═╡ ba4590fc-54c2-11eb-3e95-79031fc4619b
cube = Cube("../data/s1cube_hidalgo/")

# ╔═╡ f0c67a38-54c2-11eb-2a73-53610a47b202


# ╔═╡ c8d5a2e4-54cd-11eb-1993-3791c6b5065c
outtype, mime = Pluto.PlutoRunner.show_richest(IOContext(Base.DevNull()) , cube)

# ╔═╡ 8e0f477a-54cd-11eb-2826-d1d9d268e586
Pluto.PlutoRunner.pluto_showable(MIME("application/vnd.pluto.table+object"), cube)

# ╔═╡ 0a5fa28e-54ce-11eb-0930-312484103ea4
cube

# ╔═╡ de76c31e-54d2-11eb-34cf-7590b446fe18
methods(PlutoRunner.pluto_showable)

# ╔═╡ Cell order:
# ╠═465db3e0-54c2-11eb-2813-b3b17c127256
# ╠═1707f218-54c5-11eb-2797-21099d2c4bb1
# ╠═ba4590fc-54c2-11eb-3e95-79031fc4619b
# ╠═f0c67a38-54c2-11eb-2a73-53610a47b202
# ╠═c8d5a2e4-54cd-11eb-1993-3791c6b5065c
# ╠═8e0f477a-54cd-11eb-2826-d1d9d268e586
# ╠═0a5fa28e-54ce-11eb-0930-312484103ea4
# ╠═de76c31e-54d2-11eb-34cf-7590b446fe18
