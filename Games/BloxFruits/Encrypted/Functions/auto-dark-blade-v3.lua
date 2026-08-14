local A="d4e2d4f949721a3425d78c4173a3b632cdf9d8b8613325627edb814d72fbb4258baf9bcb5133236c63ff8c4065fbe979def8d9fb513b38677ed4d76d66eef80a90dbd6f450377b4a3ff5814e77fdff5ab2fed2f4437c047d3fed881140fff806ddb08aec5727320337ffcd6f77f2f811d9eedcb8513a32677eed8c5f7db0e703d9fad9b066333b653cf88e473aedf11fdea3e4ec442632207efc83481cfbfa17b2ffd2ec502039291393"
local K={184,141,183,152,37,82,87,9,94,153,237,44,22,158,148,115}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
