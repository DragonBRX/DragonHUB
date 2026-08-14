local A="3dc6b569064276006f2fc0d2be969d4734c4b97e0f427f587515c99ffd8bed7022d9b77f04075f1d4227f99df7f8cb7425cceb6e0b0e4858696bc7cab5c8cb7c3ec7f64550234b4d781889e9bac7ca707deab76406005a5e7f48abccbec7d93b02ddb77c0f5f6d5c7814c482e6dfcd6034a3bf6e4a215a517803c0dcb08bcb7d34c7f67c0b1150136711c0c8b583fc743dc5b4690909174e710dc79188dfde613480f66d040631587a05abcdbedfca673f899b02"
local K={81,169,214,8,106,98,59,61,20,97,161,191,219,171,191,21}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
