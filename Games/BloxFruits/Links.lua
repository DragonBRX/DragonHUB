local Root = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/Encrypted/"
local Version = "?v=" .. tostring(os.time())
local function Encrypted(Path)
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
    UI = Encrypted("UI.lua"),
    HubUI = Encrypted("HubUI.lua"),
    HubLayout = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/HubLayout.lua" .. Version,
    Runtime = Encrypted("Runtime.lua"),
    Functions = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/Functions.lua" .. Version,
    Modes = {
        AUTOMATIC = Encrypted("Modes/Automatic.lua"),
        HUB = Encrypted("Modes/HUB.lua")
    },
    Modules = {
        Settings = Encrypted("Modules/Settings.lua"),
        Farm = Encrypted("Modules/Farm.lua"),
        Melee = Encrypted("Modules/Melee.lua"),
        Items = Encrypted("Modules/Items.lua"),
        Events = Encrypted("Modules/Events.lua"),
        Raids = Encrypted("Modules/Raids.lua"),
        Combat = Encrypted("Modules/Combat.lua"),
        Travel = Encrypted("Modules/Travel.lua"),
        Fruits = Encrypted("Modules/Fruits.lua"),
        Shop = Encrypted("Modules/Shop.lua"),
        Misc = Encrypted("Modules/Misc.lua")
    }
}
