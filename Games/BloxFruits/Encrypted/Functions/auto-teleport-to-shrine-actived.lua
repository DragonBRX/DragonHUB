local A="c38daf96831edc9cf177fcb7651585bada96a3d7bb5bfdc4fa56efae205cc8dbfc8abe9e815bb1e0e94df4ac654c85d7fc96ad838a03f7c0e64af8a70a4ed295cc96a598811edc9bcb49edb67900f19ac397a9dbac5ffdcde858feb12922d49ec384e2a49b5fe5c4b76ffcb6754d9ac6db90b992e557f781c958f1b66249c4908f96a492811ee5c0f952b3a97049d09587a1ad9b835cf0c2e115eebf6c4e89a8db83b892c61ef4cfee33f8b46422d59edb97be99cf739b"
local K={175,226,204,247,239,62,145,161,138,57,157,218,0,40,167,251}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
