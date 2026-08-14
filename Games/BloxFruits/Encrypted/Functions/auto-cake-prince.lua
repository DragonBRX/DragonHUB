local A="b637ab15304812ef2ba51ab2e3631c13af2ca7541f0934b770bb09b6e83d5b70f60bbc15280d62b4318708bafb545827b43bbc1d33067f9f6aaa0bafea271604bb34bd11702b3ebe3c891abced773421bf34ae5a0f1c3ea635d62dbeea2b5b6fe72cba01396236b470a81ab3ea3c5f31b178bc1c39067fa6319810f1f52e5f25b4708b1530043db3338057ace332587c892ca90039417fb73e8f71bae83a3420bf2cbd06324812d8"
local K={218,88,200,116,92,104,95,210,80,235,123,223,134,94,62,82}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
