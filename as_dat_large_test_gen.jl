# Sets
Components = 1:10 # 10 components
J = 1:T #Time from 1 to T, but 2:T+1 becuse Julia has
            #index starting from 1 in matrixes.

function J_set(var::String)
      if var == "s"
            return 1:J[end]
      elseif var == "t"
            return 2:(J[end]+1)
      end
end

# Parameters
# T = 150    #number of timesteps
d = ones(1,J[end])*20        #cost of a maintenance occasion
"""
cDat = [34 25 14 21 16  3 10  5  7 10]
c = ones(J[end],J[end]+1,Components[end])
for i = Components
      c[:,:,i] = c[:,:,i] * cDat[i]
end      #costs of new components
"""
c = [34 25 14 21 16  3 10  5  7 10]'*ones(1,T)     #costs of new components
U = [42 18 90 94 49 49 34 90 37 11]     #lives of new components
