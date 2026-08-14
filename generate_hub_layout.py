from pathlib import Path
import json
import re

root = Path(__file__).parent
game = root / "Games" / "BloxFruits"
runtime = (game / "Source" / "Runtime.lua").read_text(encoding="utf-8")

titles = {
    "Settings": "Configurações",
    "Main": "Farm",
    "Melee": "Estilos de luta",
    "Quests": "Itens",
    "Valentine": "Valentine",
    "SeaEvent": "Eventos do mar",
    "Mirage": "Mirage e Race V4",
    "Drago": "Drago Dojo",
    "Prehistoric": "Prehistoric",
    "Raids": "Raids",
    "Combat": "Combate e PVP",
    "Travel": "Viagem",
    "Fruit": "Frutas",
    "Shop": "Loja",
    "Misc": "Outros"
}

tabs = {name: [] for name in titles}
patterns = [
    ("Toggle", r'Tabs\.(\w+):AddToggle\([^\n]*?Title\s*=\s*"([^"]+)"'),
    ("Button", r'Tabs\.(\w+):AddButton\(\{Title\s*=\s*"([^"]+)"'),
    ("Dropdown", r'Tabs\.(\w+):AddDropdown\([^\n]*?Title\s*=\s*"([^"]+)"'),
    ("Slider", r'Tabs\.(\w+):AddSlider\([^\n]*?Title\s*=\s*"([^"]+)"'),
    ("Input", r'Tabs\.(\w+):AddInput\([^\n]*?Title\s*=\s*"([^"]+)"')
]

items = []
for kind, pattern in patterns:
    for match in re.finditer(pattern, runtime):
        tab, title = match.groups()
        if tab in tabs:
            item = {"Type": kind, "Title": title, "Position": match.start()}
            if kind == "Slider":
                line = runtime[match.start():runtime.find("\n", match.start())]
                minimum = re.search(r'Min\s*=\s*([\d.]+)', line)
                maximum = re.search(r'Max\s*=\s*([\d.]+)', line)
                default = re.search(r'Default\s*=\s*([\d.]+)', line)
                item["Min"] = float(minimum.group(1)) if minimum else 0
                item["Max"] = float(maximum.group(1)) if maximum else 100
                item["Default"] = float(default.group(1)) if default else item["Min"]
            tabs[tab].append(item)

worlds = {"SeaEvent": "Sea3", "Mirage": "Sea3", "Drago": "Sea3", "Prehistoric": "Sea3", "Raids": "Sea2Sea3"}

# Tabs such as Farm, Items, Combat and Shop contain controls for several seas.
# Tagging each sea-specific control keeps the HUB focused on the current world
# while shared controls remain available everywhere.
control_worlds = {}

def only(world, *names):
    for name in names:
        control_worlds[name] = world

only("Sea1",
    "Auto Travel Dressrosa", "Auto Pole V1", "Auto Saw Sword", "Auto Saber Sword",
    "Auto Cybrog", "Auto Usoap's Hat", "Auto Bisento V2", "Auto Warden Sword",
    "Auto Marine Coat", "Auto Swan Coat")

only("Sea2",
    "Auto Zou Quest", "Auto Factory Raid", "Auto Farm Ectoplasm", "Auto Done Bartilo Quest",
    "Auto Observation V2", "Auto Upgrade Mink V3", "Auto Upgrade Human V3",
    "Auto Upgrade Skypiea V3", "Auto Upgrade FishMan V3", "Buy Legendary Sword",
    "Buy True Triple Katana Sword", "Tween to Legendary Sword Dealer", "Auto Pole V2 [Patched]",
    "Auto Law Sword", "Buy Microchip Law", "Start Law Raids", "Auto Rengoku Sword",
    "Auto Key Rengoku", "Auto Dragon Trident", "Auto Long Sword", "Auto Midnight Blade",
    "Auto Darkbeard", "Auto Unlocked DonSwan", "Auto Swan Glasses", "Esp Flower",
    "Esp Legendary Sword", "Buy Bizarre Rifle", "Buy Ghoul Mask", "Buy Ghoul Race (2.5k)")

only("Sea3",
    "Auto Pirate Raid", "Auto Done Citizen Quest", "Auto Training Dummy", "Auto Collect Berry",
    "Auto Cake Prince", "Auto Bones", "Auto Farm Mirror", "Auto Soul Reaper [Fully]",
    "Auto Random Bones", "Auto Try Luck Gravestone", "Auto Pray Gravestone",
    "Auto Unlock Dough dungeon", "Auto Unlock Phoenix dungeon", "Auto Teleport Barista Cousin",
    "Buy Buso Colors", "Auto Rainbow Colors", "Accept Rainbow Quest Faster", "Auto Valkyrie",
    "Auto Unlocked Puzzle", "Auto Elite Quest", "Stop when got God's Chalice",
    "Auto Tushita Sword", "Auto Yama Sword", "Auto Get CDK [ Last Quest ]", "Auto Yama CDK",
    "Auto Tushita CDK", "Auto Black Spikey", "Auto Dark Blade V3", "Auto Bigmom",
    "Auto Canvendish Sword", "Auto Twin Hooks", "Auto Serpent Bow", "Auto Lei Accessory",
    "Esp Berries", "Esp Gears", "Esp SeaEvent Island", "Esp Advanced Fruits Dealer",
    "Craft Dragonheart", "Craft Dragonstorm", "Craft DinoHood", "Craft SharkTooth",
    "Craft TerrorJaw", "Craft SharkAnchor", "Craft LeviathanCrown", "Craft LeviathanShield",
    "Craft LeviathanBoat", "Craft LegendaryScroll", "Craft MythicalScroll",
    "Turn on increase Boats")

only("Sea2Sea3", "Auto Unlock Phoenix dungeon", "Esp Aura Colour Dealers")
lines = ["return {"]
for name, label in titles.items():
    controls = sorted(tabs[name], key=lambda item: item["Position"])
    lines.append("{")
    lines.append(f'Key={json.dumps(name)},Title={json.dumps(label, ensure_ascii=False)},World={json.dumps(worlds.get(name, "All"))},Controls={{')
    for item in controls:
        fields = [f'Type={json.dumps(item["Type"])}', f'Title={json.dumps(item["Title"], ensure_ascii=False)}']
        fields.append(f'World={json.dumps(control_worlds.get(item["Title"], "All"))}')
        if item["Type"] == "Slider":
            fields += [f'Min={item["Min"]}', f'Max={item["Max"]}', f'Default={item["Default"]}']
        lines.append("{" + ",".join(fields) + "},")
    lines.append("}},")
lines.append("}")
(game / "HubLayout.lua").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
print(sum(len(value) for value in tabs.values()))
