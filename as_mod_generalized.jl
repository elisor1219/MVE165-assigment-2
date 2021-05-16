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
    @variable(m, x[J_set("s"),J_set("t"),Components] >= 0) #TODO Risken här är att J+1 inte
                                           #fungerar att skriva, då får man
                                           #istället skriva 1:(J[end]+1) eller
                                           #göra om J till J = T+1. Då kan man
                                           #skriva 1:J och 1:(J+1) istället.
  else
    @variable(m, x[J_set("s"),J_set("t"),Components] >= 0, Bin)
  end
  if relax_z
      @variable(m, z[J] <= 1)
  else
      @variable(m, z[J] <= 1, Bin)
  end

  cost = @objective(m, Min,
    sum(d[t]*z[t] for t in J) + sum(sum(c[s,t,i]*x[s,t,i] for s in J_set("s"), t in J_set("t")) for i in Components))
    #TODO kan bli fel här då [t > s] är oklart om de går att skriva.

  #Constraint 1b)
  @constraint(m, [t in J], sum(x[s,t,i] for s in 1:(t-1), i in Components) <= z[t])

  #Constraint 1c)
  @constraint(m, [t in J], sum(x[s,t,i] for s = 1:(t-1),  i in Components) == sum(x[t,r,i] for r in (t+1):(T+1), i in Components ))

  #Constraint 1d)
  @constraint(m, [i = Components], sum(x[1,t,i] for t = 2:(T+2)) == 1)

  return m, x, z
  end

  function add_cut_to_small(m::Model)
  @constraint(m, z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2)
end
