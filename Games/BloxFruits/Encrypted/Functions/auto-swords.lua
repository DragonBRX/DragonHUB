local A="bfaf319e677ee3c279b979fd1f3058cda6b43ddf5829c18d66843abc29791bf8b6fd349e672dcb8208916dfe197913e3bde01fc54a2ede937bdf4ef116781fa090a13e93693fcd942bfd6bf5166b54dfa7a1269a3608cf93779225ad0e7f0fe9d9a934df483fc29360967bfb5a7912e9bde0269e7835808c72966ffe524e1be0bfa2339c6072dd9a6e9136c30e6c0ee9fae037916f54cb9166fd6af50e7808e2f38d58"
local K={211,192,82,255,11,94,174,255,2,247,24,144,122,13,122,140}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
