local A="412376ba58c0b883ae04b5e4fbdb32c158387afb718c9ccab06a85fcfb9564a2011f61ba4085c8d8b426a7ece3ec76f5432f61b25b8ed5f3ef0ba4f9f29f38d64c2060be18a394d2b928b5eaf5cf1af3482073f5679494cab07782e8f29375bd103867ae51ea9cd8f509b5e5f28471e3466c61b3518ed5cab439bfa7ed9671f7436456ba588c97dfb621f8fafb8a76ae7e3874af51c9d5dbbb2edeecf0821af2483860a95ac0b8b4"
local K={45,76,21,219,52,224,245,190,213,74,212,137,158,230,16,128}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
