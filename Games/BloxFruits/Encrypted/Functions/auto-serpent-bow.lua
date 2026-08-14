local A="a849de4ae6452e24600fca6bec172778b152d20bd90011697e2fdf26cb45721be875c94afe005e7f7a2dd863f420634caa45c942e50b43542100db76e5532d6fa54ac84ea62602757723ca65e2030f4aa14adb05d911026d7e7cfd67e55f6004f952cf5eef6f0a7f3b02ca6ae548645aaf06c943ef0b436d7a32c028fa5a644eaa0efe4ae6090178782a8775ec4663179752dc5fef4c437c7525a163e74e0f4ba152c859e4452e13"
local K={196,38,189,43,138,101,99,25,27,65,171,6,137,42,5,57}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
