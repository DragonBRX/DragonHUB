_G.DragonSelectedModePreset = "HUB"
_G.DragonHubLayout = loadstring(game:HttpGet(_G.DragonLinks.HubLayout))()
_G.DragonExternalHubUI = true
loadstring(game:HttpGet(_G.DragonLinks.HubUI))()
task.spawn(function()
    local Success, Error = pcall(function()
        loadstring(game:HttpGet(_G.DragonLinks.Runtime))()
    end)
    if not Success then
        _G.DragonHubRuntimeError = tostring(Error)
    end
end)
