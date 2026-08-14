local Registry = {
    {
        UniverseIds = {994732206},
        PlaceIds = {2753915549, 85211729168715, 4442272183, 79091703265657, 7449423635, 100117331123089},
        Manifest = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/Links.lua"
    }
}

local function Contains(List, Value)
    for _, Item in ipairs(List or {}) do
        if Item == Value then return true end
    end
    return false
end

local Selected
for _, Entry in ipairs(Registry) do
    if Contains(Entry.UniverseIds, game.GameId) or Contains(Entry.PlaceIds, game.PlaceId) then
        Selected = Entry
        break
    end
end

if not Selected then
    game:GetService("Players").LocalPlayer:Kick("DragonHUB | Jogo não suportado")
    return
end

local Links = loadstring(game:HttpGet(Selected.Manifest))()
_G.DragonLinks = Links
loadstring(game:HttpGet(Links.UI))()
local ModeLink = Links.Modes and Links.Modes[_G.DragonSelectedMode]
if not ModeLink then error("DragonHUB | Modo inválido") end
loadstring(game:HttpGet(ModeLink))()
