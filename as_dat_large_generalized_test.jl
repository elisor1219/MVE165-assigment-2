# Sets
Components = 1:1 # 10 components
J = 2:(T+1) #Time from 1 to T, but 2:T+1 becuse Julia has
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
cDat = [14]
c = ones(J[end],J[end]+1,Components[end])
for i = Components
      c[:,:,i] = c[:,:,i] * cDat[i]
end      #costs of new components
U = [2]     #lives of new components
