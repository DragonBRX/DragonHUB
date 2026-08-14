local A="24cfc619222dd5fa96fe9bc555ac96fe2fceca0a2b2dcba680d5dafc55f0d9c46a8cf60c2f79fdfa8bd196db55ecbed13dcec60c2762f6e7a08abbd840fdcd9f1ec1c90d2b21dba681dc98c953fa9dbd3bc5c91e605eeca699d5c7fe51fdc1d2759dd10a3b6892ae8b90b9c95cfdd6d62bcb850c2668f6e799d189c31ee2c4d63fce8d3b2f61f4a58cd3918443f4d8d166f3d1193a68b1e788de9ea255ffd0bd3ac5d10d3c63b88ae7"
local K={72,160,165,120,78,13,152,199,237,176,250,168,48,145,180,183}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
