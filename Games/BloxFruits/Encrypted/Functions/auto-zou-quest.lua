local A="4880d8bdeb8c40bb8a6337d57f7094cd519bd4fcddc378a6a05833cb6e6f9adf508ecfb9baca6cea82482bb27c38d8ef5086d4b2a7e137c7815d3ac1321bd7e0518a979fe6c061e4904e3d91103ed3e042c1e8a8e6d868bba74c3acd7f708bf8569aded6eeca2dc590413ada7b2eddac5087deb28dd86cf59a0325c87b3ad8a4429ad5bff3c562e8d9045cd4752ed7e004bccebfe4c97ef5dd6824ca753f8bfc478ed7b0afef6cea9d4f37db7161c5e94889958ff3cd79e3d8273fde3a23d9f804bccebfe4c97ef5d1593edd746de9cb0aabc9bde0c363ce844f10cd742ec2e54b81feaef5c37fbb82483ade3403d7e141c195febd8c2fa8df5939cb6e3fdfe243c7feaef5c37fafd14838dc1028d8e80de5deb2e3a668e8952724dd6e38c4e204a2b1"
local K={36,239,187,220,135,172,13,134,241,45,86,184,26,77,182,140}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
