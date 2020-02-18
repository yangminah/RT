using PyPlot, DelimitedFiles, LinearAlgebra

# Numerical Simulation Parameters
N = 2^13;
k = vcat(collect(0:N/2), collect(-N/2+1:-1)); # implies domain length is 2π
kind = vcat(collect(Int(N/2)+2:N), collect(1:Int(N/2)+1));
kindnz = vcat(collect(Int(N/2)+2:N), collect(2:Int(N/2))); # indexing w/o zero mode

hdict = Dict{String, Float64}();
mdict = Dict{String, String}();
cdict = Dict{String, Symbol}();
mds = ["IFRK3" "ETDRK3" "ARK3" "ARK4"]
cs = [:red; :orange; :green; :blue]
hs = [0.06 0.05 0.025 0.01 0.005 0.0025 0.001 0.0005 0.00025 0.0001 0.000075 0.00005]
for (i,m) in enumerate(mds)
    for h in hs
        push!(hdict, m*"-"*string(Int(h*1000000),pad=6) => h)
        push!(mdict, m*"-"*string(Int(h*1000000),pad=6) => m)
        push!(cdict, m*"-"*string(Int(h*1000000),pad=6) => cs[i])
    end
end

ddict=Dict{String, Int64}();
cs2 = [:purple, :pink, :grey]
hs2 = [0.06 0.05 0.025 0.01 0.005 0.0025 0.001 0.0005 0.00025 0.0001 0.000075 0.00005]
ds = [4 6 8]
for h in hs
    for (i,d) in enumerate(ds)
        push!(hdict, "IFRK3R-"*string(Int(h*1000000),pad=6)*"-d"*string(d) => h)
        push!(mdict, "IFRK3R-"*string(Int(h*1000000),pad=6)*"-d"*string(d) => "IFRK3R")
        push!(cdict, "IFRK3R-"*string(Int(h*1000000),pad=6)*"-d"*string(d) => cs2[i])
        push!(ddict, "IFRK3R-"*string(Int(h*1000000),pad=6)*"-d"*string(d) => ds[i])        
    end
end

IFlist = ["IFRK3-060000", "IFRK3-050000","IFRK3-025000", "IFRK3-010000",
"IFRK3-005000","IFRK3-002500", "IFRK3-001000", "IFRK3-000500",
"IFRK3-000250", "IFRK3-000100"];
ETDlist = ["ETDRK3-002500","ETDRK3-001000", "ETDRK3-000500", "ETDRK3-000250", 
"ETDRK3-000100"];
ARK3list = ["ARK3-025000", "ARK3-010000", "ARK3-005000","ARK3-002500", 
"ARK3-001000", "ARK3-001000", "ARK3-000500", "ARK3-000250",
"ARK3-000100", "ARK3-000075", "ARK3-000050"];
ARK4list = ["ARK4-060000", "ARK4-050000", "ARK4-025000", "ARK4-010000", 
"ARK4-005000", "ARK4-002500", "ARK4-001000", "ARK4-000500", 
"ARK4-000250", "ARK4-000100"];
IFr4list = ["IFRK3R-060000-d4", "IFRK3R-050000-d4", "IFRK3R-025000-d4", "IFRK3R-010000-d4",
"IFRK3R-005000-d4", "IFRK3R-002500-d4", "IFRK3R-001000-d4", "IFRK3R-000500-d4"];
IFr6list = ["IFRK3R-060000-d6", "IFRK3R-050000-d6", "IFRK3R-025000-d6", "IFRK3R-010000-d6",
"IFRK3R-005000-d6", "IFRK3R-002500-d6", "IFRK3R-001000-d6", "IFRK3R-000500-d6"];
IFr8list = ["IFRK3R-060000-d8", "IFRK3R-050000-d8", "IFRK3R-025000-d8", "IFRK3R-010000-d8",
"IFRK3R-005000-d8", "IFRK3R-002500-d8", "IFRK3R-001000-d8", "IFRK3R-000500-d8"];

listn = vcat(ETDlist, ARK3list, ARK4list, IFr8list, IFr6list, IFlist, IFr4list);

