local A="4c4be0bad3df59a7b91b65c47ecdebcb5550ecfbfc9078f6a73670895d82bce35406af88cb9e60ffff3365c56895b4804651edb8cb967bf4e2183ee86b80a5f30872e2b7ca9a38d9a33968cb7a93a2a32a57e6b7d9d147eea32161944d91a5ff4519beafcd8a7190ab3324ea7a9ca5e84147e8fbcb9771f4e22165da70debafa4153edf3fc9e78f6a03467c23783ace6460ad0afde8b71b3e2306acd1195a7ee2a56e6afca8d7aba8f5f"
local K={32,36,131,219,191,255,20,154,194,85,4,169,27,240,201,138}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
