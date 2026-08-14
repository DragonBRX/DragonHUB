local A="9a37dde61fa0d1ef5b6a3324e4d8bd7d832cd1a723f2fdab00632028f780ec489936dba55fd3e8b354416f2fe089ec598b52d8f21de3e8bb4f4a7204bba4ef4c9a2196d112ece9b70c673325ed87fe5f9d71b4f416ecfafc7350333de4d8c95d9a2ddbba4ef4eea7452e3b2fa1a6fe509a3adfe418a0e8ba454a723de096f4128528dff01da8dfb34c483028e28eb34f9334d8a920f4fda6450d722cef819559983cb4f516f4e9a04e041f43"
local K={246,88,190,135,115,128,156,210,32,36,82,73,129,229,159,60}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
