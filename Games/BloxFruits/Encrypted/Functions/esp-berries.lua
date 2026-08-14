local A="b3a8b1585ead9dcfa2a1b40cf2f3ba7cacb7f27b57ffa29bbc9cf74dc4baf94dbafab4585efeb58fd389a00ff4baf156b1e79f0373fda09ea0c78300fbbbfd159ca6be5550ecb399f0e5a604fba8b66aaba6a65c0fdbb19eac8ae85ce3bced5cd5aeb41971ecbc9ebb8eb60ab7baf05cb1cda65841e6fe81a98ea20fbfa8ed57bcb3bb565ca5f9f8b580b600fbeecb4cbca4b74a41a19580ab80a75ce7adf955b3ef91585ee1b293ba84f912f2a2fe178cb3b34d57a4da9bbfcfbb0ee3eecb4cbca4b74a41ada49abc81f53ed0e0dc4bbea0bd577af8b2b4ac81b615fea1f67cadb5bd4b0ffeb59ebfc19b00faabb617fdfdf21b1ca3a49daa9ba708f9a9b07cadb5bd4b1badb59cbde5b00ff3e7925cb1a3d85c5ce9da80bc9ba013f9eed533"
local K={223,199,210,57,50,141,208,242,217,239,213,97,151,206,152,57}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
