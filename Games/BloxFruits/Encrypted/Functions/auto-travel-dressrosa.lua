local A="2b6311abb2308601537351b22b83a10a32781dea8a62aa4a4d51109b3cdbf038356301abfc3c9848494955e228dfef38227178acab7ea84841525eff0384c23b37600be28871a7494d1173be22d2e12a24675bc0ad75a75a066e44be3adbbe1d266007afe32dbf4e5d583ab6289ec02a2b6010abbd7beb4840585eff3adff020697f02aba97ee37f49515cbd2fdde86734691eacf043bf5d5c5819ff2bd0e741226216c0ac75bf495a53109244"
local K={71,12,114,202,222,16,203,60,40,61,48,223,78,190,131,75}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
