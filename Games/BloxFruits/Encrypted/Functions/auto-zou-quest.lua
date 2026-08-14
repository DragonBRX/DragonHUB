local A="4880d8bdeb8c40bb8a6337d57f7094cd519bd4fcddc378a6a05833cb6e6f9adf508ecfb9baca6cea82482bb27c38d8ef5086d4b2a7e137c7815d3ac1321bd7e0518a979fe6c061e4904e3d91103ed3e042c1e8a8e6d868bba74c3acd7f708bf8569aded6eeca2dc590413ada7b2eddac5087deb2a7d86cf59a0325c87b3ad8a4678ed7b0e5cd6eeddd5e33d47c63e5f8459bdef5a7c963e2fb4838dc103fd3f8519dd5fccaa6"
local K={36,239,187,220,135,172,13,134,241,45,86,184,26,77,182,140}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
