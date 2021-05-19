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
    @variable(m, x[0:T,1:(T+1),Components] >= 0)
  else
    @variable(m, x[0:T,1:(T+1),Components] >= 0, Bin)
  end
  if relax_z
      @variable(m, z[J] <= 1)
  else
      @variable(m, z[J] <= 1, Bin)
  end
  cost = @objective(m, Min,
    sum(d[t]*z[t] for t in J) + sum(sum(c_cost(s,t,i)*x[s,t,i] for t in 1:(T+1), s in 0:(t-1)) for i in Components) - 145)

  #Constraint 1b)
  @constraint(m, [t in J, i in Components], sum(x[s,t,i] for s in 0:(t-1)) <= z[t])

  #Constraint 1c)
  @constraint(m, [t in J, i in Components], sum(x[s,t,i] for s in 0:(t-1)) == sum(x[t,r,i] for r in (t+1):(T+1)))

  #Constraint 1d)
  @constraint(m, [i in Components], sum(x[0,t,i] for t = 1:(T+1)) == 1)

  #ReplaceWithinLife = @constraint(m,
  #  [i in Components, s in J_set("t") ,ell in 0:(T-U[i]); T >= U[i]],
  #  sum(x[t,s,i] for t in (ell + 1):(ell + U[i])) >= 1)



  return m, x, z
  end

  function add_cut_to_small(m::Model)
  @constraint(m, z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2)
end
