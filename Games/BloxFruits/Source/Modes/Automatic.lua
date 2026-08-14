_G.DragonSelectedModePreset = "AUTOMATIC"
_G.DragonLoadedFeatureModules = _G.DragonLoadedFeatureModules or {}

for Name, Link in pairs(_G.DragonLinks.Modules or {}) do
    local Success, Module = pcall(function()
        return loadstring(game:HttpGet(Link))()
    end)
    if Success then _G.DragonLoadedFeatureModules[Name] = Module or true end
end

loadstring(game:HttpGet(_G.DragonLinks.Runtime))()
