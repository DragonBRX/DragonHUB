local A="76e897a9f8f298d72c02f3a301f259436ff39be8d2b3b69e383eebee36ae126638aba7bcf5a6b0d7312dfebd01b271646fe997bcfdbdbbca1a76d3be14a3022a4ce698bdf1fe968b3b20f0af07a4520869e298aeba81a18b2329af9805a30e6727ba80bae1b7df83316cd1af08a3196379ecd4bcfcb7bbca232de1a54abc0b636de9dc8bf5beb988362ff9e217aa176434d480a9e0b7fcca3222f6c401a11f0868e280bde6bcf5a75d"
local K={26,135,244,200,148,210,213,234,87,76,146,206,100,207,123,2}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
