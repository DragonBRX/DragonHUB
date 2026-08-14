local A="37afa7c2e4b000d10fc1ec966aaad0392eb2aa83e7fe6db81de2e8d923c4860c2fa5f9c5e9fc3e890985eb8e61f4860434aee4eeb2d13d9c18f6a5ad6efb87087783a5cfe4f22c8f1fa687886afb944308b4a5d7edad1b8d18fae8c632e380183ecaadc5a8d32c8018edec9864b786053eaee4d7e9e326c207ffec8c61bfb10c37aca6c2ebfb619f11e3ebd55ce393193ee9e4c6e6f447891aeb87896ae3871f35e089a9"
local K={91,192,196,163,136,144,77,236,116,143,141,251,15,151,242,109}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
