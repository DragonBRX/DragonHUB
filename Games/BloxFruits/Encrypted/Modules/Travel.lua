local A="598ed116ac95845aaa74056f5d460c7c7f99c415bb97860dc453046b1a080c630b908737bb97c1518b671c28515b0e0a7ba5d500fcd78403b067097c1817682c4e98874ffed9e554907a32650859512321"
local K={43,235,165,99,222,251,164,33,228,21,104,10,125,123,44,94}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
