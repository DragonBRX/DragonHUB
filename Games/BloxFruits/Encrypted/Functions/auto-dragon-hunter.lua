local A="cd2de35405035ee6d67eaecc92b73716d436ef152d5172bcc25eefe982e46132d360ac661d4267be9056aecd84ef685dc737ee561d4a7cb58d7df5e087fa792e8914e1591c463f98cc5ca3c396e97e7eab31e5590f0d40afcc44aa9ca1eb7922c47fbd411b5676d1c456efe296e67935c021eb151d4b76b58d44aed29ca46627c035ee1d2a427fb7cf51accadbf9703bc76cd341085776f28d55a1c5fdef7b33ab30e5411c517dfbe03a"
local K={161,66,128,53,105,35,19,219,173,48,207,161,247,138,21,87}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
