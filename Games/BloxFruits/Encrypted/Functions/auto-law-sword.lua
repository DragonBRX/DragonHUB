local A="42b14e8443ad630ec299a473270d8f175baa42c563ec5913eaa0aa6c261281055abf598012eb4f5fcab2b8142445c3355ab7428b0fc01472c9a7a9676a66cc3a5bbb01a64ee14251d8b4ae374843c83a48f07e914ef94b0eefb6a96b270d90225cab48ef46eb0e70d8bba97c2353c6765ab6488b0ff94f40d2f9b66e2347c37e6dbf41894dec4d5895a4a072241efe224faa48cc0fe84057b3b2ab7a4842c8225bac43c56287"
local K={46,222,45,229,47,141,46,51,185,215,197,30,66,48,173,86}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
