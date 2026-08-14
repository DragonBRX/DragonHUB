local A="d2504637733fe2f1ef3cfdad4eabc73cc95a40383f6bc0ecd000fda744b6b11ad75e49253d33fcb8f506f9fd4df7891bdb422f306a71ccb8fd1df2e066aca418ce535c7e497ec3b9f15edfa147fa8709dd540c5c6c7ac3aaba21e8a15ff3d83edf5350332222dbbee11796a94db6a609d25347377c748fb8fc17f2e05ff79603904c55376871878ff51ef0a24af58e44cd5a4930314cdbade017b5e04ef88162db51415c6d7adbb9e61cbc8d21"
local K={190,63,37,86,31,31,175,204,148,114,156,192,43,150,229,104}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
