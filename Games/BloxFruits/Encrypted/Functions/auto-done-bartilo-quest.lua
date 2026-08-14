local A="07d82fba9bab996fbfea983743bf86461ec323fbb3e4ba37e4e6982852ebc8684be639be84fff67e97d0982e43bfc26607c429a6fdeda13ca7d0903548a2e93d2ac73cb78ea38233a8d19c7665e3c86b09d62fb0de81a737a8c2d70952e3d06256e12db782eee96fb0d68c3f2cebc22728d620b795eab739e4d0913f48a2d06618dc62a887eaa33cece798364ae0c564009b3fbe9bedfa01b0c58d3f0fa2c1690fbd29b59381a637b0d18b3406cfae"
local K={107,183,76,219,247,139,212,82,196,164,249,90,38,130,164,7}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
