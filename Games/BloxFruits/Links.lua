local Root = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/Encrypted/"

return {
    Game = "Blox Fruits",
    UniverseIds = {994732206},
    Worlds = {
        Sea1 = {2753915549, 85211729168715},
        Sea2 = {4442272183, 79091703265657},
        Sea3 = {7449423635, 100117331123089}
    },
    UI = Root .. "UI.lua",
    Runtime = Root .. "Runtime.lua",
    Functions = "https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/Games/BloxFruits/Functions.lua",
    Modes = {
        AUTOMATIC = Root .. "Modes/Automatic.lua",
        HUB = Root .. "Modes/HUB.lua"
    },
    Modules = {
        Settings = Root .. "Modules/Settings.lua",
        Farm = Root .. "Modules/Farm.lua",
        Melee = Root .. "Modules/Melee.lua",
        Items = Root .. "Modules/Items.lua",
        Events = Root .. "Modules/Events.lua",
        Raids = Root .. "Modules/Raids.lua",
        Combat = Root .. "Modules/Combat.lua",
        Travel = Root .. "Modules/Travel.lua",
        Fruits = Root .. "Modules/Fruits.lua",
        Shop = Root .. "Modules/Shop.lua",
        Misc = Root .. "Modules/Misc.lua"
    }
}
