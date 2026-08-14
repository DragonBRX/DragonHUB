local A="a0c396f674b892a1d20c89e39910afe4b9d89ab75ceabefbc662c0d8cd04af899fd894e37da5b9fdc5318df3f64bf8cbafd89cf876b892a6e83298e28505dbc4a0d990bb5bf9b3f0cb238be5d527fec0a0cadbc46cf9abf9941489e28948b098b8de80f212f1b9bcea2384e29e4ceeceecd89df276b8abfdda29c6fd8c4cfacbe4ef94fb74fabeffc26e9beb904ba3f6b8cd81f231b8baf2cd488de09827ffc0b8d987f938d5d5"
local K={204,172,245,151,24,152,223,156,169,66,232,142,252,45,141,165}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
