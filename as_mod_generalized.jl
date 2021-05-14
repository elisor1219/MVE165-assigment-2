"""
  Construct and returns the model of this assignment.
"""
function build_model(relax_x::Bool = false, relax_z::Bool = false)
  #Components - the set of components
  #T - the number of time steps in the model
  #d[1,..,T] - cost of a maintenance occasion
  #c[Components, 1,..,T] - costs of new components
  #U[Components] - lives of new components
  m = Model()
  #if relax_x
  #  @variable(m, x[1:S,1:(T-S),Components] >= 0)
  #else
  #  @variable(m, x[1:S,1:(T-S),Components] >= 0, Bin)
  #end
  if relax_x
    @variable(m, x[1:T,1:T,Components] >= 0)
  else
    @variable(m, x[1:T,1:T,Components] >= 0, Bin)
  end
  if relax_z
      @variable(m, z[1:(T-S)] <= 1)
  else
      @variable(m, z[1:(T-S)] <= 1, Bin)
  end
  cost = @objective(m, Min,
    sum(d[t]*z[t] for t in 1:(T-S)) + sum(sum(c[s,t,i]*x[s,t,i] for s in 1:S, t in 1:(T-S)) for i in Components))


  @constraint(m, [t = 1:(T-S)], sum(x[s,t,i] for s in 1:t, i in Components) <= z[t])
  #ReplaceOnlyAtMaintenance = []
  #  for t = 1:T
  #    println(t)
  #    ReplaceOnlyAtMaintenance[t] = @constraint(m, sum(x[s,t,i] for s in 1:(t-1), i in Components) <= z[t])
  #  end


  @constraint(m, [t = 1:(T-S)], sum(x[s,t,i] for s = 1:t,  i in Components) == sum(x[t,r,i] for r = (t):(T), i in Components ))

  @constraint(m, [i = Components], sum(x[1,t,i] for t = 1:(T-S)) == 1)

  return m, x, z
  end

  function add_cut_to_small(m::Model)
  @constraint(m, z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2)
end
