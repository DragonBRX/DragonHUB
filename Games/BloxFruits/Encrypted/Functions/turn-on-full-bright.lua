local A="ada9f2b275815da4bae8fa01378305ffb4b4fff376cf30dfb4caf74c10cc4ecca9b2b3ff4ad571eda49bfd0d3ecd42d6cba0e4bd7ad579f6af86d65613ce57c7b8eec7b275d475b582c7f70030df44c0e8cce2b675c73ecab5c7ef096fe846c7b4a3acee6dd365fccbcffd4c11df4bc7a3a7f2b839d578fcaf86ef0d21d509d8b1a7e6bd31e271f5adc4fa0f399254ceada0bf806dc064fce886fe0236b442c5a5cce3b66dd462f7e1eb91"
local K={193,198,145,211,25,161,16,153,193,166,155,108,82,190,39,171}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
