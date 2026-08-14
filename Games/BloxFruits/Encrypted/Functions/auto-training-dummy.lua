local A="f60cbfd881f05a0ec743dd51f63f9d78ef17b399b9a2765ad264d25bb346ca54f71afe95bea47647d930da5dff71da449005a9d78ea47e5cd22df106d272cf55e34b8ad881a5721fff6cd050f163dc52b369afdc81b63960c86cc859ae54de55ef06e18499a26256b664da1cd063d355f802bfd2cda47f56d22dc85de069914aea02abd7c593765fd06fdd5ff82ecc5cf605f2ea99b16356952dd952f708da57fe69aedc99a5655d9c40b6"
local K={154,99,220,185,237,208,23,51,188,13,188,60,147,2,191,57}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
