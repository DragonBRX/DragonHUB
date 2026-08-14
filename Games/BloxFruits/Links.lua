local Root = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/Source/"
local Version = "?v=" .. tostring(os.time())
local function Source(Path)
    return Root .. Path .. Version
end

return {
    Game = "Blox Fruits",
    UniverseIds = {994732206},
    Worlds = {
        Sea1 = {2753915549, 85211729168715},
        Sea2 = {4442272183, 79091703265657},
        Sea3 = {7449423635, 100117331123089}
    },
    UI = Source("UI.lua"),
    HubUI = Source("HubUI.lua"),
    HubLayout = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/HubLayout.lua" .. Version,
    Runtime = Source("Runtime.lua"),
    Modes = {
        AUTOMATIC = Source("Modes/Automatic.lua"),
        HUB = Source("Modes/HUB.lua")
    }
}
