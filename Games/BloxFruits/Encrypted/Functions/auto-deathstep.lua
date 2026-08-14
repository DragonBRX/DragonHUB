local A="a0a08515b65cbbeaf08e6b06b30b38f6b9bb89549e1997a3e3937e0ea61436e4b8ae9211e71a97bbf8a57761b04374d4b8a6891afa31cc96fbb06612fe607bdbb9aaca37bb109ab5eaa36142dc457fdbaae1b500bb0893eadda1661eb30b27c3beba837eb31ad694eaac6609b7557197b8a7831afa0897a4e0ee791bb741749f8fae8a18b81d95bca7b36f07b01849c3adbb835dfa1998b381a5640fdc447fc3b9bd88549776"
local K={204,207,230,116,218,124,246,215,139,192,10,107,214,54,26,183}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
