local A="7bc6e2e5f226458161206c67459810ee72c4eef2fb2640d56e4e5b4c78871eef63c8f5e1a36069d0690b700046d05cdf63c0eeeabe4b32fd6a1e617308f353d062ccadc7ff6a64de7b0d66232ad657d07187d2f0ff726d814c0f617f45980fc865dce48ef76028ff7b02616841c6599c63c1e4eabe7269cf71407e7a41d25c9454c8ede8fc676bd7361d6866468b61c876dde4adbe6366d8100b636e2ad757c862dbefa4d30c"
local K={23,169,129,132,158,6,8,188,26,110,13,10,32,165,50,188}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
