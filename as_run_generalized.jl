using JuMP
#using Cbc
using Gurobi
using SparseArrays
using OffsetArrays
using Plots

T = 125




"""
for i = 2:152
        println(x_val[1,i,2])
end
"""
#println()
#println(x_val)

"""
for i in Components
        println(sum(x_val[s,t,1] for s in J_set("s"), t in J_set("t")))
end
"""
k = 1
T = 50
a = 50:50:700
b = [0.0 0 0 0 0 0 0 0 0 0 0 0 0 0]

include("as_dat_large_generalized.jl")
include("as_mod_generalized.jl")


while T< 710
    println("-------------------------------------------------------", T)
    m, x, z = build_model(true,true)
    set_optimizer(m, Gurobi.Optimizer)
    optimize!(m)

    b[k] = solve_time(m)
    global k = k+1
    global T = T + 50
end


plot(a, log.(b)', legend=:topleft, xlabel = "T", ylabel = "Time(logarithmic)", xtickfontsize=16, xguidefontsize=16, yguidefontsize=16, ytickfontsize=16)

savefig("compute_time_4")
