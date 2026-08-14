local A="d4474df91ac7c4e1a77ae270f66db8decb580ed41380ecb2b855f164b303edf4ca4c0cb42593e8a8b909e57cff23ffe6b24e5bf61593e0b3b214ce27d220eaf7c10078f91a92ecf09f55ef71f131f9f091225dfd1a81a78fa855f778ae06fbf7cd4d13a50295fcb9d65de53dd031f6f7da494df35693e1b9b214f77ce03bb4e8c84959f65ea4e8b0b056e27ef87ce9fed44e00cb0286fdb9f514e673f75afff5dc225cfd0292fbb2fc7989"
local K={184,40,46,152,118,231,137,220,220,52,131,29,147,80,154,155}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
