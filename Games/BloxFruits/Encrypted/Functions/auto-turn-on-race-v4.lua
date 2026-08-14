local A="26f1709cd154bf870887fe5b9bd3ee0c3fea7cdde90180d453a6f116ac8faf286ac827df912786db07aca2509f82bf2837947588d31786d31ca7bf7bc4afbc3d26e73babdc1887df5f8afe5a928cad2e21b7198ed818949420bdfe429bd39a2c26eb76c0800080cf16c3f650deadad2126fc729ed65486d216a7bf429f9da76339ee728ad35cb1db1fa5fd579d85e03e2ff275d3ee0093ce16e0bf53908ac62824fa198fd80087c81de9d23c"
local K={74,158,19,253,189,116,242,186,115,201,159,54,254,238,204,77}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
