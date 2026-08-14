local A="37afa7c2e4b000d10fc1ec966aaad0392eb2aa83e7fe6db81de2e8d923c4860c2fa5f9c5e9fc3e890985eb8e61f4860434aee4eeb2d13d9c18f6a5ad6efb87087783a5cfe4f22c8f1fa687886afb944308b4a5d7edad1b8d18fae8c632e380183ecaadc5a8d32c8018edec9864b786053eaeced7e9e326c207ffec8c61bf941835a3b0cae7fe65c57ee3e2986efbd23e2ea3a7c6fbe361a906fde28932e7910c37acece0e9fc218e15ece6d77cf29e0b7593b0c2fcf564e61de9ad9560e3d23e2ea3a7c6fbe36d981ceae3db50d0dc2929a1a3cce6d8388e32fae3987bfe9d031eb2b6ccfaad3e8918e9a3b56efa974375e2fe83aabe63981bfcf98966f995451eb2b6ccfab96d891aeb879e61f3db673eaea0a9edfe29e606eaf98e7df9d22051"
local K={91,192,196,163,136,144,77,236,116,143,141,251,15,151,242,109}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
