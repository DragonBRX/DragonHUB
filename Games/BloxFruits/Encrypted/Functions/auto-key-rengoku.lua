local A="a514e7c3c07f3a65f4fc15444f85753dbc0feb82e73a0e78ddd71a4e45d3225ee528f0c3d83a4a3eeede074c57b23109a718f0cbc3315715b5f3045946c17f2aa817f1c7801c1634e3d0154a41915d0fac17e28cff2b162cea8f224846cd3241f40ff6d7c9551e3eaff1154546da361fa25bf0cac931572ceec11f0759c8360ba753c7c3c0331539ecd9585a4fd431529a0fe5d6c976573de1d67e4c44dc5d0eac0ff1d0c27f3a52"
local K={201,123,132,162,172,95,119,88,143,178,116,41,42,184,87,124}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
