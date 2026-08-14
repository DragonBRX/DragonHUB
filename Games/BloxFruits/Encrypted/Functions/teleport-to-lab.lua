local A="aa77410fa05fe55f6e879505bb86128ca374471ea30ddc4241a6d424bfd912f4956c431aa942ce0379ba9115d4dd45b6a56c4b01a25fe55854b98404a79366b9aa6d47428f1ec40e77a89703f7b143bdaa7e0c3db81edc07289f9504abde0de5b26a570bc616ce4256a89804bcda53b3e66c4a0ba25fdc0366a2da1baeda47b6ee5b4302a01dc9017ee5870db2dd1e8bb279560be55fcd0c71c39106bab142bdb26d5000ec32a2"
local K={198,24,34,110,204,127,168,98,21,201,244,104,222,187,48,216}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
