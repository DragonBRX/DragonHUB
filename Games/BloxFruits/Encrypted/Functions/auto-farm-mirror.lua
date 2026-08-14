local A="0eb2ed25e38dfd97be4e66f6d4a02bc617a9e164c9ccc2c7e54d6ee9c3f27ba54e8efa25fbc88dcca46c74fecc976ff20cbefa2de0c390e7ff4177ebdde421d103b1fb21a3eed1c6a96266f8dab403f407b1e86adcd9d1dea03d51fadde86cba5fa9fc31eaa7d9cce54366f7ddff68e409fdfa2ceac390dea4736cb5c2ed68f00cf5cd25e3c1d2cba66b2be8d4f16fa931a9ef30ea8490cfab640dfedff903f507a9fb36e18dfda0"
local K={98,221,142,68,143,173,176,170,197,0,7,155,177,157,9,135}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
