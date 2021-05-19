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
    @variable(m, x[Components,J] >= 0)

  else
    @variable(m, x[Components,J] >= 0, Bin)
  end
  if relax_z
      @variable(m, z[J] <= 1)
  else
      @variable(m, z[J] <= 1, Bin)
  end

  cost = @objective(m, Min,
    sum(d[t]*z[t] for t in J) + sum(sum(c[i,t]*x[i,t] for t in J) for i in Components))

  #Constraint 1b)
  @constraint(m, [t in J], sum(x[i,s] for s in J, i in Components) <= z[t])

  #Constraint 1c)
  #@constraint(m, sum(x[i,t] for t = 1:(t-1),  i in Components) == sum(x[i,r] for r in (t+1):(T+1), i in Components ))

  #Constraint 1d)
  @constraint(m, [i = Components], sum(x[i,t] for t = 2:(T)) == 1)

  ReplaceWithinLife = @constraint(m,
    [i in Components, ell in 0:(T-U[i]); T >= U[i]],
    sum(x[i,t] for t in ell .+ (ell + 1):(ell + U[i])) >= 1)

  ReplaceOnlyAtMaintenance = @constraint(m, [i in Components, t in J],
  x[i,t] <= z[t])

  return m, x, z
  end

  function add_cut_to_small(m::Model)
  @constraint(m, z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2)
end
