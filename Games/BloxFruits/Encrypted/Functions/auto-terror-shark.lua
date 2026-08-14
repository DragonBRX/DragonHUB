local A="0c93278dd1e378ee0b982fe4b04c14a215882bcce9a647a11fa46edabd10448842d01798dcb750ee16b722fab00c3c8515922798d4ac5bf33dec0ff9a51d4fcb369d2899d8ef76b21cba2ce8b61a1fe91399288a939041b204b373dfb41d43865dc1309ec8a63fba16f60de8b91d548203976498d5a65bf304b73de2fb02468217926cafdcaf59b111b525a5a6145a854eaf308dc9a61cf315b82a83b01f52e912993099cfad159e7a"
local K={96,252,68,236,189,195,53,211,112,214,78,137,213,113,54,227}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
