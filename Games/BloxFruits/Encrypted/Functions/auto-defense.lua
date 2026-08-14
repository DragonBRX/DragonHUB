local A="d6d70efed83f5740c017f1791d417696cfcc02bff07a7c18d52af536542f20b6cedd50f9d5736918c653f661161f20bed5d64dd28e5e6a0dd720b842191021b296fb0cf3d87d7b1ed0709a671d1032f9e9cc0cebd1224c1cd72cf529450826a2dfb204f9945c7b11d73bf177135c20bfdfd64debd56c7153c829f163165417b6d6d40ffed774360ede35f63a2b0835a3df914dfada7b1018d53d9a661d0821a5d4982095"
local K={186,184,109,159,180,31,26,125,187,89,144,20,120,124,84,215}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
