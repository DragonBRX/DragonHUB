local A="f79486a865d8b401f42c4ce10cc98239ee8f8ae95a99975bfa0b43e92886d45ab7a891a87d9dc45aee0e5ee914fec60df59891a06696d971b5235dfc058d882efa9790ac25bb9850e3004cef02ddaa0bfe9783e75a8c9848ea5f7bed0581c545a68f97bc6cf2905aaf214ce00596c11bf0db91a16c96d948ee1146a21a84c10ff5d3a6a865949b5dec0901ff0c98c656c88f84bd6cd1d959e10627e90790aa0afe8f90bb67d8b436"
local K={155,251,229,201,9,248,249,60,143,98,45,140,105,244,160,120}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
