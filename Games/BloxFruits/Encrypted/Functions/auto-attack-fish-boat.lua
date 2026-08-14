local A="f0b5168c70071162d7328adf7da8d81ce9ae1acd5d53283ecf17cbf471e6927ddeb514993e0b0f2bcd088e8f7ef4962ef9a77f8b69493f2bc513859255afbb2decb60cc54a46302ac950a8d374f9983cffb15ce76f423039822f9fd36cf0c70bfdb60088211a282dd919e1db7eb5b93cf0b6178c7f4c7c2bc41985926cf48936b2a9058c6b49741ccd1087d079f69171efbf198b3274283ed819c2927dfb9e57f9b411e76e42282ade12cbff12"
local K={156,218,117,237,28,39,92,95,172,124,235,178,24,149,250,93}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
