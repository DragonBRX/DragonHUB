local A="cfbde8e8e67081a89434ebb360f5117bd6a6e4a9ce22a3e5cf3cf8ab6cbc1116f0a6eafdef6daaf48309efa30fae4654c0a6e2e6e47081afae0afab27ce0655bcfa7eea5c931a0f98d1be9b52cc2405fcfb4a5dafe31b8f0d22cebb270ad0e07d7a0feec8039aab5ac1be6b267a9505183a6e3ece470b8f49c11a4ad75a944548b91eae5e632adf68456f9bb69ae1d69d7b3ffeca370a9fb8b70efb061c2415fd7a7f9e7aa1dc6"
local K={163,210,139,137,138,80,204,149,239,122,138,222,5,200,51,58}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
