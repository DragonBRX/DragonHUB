local A="9eb7b087fa6643aba27c79848dbbcf5087acbcc6c2337cf8f95d76c9bbf6847fd288bc95ff3267f9b71034ba9ce79974cfbeb28ae523739cbf47768a9cef827fd295e9a7e63662eff16479859de3c15293b4bf84f72565bfd3417d858ea8be6593acb6dbc02762e3bc0f259d9af3881b9bbef3a5f72a62f4b85173c99cee887fd2acb295fd687de6b84576c1abe7817d90b9b08dba356bfabf1c4b9d89f28838d2bdbd829c2360f2d3407d9d9df48331bfd2"
local K={242,216,211,230,150,70,14,150,217,50,24,233,232,134,237,17}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
