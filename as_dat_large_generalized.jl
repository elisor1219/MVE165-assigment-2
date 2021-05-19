# Sets
Components = 1:10 # 10 components
J = 1:T

function J_set(var::String)
      if var == "s"
            return 0:(t-1)
      elseif var == "t"
            return 1:(T+1)
      end
end

# Parameters
# T = 150    #number of timesteps
d = ones(1,J[end])*20        #cost of a maintenance occasion
U = [42 18 90 94 49 49 34 90 37 11]     #lives of new components
cDat = [34 25 14 21 16  3 10  5  7 10] #Cost of new component

function c_cost(s::Int64, t::Int64, i::Int64)
      if (t-s) <= U[i]
            return cDat[i]
      elseif (t-s) >= (U[i] + 1)
            return T*(maximum(d) + Components[end]*maximum(cDat))+1
      end
end

c = OffsetArray{Float64}(undef,0:T,1:(T+1),Components[end])


for i in Components
      for t in 1:(T+1)
            for s in 0:T
                  c[s,t,i] = c_cost(s,t,i)
            end
      end
end
