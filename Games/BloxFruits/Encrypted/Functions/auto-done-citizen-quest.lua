local A="df1830b23f95050dff46ad5eba498fddc6033cf317da2655a44ba547b60ec8f2932626b620c16a1cd77cad47ba49cbfddf0436ae59d33d5ee77ca55cb154e0a6f20723bf2a9d1e51e87da91f9c15c1f0d11630b87abf3b55e86ee260ab15d9f98e2132bf26d0750df07ab956d51dcbbcf0163fbf31d42b5ba47ca456b154d9fdc01c7da023d43f5eac4bad5fb316ccffd85b20b63fd36663f069b856f654c8f2d77d36bd37bf3a55f07dbe5dff39a7"
local K={179,119,83,211,83,181,72,48,132,8,204,51,223,116,173,156}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
