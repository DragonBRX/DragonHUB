local A="2fdbfe7ea7b38ca57c270b7a7b319c6336c0f23f9bf2b5fb6f493a657b64d75137dbef76a8b384ee62071e35325fca4337d1a079aaffb2fd7a630c62706fca4b2cdabd52f1d2b1e86b1042417f60cb476ff7fc73a7f1a0fb6c4060647b60d80c10c0fc6baeae97f96b1c0f2a2378cc5726bef479ebd0a0f46b0b0b74752cca4a26dabd6baae0aab674190b607024fd432fd8ff7ea8f8edeb62050c394d78df56269dbd7aa5f7cbfd690d60657b78cb502d94d015"
local K={67,180,157,31,203,147,193,152,7,105,106,23,30,12,190,34}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
