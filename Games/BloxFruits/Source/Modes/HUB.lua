_G.DragonSelectedModePreset = "HUB"
_G.DragonHubLayout = loadstring(game:HttpGet(_G.DragonLinks.HubLayout))()
_G.DragonExternalHubUI = true
_G.DragonHubRuntimeError = nil
loadstring(game:HttpGet(_G.DragonLinks.HubUI))()
task.spawn(function()
    local Success, Error = pcall(function()
        local RuntimeSource = game:HttpGet(_G.DragonLinks.Runtime)
        local RuntimeChunk, CompileError = loadstring(RuntimeSource)
        if not RuntimeChunk then
            error("Falha ao compilar Runtime.lua: " .. tostring(CompileError))
        end
        RuntimeChunk()
    end)
    if not Success then
        _G.DragonHubRuntimeError = tostring(Error)
    end
end)
