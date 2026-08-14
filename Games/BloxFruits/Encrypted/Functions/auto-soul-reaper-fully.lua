local A="e300b88338ce235a709d89c85ee7b858fa1bb4c207811b0b2b818dc44bbfe839d429ae8e3897334527809cc44fbfa77fee03a88729e4081265b09ccc54b4ba54b52eab92389746316abf9dc01799fb75e30dba813fc764146ebf8e8b68aefb6dea528d83389b0b5a36a79ad05ed0f37faf2cba8e388c0f0460f39ccd5eb4ba6dee1cb0cc279e0f1065fbabc457b6f878ec04f7913182084958a789d15ef3ba7ce10bd1873a8a64156ea79dd755fad713"
local K={143,111,219,226,84,238,110,103,11,211,232,165,59,218,154,25}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
