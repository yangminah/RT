include("RT.jl")
using PyPlot

#### Fixed values
seed=89
Random.seed!(seed);
ω = intRT(3);         #sum to 0 for resonance.
C = floatRT(5);       #sum to 0 for conservation of energy
IC = onUnitCircle(3); #Start with complex values on unit circle.
R = collect(4:5);     #Ranges being tested: 5*10 .^(R) gives final time, 10 .^(-R) gives ϵ.
test="R45_"

#### "True" solution done with RK4, h=1e-5. 
for i in R
	name=test*"true"*string(i)
	T = 5*exp10(i); ϵ=exp10(-i); h=exp10(-5)
	N = Int(ceil(T/h)); 
	every = Int(ceil(N/100)) #only save 101 values total
	RT_amp(N, h, every, IC, ω=ω, ϵ=ϵ, C=C, stepper=RK4_step, name=name);	
end

h = exp10(-3); #fixed!
#### Methods being tested with fixed h=1e-3
steppers = [IFE_step, ETD1_step, CNimex_step]
colors = ["r","b","g"]
ss = length(steppers)
for i in R, j = 1 : ss
	name=test*string(steppers[j])*string(i)
	T = 5*exp10(i); ϵ=exp10(-i); 
	N = Int(ceil(T/h)); 
	every = Int(ceil(N/100))
	RT_amp(N, h, every, IC, ω=ω, ϵ=ϵ, C=C, stepper=steppers[j], name=name);		
end

####Plot errors on log y-scale
for k = 1 : 3
	for i in R
		T = 5*exp10(i); x = range(0, T, length=101)
		tsol = readdlm(test*"true"*string(i)*".txt")
		subplot(100+length(R)*10+i-1)
		for j = 1 : ss
			name=test*string(steppers[j])*string(i)
			semilogy(x, abs.(tsol[:,k]-readdlm(name*".txt")[:,k]),
				c=colors[j], label=name)
		end
		legend()
	end
	savefig(test*"seed"*string(seed)*"-errz"*string(k)*".png")
	close()
end

####Plot amplitudes for all methods (including "true" solution) separately. 
steppers = [IFE_step, ETD1_step, CNimex_step,:true]
colors = ["r","b","g","k"]
ss = length(steppers)
for k = 1 : 3
	for i in R
		T = 5*exp10(i); x = range(0, T, length=101)
		tsol = readdlm(test*"true"*string(i)*".txt")
		print(100+length(R)*10+i-1, "\n")
		subplot(100+length(R)*10+i-1)
		for j = 1 : ss
			name=test*string(steppers[j])*string(i)
			plot(x, readdlm(name*".txt")[:,k],c=colors[j], label=name)
		end
		legend()
	end
	savefig(test*"seed"*string(seed)*"-z"*string(k)*".png")
	close()
end

#### Plot each method separately.
for i in R
	T = exp10(i); x = range(0, T, length=101)
	for j = 1 : ss
		name=test*string(steppers[j])*string(i)
		plot(x, readdlm(name*".txt"),c=colors[j], label=name)
		legend()
		savefig("everything"*string(i)*string(steppers[j])*".png")
		close()
	end
end
