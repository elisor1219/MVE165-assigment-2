using JuMP
#using Cbc
using Gurobi
using SparseArrays

T = 100
include("as_dat_large_remaining_life.jl")
include("as_mod_remaining_life.jl")
m, x, z = build_model()
set_optimizer(m, Gurobi.Optimizer)
# set_optimizer_attributes(m, "MIPGap" => 2e-2, "TimeLimit" => 3600)
"""
Some useful parameters for the Gurobi solver:
    SolutionLimit = k : the search is terminated after k feasible solutions has been found
    MIPGap = r : the search is terminated when  | best node - best intgeger | < r * | best node |
    MIPGapAbs = r : the search is terminated when  | best node - best integer | < r
    TimeLimit = t : limits the total time expended to t seconds
    DisplayInterval = t : log lines are printed every t seconds
See http://www.gurobi.com/documentation/8.1/refman/parameters.html for a
complete list of valid parameters
"""


#unset_binary.(x)
#unset_binary.(z)
optimize!(m)
"""
Some useful output & functions
"""
# obj_ip = objective_value(m)
# unset_binary.(x)
# unset_binary.(z)
# optimize!(m)
#obj_lp = objective_value(m)
#println("obj_ip = $obj_ip, obj_lp = $obj_lp, gap = $(obj_ip-obj_lp) ")

# println(solve_time(m))

x_val = sparse(value.(x.data))
z_val = sparse(value.(z))

println("")
println("x  = ")
println(x_val)
println("z = ")
println(z_val)

println("r = $r")

obj = objective_value(m)
println("Objective Value = $obj")


function findLastOne(A)
    #A is a row-vector.
    i = length(A)
    while i >= 1
        if A[i] == 1
            return i
        end
        i = i - 1
    end
end
remaingLife = zeros(Components[end])
for i in Components
    remaingLife[i] = findLastOne(sparse(value.(x.data))[i,:]) + U[i]
end
println("Remaining life after t=T ")
println(remaingLife)

numberOfMaintenaces = zeros(Components[end])
for i in Components
    numberOfMaintenaces[i] = sum(value.(x)[i,t] for t in 1:T)
end

println("Number of maintenance occasions ")
println(numberOfMaintenaces)
