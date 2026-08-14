local A="08a3c990075b3cedd37ff0ca2d07310b11b8c5d128141dbccd52e5870a5f61381dee86a21f1a05b59557f0cb3b5f6e4002b9c4921f121ebe887cabe6384a7f334c9acb9d1e1e5d93c95dfdc5295978636ebfcf9d0d5522a4c945f49a1e5b7f3f01f19785190e14dac157b1e429567f2805afc1d11f1314be8845f0d42314603a05bbc4d9281a1dbcca50f2cc6449762602e2f9850a0f14f98854ffc3425f7d2e6ebecf851e091ff0e53b"
local K={100,204,170,241,107,123,113,208,168,49,145,167,72,58,19,74}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
