local A="0265a2a1dfa11b5a3fb234f8d1dd2bd71b7eaee0f0ee3a0b219f21b5f7886ce51a28ed93c7e02202799a34f9c785749c087fafa3c7e8390964b16fd4c49065ef465ca0acc6e47a24259039f7d58362bf6479a4acd5af0513258830a8e28165e30b37fcb4c1f4336d2d9a75d6d58c65f40f69aae0c7e93309648834e6dfce7ae60f7dafe8f0e03a0b269d36fe98936cfa082492b4d2f5334e64993bf1be8567f26478a4b4c6f3384709f6"
local K={110,10,193,192,179,129,86,103,68,252,85,149,180,224,9,150}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
