local A="1242e2855f812913afc9eb1e21ff8e310b59eec460c00d42f4c5e51230e080230a4cf5810ec70542a7e2f77922b7c2130a44ee8a13ec5e6fa4f7e60a6c94cd1c0b48ada752cd084cb5e4e15a4eb1c91c1803d29052d5011382e6e60621ff91040c58e4ee5ac7446db5ebe61125a1c7500a45e48a13d5055dbfa9f90325b5c2583d4ced8851c00745f8f4ef1f22ecff041f59e4cd13c40a4adee2e4174eb0c9040b5fefc47eab"
local K={126,45,129,228,51,161,100,46,212,135,138,115,68,194,172,112}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
