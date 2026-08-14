_G.DragonSelectedModePreset = "AUTOMATIC"
local RuntimeSource = game:HttpGet(_G.DragonLinks.Runtime)
local RuntimeChunk, CompileError = loadstring(RuntimeSource)
if not RuntimeChunk then
    error("Falha ao compilar Runtime.lua: " .. tostring(CompileError))
end
RuntimeChunk()
