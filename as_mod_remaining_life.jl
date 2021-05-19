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
  if relax_x
    @variable(m, x[Components, 1:T] >= 0)
  else
    @variable(m, x[Components, 1:T] >= 0, Bin)
  end
  if relax_z
      @variable(m, z[1:T] <= 1)
  else
      @variable(m, z[1:T] <= 1, Bin)
  end
  cost = @objective(m, Min,
    sum(c[i, t]*x[i, t] for i in Components, t in 1:T) + sum(d[t]*z[t] for t in 1:T))

  #Life after t=T.
  RemainingLifeAfterPlanningPeriod = @constraint(m, [i in Components],
  sum(x[i,t] for t in (T-U[i]+r):T)  >= 1)

  ReplaceWithinLife = @constraint(m,
    [i in Components, ell in 0:(T-U[i]); T >= U[i]],
    sum(x[i,t] for t in (ell + 1):(ell + U[i])) >= 1)

  ReplaceOnlyAtMaintenance = @constraint(m, [i in Components, t in 1:(T)],
  x[i,t] <= z[t])


  return m, x, z
end
