local A="41226223d5b0de96b34e8c7e55f39bb858396e62f4f1e0dfad72943377bbd7db011e7523cdf5aecda96c9e764dc4df8c432e752bd6feb3e6f2419d635cb791af4c21742795d3f2c7a4628c705be7b38a4821676ceae4f2dfad3dbb725cbbdcc410397337dc9afacde8438c7f5cacd89a466d752adcfeb3dfa973863d43bed88e43654223d5fcf1caab6bc16055a2dfd77e396036dcb9b3cea664e7765eaab38b48397430d7b0dea1"
local K={45,77,1,66,185,144,147,171,200,0,237,19,48,206,185,249}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