function saveerror(k, listn::Vector{String}, tru::String, nt::T, rel::Bool=true) where T<:Real
    k = k[2:Int(end/2)];
    truth= log.(readdlm("../txtfiles/"*tru*".txt")' ./ k);
    edict = Dict{String, Float64}();
    for (i, na) in enumerate(listn)
        E = log.(readdlm("../txtfiles/"*na*".txt")' ./ k);
        if rel == true
            push!(edict, na => norm(truth-E,nt)/norm(truth,nt))
        else
            push!(edict, na => norm(truth-E,nt))
        end
    end
    return edict
end
IFdict = saveerror(k, IFlist, "IFRK3-001000",2);
ETDdict = saveerror(k, ETDlist, "IFRK3-001000",2);
ARK3dict = saveerror(k, ARK3list, "IFRK3-001000",2);
ARK4dict = saveerror(k, ARK4list, "IFRK3-001000",2);
IFr4dict = saveerror(k, IFr4list, "IFRK3-001000",2);
IFr6dict = saveerror(k, IFr6list, "IFRK3-001000",2);
IFr8dict = saveerror(k, IFr8list, "IFRK3-001000",2);

function plotErrvH!(k, name::Vector{String}, hdict, mdict;#, m::Int, n::Int
    tru::String="IFRK3-000100")  
    k = k[2:Int(end/2)]
    truth=log.(readdlm("../txtfiles/"*tru*".txt")' ./ k)
    fig, ax = subplots()#(m,n)
    ax.set_xscale("log")
    ax.set_yscale("log")
    ymin=-1
    ymax=-1
    for (i,na) in enumerate(name)
        #subplot(m*100+n*10+i)
        E = log.(readdlm("../txtfiles/"*na*".txt")' ./ k)
        err = norm(truth-E,2)/norm(truth,2)
        print(err,"\n")
        if mdict[na] == "IFRK3R"
            scatter(hdict[na], err, c=cdict[na], s=(ddict[na]-4)*20+20)
        else
            scatter(hdict[na], err, c=cdict[na])
        end
        if i == 1
            ymin = err
            ymax == err
        else
            if ymin > err && na != tru
                ymin = err
            end
            if ymax < err
                ymax = err
            end
        end
        #print(na*": ymin is "*string(ymin)*", and ymax is "*string(ymax)*".\n")
    end 
    for (i,m) in enumerate(mds)
        scatter([], [], c=cs[i], label=m)
    end
    for (i,d) in enumerate(ds)
        scatter([], [], c=cs2[i], label="deg="*string(d), s=(d-4)*20+20)
    end
    ylim(0.5*ymin, ymax*1.5)
    #ylim(5e-3, 10^(0.5))
    xlabel("h: time-step size")
    ylabel("Relative error (2-norm)")
    title("Error in log(Energy Spectrum)")
    legend()
    ax.set_axisbelow(true)
    ax.grid(true)
    # Turn on the minor TICKS, which are required for the minor GRID
    ax.minorticks_on()

    # Customize the major grid
    ax.grid(which="major", linestyle="-", linewidth=0.5, color=:red)
    # Customize the minor grid
    ax.grid(which="minor", linestyle=":", linewidth=0.5, 
        color=:black, alpha=0.7)
end

function plotEnergy!(k, name::Vector{String}, m,n,hdict, mdict;#, m::Int, n::Int
    tru::String="IFRK3-025000")
    k = k[2:Int(end/2)]
    truth=readdlm("../txtfiles/"*tru*".txt")' ./ k
    β = truth[65]*64;
    fig, ax = subplots(m,n)
    loglog(k, β ./k, label="1/k+C",c=:black)
    for (i,na) in enumerate(name)
        #subplot(m*100+n*10+i)
        E = readdlm("../txtfiles/"*na*".txt")' ./ k
        err = norm(truth-E,2)/norm(truth,2)
        loglog(k, abs.(β ./k - E))
        #loglog(k, abs.(truth-readdlm("../txtfiles/"*na*".txt")') ./ truth)#, label=na)
        if i > (m-1)*n
            xlabel("Wave Number")
        end
        if mod(i,n)==1
            ylabel("n(k)")
        end
        legend()
        title(na)
    end
    suptitle("Integrating Factor Methods")#mdict(na)*hdict(na))
end

