local A="9e70faa233f16d4624c8dd549d32c07c876bf6e318be44132aebdd57da23b149936bfcfe39b04c083afbb65f8d6181499b70f7e312eb610b2feac511ae6e8e489733daa233bd421a3ced95338b6a8e5bdc4ceda22bb41d2d3eeac95cc532964f877a93aa39f1631a33eade589b64c2499a7af7e32bb0531071f5cc588f61ca7e9373f5a13eb24b572ce3d05fd65c965c867ab0e33abf44713ae8d8338a6a96488071b98e55"
local K={242,31,153,195,95,209,32,123,95,134,188,57,248,15,226,61}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
