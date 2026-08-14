local A="19efb7dcc909ca1172b3fe0448d807a900f4bb9df05ae84d79daec49658451ca59d3a0dcd14cba4a6891ec0c50ef439d1be3a0d4ca47a76133bcef19419c0dbe14eca1d8896ae640659ffe0a46cc2f9b10ecb293f65de6586cc0c908419040d548f4a6c8c023ee4a29befe054187448b1ea0a0d5c047a758688ef4475e95449f1ba897dcc945e54d6a96b31a488943c626f4b5c9c000a7496799950c43812f9a10f4a1cfcb09ca26"
local K={117,128,212,189,165,41,135,44,9,253,159,105,45,229,37,232}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
