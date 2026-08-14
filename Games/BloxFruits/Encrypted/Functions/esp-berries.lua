local A="b3a8b1585ead9dcfa2a1b40cf2f3ba7cacb7f27b57ffa29bbc9cf74dc4baf94dbafab4585efeb58fd389a00ff4baf156b1e79f0373fda09ea0c78300fbbbfd159ca6be5550ecb399f0e5a604fba8b66aaba6a65c0fdbb19eac8ae85ce3bced5cd5aeb41971ecbc9ebb8eb60ab7baf05cb1e7a65841e6fe81a98ea20fbf8df955b3a5b35a59a1a397b589fb32e3afec5cf6e7b7575687b59cbde5a704e3bbea57ff8ad8"
local K={223,199,210,57,50,141,208,242,217,239,213,97,151,206,152,57}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
