#using AbstractPlotting
using GLMakie
using RecurrenceAnalysis
using Distributions: Normal
using ESDL

ts1fun(x, freq) = sin.(x) .+ sin.(freq .* x)

trendfun(x, slope) = sin.(x) .+ slope .* x .* 0.025

function stepfun(x, m)
    ts2 = zero(x)
    ts2[1:div(end,2)] .= rand.(Normal(m,1))
    ts2[div(end,2):end] .= rand.(Normal(0,1))
    ts2 
end

function plot_rp_example()
    x = range(0,100,length=1000)

    fig = Figure(resolution= (1200,900))
    funcs = Dict(:sumsin => ts1fun, :trend=> trendfun, :step => stepfun)
    funcsymlist = [:sumsin, :trend, :step]
    funcsym  = Node{Any}(funcsymlist[1])
    menu = Menu(fig[3,2], options = zip(["Sum of two sines", "Sine with a trend", "Noisy step function"], funcsymlist), tellheight=false)
    freqsliderlabel = Dict(:sumsin =>"Frequency of second sine", :trend =>"Slope of the trend", :step => "Mean of the second part")
    @show freqsliderlabel
    @show menu.selection
    ls = labelslider!(fig,"Parameter of the time series", 0:0.2:4, sliderkw=Dict(:startvalue =>2))
    fig[1,1:2] = ls.layout

    thresh = labelslider!(fig, "Threshold for the computation of the RP", [(0:0.1:2)..., (2.5:0.3:3.5)...],sliderkw=Dict(:startvalue =>0.2))
    fig[2,1:2] = thresh.layout


tsplot = Axis(fig[3,1])
rpplot = Axis(fig[4,1])

rpplot.aspect=1
tsplot.aspect = 1
linkxaxes!(tsplot, rpplot)
hidexdecorations!(tsplot)

on(menu.selection) do s
    funcsym[] = s
    ts1 = lift(ls.slider.value) do freq
       #@show funcsym
        funcs[funcsym[]](x,freq)

    end
    set_close_to!(ls.slider, 2)
    on(ts1) do s
        limits!(tsplot, 1,1000,minimum(ts1[]), maximum(ts1[]))
    end
    rp1 = @lift(collect(RecurrenceMatrix($(ts1), $(thresh.slider.value)).data))
    lines!(tsplot, ts1)
    heatmap!(rpplot, rp1, colormap=Reverse(:gray1), aspect=1)
    #tr = @lift(trend($rp1))
    #trlabel = Label(fig[4,2], "RQA TREND is $(tr[])", tellheight=false)

    #on(tr) do t
    #    delete!(trlabel)
    #trlabel = Label(fig[4,2], "RQA TREND is $t", tellheight=false)
    #end
    
end
menu.is_open=true

return fig
end

scene = plot_rp_example()
#display(scene)

function plot_rps_forestry(defdata, fordata)
    fig = Figure(resolution=(1200,900))

    thresh = labelslider!(fig, "Threshold for the computation of the RP", [(0:0.1:2)..., (2.5:0.3:3.5)...],sliderkw=Dict(:startvalue =>0.2))

    fig[1,1:2] = thresh.layout
    defmean = mean(defdata)
    deftimes = lines(fig[2,1], defmean, color=:red)
    lines!.(Ref(fig[2,1]), defdata, color=:grey)
    lines!(fig[2,1], defmean, color=:red)
    formean = mean(fordata)
    fortimes = lines(fig[2,2], formean, color=:green)
    lines!.(Ref(fig[2,2]), fordata, color=:grey)
    lines!(fig[2,2], formean, color=:green)

    defrpplot  = Axis(fig[3,1])
    forrpplot = fig[3,2]
    rpsdef = [lift(collect(Recurrencematrix(def, $(thresh.slider.value))) for def in defdata]

    rpsdef = @lift(collect.(getproperty.(RecurrenceMatrix.(defdata, $(thresh.slider.value)), :data)))
    for rp in rpsdef
        heatmap!(defrpplot, rp, colormap=Reverse(:gray1), aspect=1)
    end
    return fig
end


fig = plot_rps_forestry(dB.(def_metric), dB.(for_metric))



function menuexample()
    fig = Figure(resolution = (1200, 900))

menu = Menu(fig, options = [:viridis, :heat, :blues])

funcs = [sqrt, x->x^2, sin, cos]

menu2 = Menu(fig, options = zip(["Square Root", "Square", "Sine", "Cosine"], funcs))

fig[1, 1] = vgrid!(
    Label(fig, "Colormap", width = nothing),
    menu,
    Label(fig, "Function", width = nothing),
    menu2;
    tellheight = false, width = 200)

ax = Axis(fig[1, 2])

func = Node{Any}(funcs[1])

ys = @lift($func.(0:0.3:10))
scat = scatter!(ax, ys, markersize = 10px, color = ys)

cb = Colorbar(fig[1, 3], scat, width = 30)

on(menu.selection) do s
    scat.colormap = s
end

on(menu2.selection) do s
    func[] = s
    autolimits!(ax)
end

menu2.is_open = true
fig
end

#fig2 = menuexample()


# Other functions
#ts3 = sin.(x) .+ 0.03 .*x
#ts2 = zero(x)
#ts2[1:div(end,2)] .= rand.(Normal(3,1))
#ts2[div(end,2):end] .= rand.(Normal(0,1))

