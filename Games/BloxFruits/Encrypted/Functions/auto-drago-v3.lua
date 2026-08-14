local A="0ad17098437fd18563211f064a25fb4113ca7cd96b2dfddf774f563d1c31fb2c35ca728d4a62fad9741c1b16257eac6e05ca7a96417fd182591f0e0756308f610acb76d56c3ef0d47a0e1d000612aa650ad83daa5b3ee8dd25391f075a7de43d12cc669c2536fa985b0e12074d79ba6b46ca7b9c417fe8d96b0450185f79ae6e4efd7295433dfddb73430d0e437ef75312df679c067ff9d67c651b054b12ab6512cb61970f1296"
local K={102,190,19,249,47,95,156,184,24,111,126,107,47,24,217,0}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
