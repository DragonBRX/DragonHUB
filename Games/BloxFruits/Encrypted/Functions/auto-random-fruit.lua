local A="b958580aab106badfff244c4ad632043a043544b955148f4ebd105efba2b6b76f71b681fa64443ade2dd49daad230864a059581fae5f48b0c98664d9b8327b2a8356571ea21c65f1e8d047c8ab352b08a652570de96352f1f0d918ffa9327767e80a4f19b2552cf9e29c66c8a4326063b65c1b1faf5548b0f0dd56c2e62d7263a2591328a65c4af2e5df4e85bb3b6e64fb644f0ab3550fb0e1d241a3ad306608a7524f1eb55e06dd8e"
local K={213,55,59,107,199,48,38,144,132,188,37,169,200,94,2,2}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
