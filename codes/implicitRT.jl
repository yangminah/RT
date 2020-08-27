using DifferentialEquations, PyPlot
include("RT.jl")

struct RTparams
	ω::Vector{Float64}
    ϵ::Float64
    C::Vector{Float64}
    RTparams(ω,ϵ,C) = new(copy(ω), copy(ϵ), copy(C))
end
#=
function RTtend!(dz:: Vector{ComplexF64}, z::Vector{ComplexF64}, p::RTparams, t)
	#dz = deepcopy(z);
	for i = 1 : 3
		dz[i] = p.C[i]*prod(conj.(z[1:end .!=i]))
	end
	dz = p.ϵ*dz + im*p.ω.*z
end=#
#function RTtend!(dz:: Vector{Float64}, z::Vector{Float64}, p::RTparams, t)
function RTtend!(dz, z, p, t)
	#dz = deepcopy(z);
	dz[1] = p.C[1]*(z[2]*z[3]-z[5]*z[6]);
	dz[4] = p.C[1]*(-z[2]*z[6]-z[3]*z[5]);
	dz[2] = p.C[2]*(z[1]*z[3]-z[4]*z[6]);
	dz[5] = p.C[2]*(-z[1]*z[6]-z[3]*z[4]);
	dz[3] = p.C[3]*(z[1]*z[2]-z[4]*z[5]);
	dz[6] = p.C[3]*(-z[1]*z[5]-z[2]*z[4]);
	#dz = p.ϵ*dz + im*p.ω.*z
	dz = p.ϵ*dz + vcat(-p.ω.*z[4:6],p.ω.*z[1:3]);
end

function reshapetomat(u::Vector{Vector{Float64}})
	newu = zeros(ComplexF64,length(u),3)
	newmag = zeros(Float64, length(u),3)
	for i = 1 : length(u)
		newu[i,1] = u[i][1]+im*u[i][4];
		newu[i,2] = u[i][2]+im*u[i][5];
		newu[i,3] = u[i][3]+im*u[i][6];
		newmag[i,1] = abs(newu[i,1]);
		newmag[i,2] = abs(newu[i,2]);
		newmag[i,3] = abs(newu[i,3]);
	end
	return newu, newmag
end

seed=1205
Random.seed!(seed);
ϵ = 0.01;             # Nonlinear scale
ω = [-1, 3, -2];      # "slow" wave numbers
C = floatRT(5);       # Energy conserving constants
IC = onUnitCircle(3)  # Initial condition
IC = vcat(real.(IC), imag.(IC));
p = RTparams(ω,ϵ,C);
T = 1000;
tspan = (0., T);
dz = deepcopy(IC);
prob = ODEProblem(RTtend!, IC, tspan, p);

#alg = ImplicitEuler();
alg = ImplicitMidpoint();
#alg = RadauIIA3();
#alg = RadauIIA5();
#alg = PDIRK44();
dt = 0.05
strideI = Int(1/dt);
sol=solve(prob,alg,dt=dt)

#scatter(1:length(sol.t)-1, sol.t[2:end]-sol.t[1:end-1] .- 0.05)
complexsol, absvalsol = reshapetomat(sol.u);
fig,ax=subplots()
plot(sol.t[1:strideI:end], absvalsol[1:strideI:end,1],label="z1")
plot(sol.t[1:strideI:end], absvalsol[1:strideI:end,2],label="z2")
plot(sol.t[1:strideI:end], absvalsol[1:strideI:end,3],label="z3")
title("Implicit Midpoint Rule")
legend()

alg = PDIRK44();
sol=solve(prob,alg,dt=dt)
#scatter(1:length(sol.t)-1, sol.t[2:end]-sol.t[1:end-1] .- 0.05)
complexsol, absvalsol = reshapetomat(sol.u);
fig,ax=subplots()
plot(sol.t[1:strideI:end], absvalsol[1:strideI:end,1],label="z1")
plot(sol.t[1:strideI:end], absvalsol[1:strideI:end,2],label="z2")
plot(sol.t[1:strideI:end], absvalsol[1:strideI:end,3],label="z3")
title("PDIRK44: 2 processor 4th order diagonally non-adaptive implicit method")
legend()