local A="04571d18a387280b49ba2ef57b2a7bca3f460c00a2cb245041b722f7283766c80d102818a5865b1165be31b2773779a3134b1a3fb4872a5c27f902e52f7804bc03410104a5882a5c27f902e52f7804b1175f084ffdc92a33439061bc7b351a9d025d363ebe9c642f40ae2ae43a6579950b38"
local K={118,50,105,109,209,233,8,112,7,219,67,144,91,23,91,232}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
