local A="f961d50ead5ffd4f9c159c03c622b9f0c66dd218fd1dfd72be159615c622b9a9a956f523925eb951f058d144b17ef5b9dc65d51ead13f114f010901f8a76febaff4a8357ff138d5ba000900ab371d5bde86f8306a23b"
local K={139,4,161,123,223,49,221,52,210,116,241,102,230,31,153,210}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
