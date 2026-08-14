repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════════════
--  DETECTAR O MAR (SEA)
-- ═══════════════════════════════════════════════════════════════════════════════

local PlaceId = game.PlaceId
local World1 = PlaceId == 2753915549
local World2 = PlaceId == 4442272183
local World3 = PlaceId == 7449423635

if not (World1 or World2 or World3) then
    warn("[DragonHUB] Jogo não reconhecido!")
    return
end

local SeaName = World1 and "Sea 1" or World2 and "Sea 2" or "Sea 3"
print("[DragonHUB] Detectado: " .. SeaName)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SERVIÇOS
-- ═══════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local CommF_ = ReplicatedStorage.Remotes.CommF_
local CommE = ReplicatedStorage.Remotes.CommE

-- ═══════════════════════════════════════════════════════════════════════════════
--  FLAGS GLOBAIS DE CONTROLE
-- ═══════════════════════════════════════════════════════════════════════════════

_G.AutoFarm = false
_G.ScriptRodando = false
_G.FecharTudo = false

-- Configurações automáticas (o script decide sozinho)
_G.Config = {
    BringMonster = true,
    BringMode = 375,
    FastAttack = true,
    FastAttackDelay = 0.03,
    AutoHakiKen = true,
    AutoBuso = true,
    AutoStats = true,
    StatPriority = "Melee",
    KillAt = 25,
    BypassTP = true,
    PosY = 30
}

-- Variáveis de estado
local Mon, NameQuest, LevelQuest, CFrameQuest, CFrameMon, NameMon
local MyLevel = 1
local StartMagnet = false
local PosMon = CFrame.new(0, 30, 0)
local Type = 1
local Pos = CFrame.new(0, 30, 0)

-- ═══════════════════════════════════════════════════════════════════════════════
--  FUNÇÕES UTILITÁRIAS BÁSICAS
-- ═══════════════════════════════════════════════════════════════════════════════

local function GetChar()
    return LocalPlayer.Character
end

local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetDistance(target)
    local hrp = GetHRP()
    if not hrp then return math.huge end
    return (target.Position - hrp.Position).Magnitude
end

local function HasWeapon(name)
    return LocalPlayer.Backpack:FindFirstChild(name) or LocalPlayer.Character:FindFirstChild(name)
end

local function CheckItem(name)
    for _, v in pairs(CommF_:InvokeServer("getInventory")) do
        if v.Name == name then return v end
    end
    return nil
end

local function CheckMaterial(name)
    for _, v in pairs(CommF_:InvokeServer("getInventory")) do
        if v.Type == "Material" and v.Name == name then
            return v.Count
        end
    end
    return 0
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE TELEPORTE
-- ═══════════════════════════════════════════════════════════════════════════════

local function TP(Pos)
    local hrp = GetHRP()
    if not hrp then return end
    local dist = (Pos.Position - hrp.Position).Magnitude
    
    if dist > 2000 then
        hrp.CFrame = Pos
        return
    end
    
    local speed = dist < 25 and 20000
        or dist < 50 and 10000
        or dist < 150 and 5000
        or dist < 250 and 2500
        or dist < 500 and 1250
        or dist < 750 and 625
        or 400
    
    TweenService:Create(hrp, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = Pos}):Play()
end

local function TP1(Pos)
    local hrp = GetHRP()
    if not hrp then return end
    local dist = (Pos.Position - hrp.Position).Magnitude
    
    if dist <= 250 then
        hrp.CFrame = Pos
        return
    end
    
    TweenService:Create(hrp, TweenInfo.new(dist / 325, Enum.EasingStyle.Linear), {CFrame = Pos}):Play()
end

local function BTP(P)
    repeat
        task.wait(0.1)
        local hrp = GetHRP()
        if hrp then
            local hum = GetHumanoid()
            if hum then hum:ChangeState(15) end
            hrp.CFrame = P
            task.wait()
            hrp.CFrame = P
        end
    until not GetHRP() or (P.Position - GetHRP().Position).Magnitude <= 1500
end

local function topos(Pos)
    local hrp = GetHRP()
    if not hrp then return end
    local dist = (Pos.Position - hrp.Position).Magnitude
    
    if dist <= 250 then
        hrp.CFrame = Pos
        return
    end
    
    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 210, Enum.EasingStyle.Linear), {CFrame = Pos})
    tween:Play()
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE EQUIPAR ARMAS
-- ═══════════════════════════════════════════════════════════════════════════════

local NotAutoEquip_flag = false

local function UnEquipWeapon(name)
    NotAutoEquip_flag = true
    pcall(function()
        local tool = LocalPlayer.Character:FindFirstChild(name) or LocalPlayer.Backpack:FindFirstChild(name)
        if tool then tool.Parent = LocalPlayer.Backpack end
    end)
    task.wait(0.2)
    NotAutoEquip_flag = false
end

local function EquipWeapon(name)
    if NotAutoEquip_flag then return end
    pcall(function()
        local tool = LocalPlayer.Backpack:FindFirstChild(name)
        if tool then
            LocalPlayer.Character.Humanoid:EquipTool(tool)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE HAKI
-- ═══════════════════════════════════════════════════════════════════════════════

local function AutoHaki()
    pcall(function()
        if _G.Config.AutoBuso and not LocalPlayer.Character:FindFirstChild("HasBuso") then
            CommF_:InvokeServer("Buso")
        end
    end)
end

spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.Config.AutoHakiKen then
                CommE:FireServer("Ken", true)
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE FAST ATTACK (CORRIGIDO)
-- ═══════════════════════════════════════════════════════════════════════════════

local function AttackFunction()
    pcall(function()
        if not _G.Config.FastAttack then return end
        
        local cf = require(LocalPlayer.PlayerScripts.CombatFramework)
        local upvs = debug.getupvalues(cf)
        local controller = nil
        
        for _, v in pairs(upvs) do
            if typeof(v) == "table" and v.activeController then
                controller = v.activeController
                break
            end
        end
        
        if controller and controller.active then
            controller.active = false
            controller.timeToNextAttack = 0
            controller.hitboxMagnitude = 60
            controller.timeToNextBlock = 0
            controller.blocking = false
            controller.attacking = false
            controller.increment = 3
        end
        
        local char = GetChar()
        if char then
            local stun = char:FindFirstChild("Stun")
            if stun then stun.Value = 0 end
            local busy = char:FindFirstChild("Busy")
            if busy then busy.Value = false end
        end
    end)
end

spawn(function()
    while task.wait(0.03) do
        if _G.Config.FastAttack and _G.AutoFarm then
            pcall(AttackFunction)
        end
    end
end)

spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and _G.Config.FastAttack then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(1280, 672))
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE BRING MOBS
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    local rot = 0
    while task.wait(0.1) do
        rot = (rot + 1) % 5
        local offset = ({
            CFrame.new(0, _G.Config.PosY, 0),
            CFrame.new(0, _G.Config.PosY, -30),
            CFrame.new(30, _G.Config.PosY, 0),
            CFrame.new(0, _G.Config.PosY, 30),
            CFrame.new(-30, _G.Config.PosY, 0),
        })[rot + 1]
        local hrp = GetHRP()
        if hrp then
            PosMon = hrp.CFrame * offset
        end
    end
end)

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if not _G.AutoFarm or not _G.Config.BringMonster then return end
            if not Mon then return end
            local hrp = GetHRP()
            if not hrp then return end
            
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == Mon and v:FindFirstChild("Humanoid") 
                    and v:FindFirstChild("HumanoidRootPart") 
                    and v.Humanoid.Health > 0 
                    and (v.HumanoidRootPart.Position - hrp.Position).Magnitude <= _G.Config.BringMode then
                    
                    v.HumanoidRootPart.CFrame = PosMon
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.HumanoidRootPart.CanCollide = false
                    v.Humanoid.WalkSpeed = 0
                    v.Humanoid:ChangeState(14)
                    
                    if v.Humanoid:FindFirstChild("Animator") then
                        v.Humanoid.Animator:Destroy()
                    end
                    
                    pcall(function()
                        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                    end)
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE NOCLIP
-- ═══════════════════════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    if _G.AutoFarm then
        local c = GetChar()
        if not c then return end
        
        if not Workspace:FindFirstChild("AutoFarmFloor") then
            local f = Instance.new("Part")
            f.Name = "AutoFarmFloor"
            f.Parent = Workspace
            f.Anchored = true
            f.Transparency = 1
            f.Size = Vector3.new(30, 0.5, 30)
            f.CanCollide = true
        end
        
        local floor = Workspace:FindFirstChild("AutoFarmFloor")
        if floor then
            floor.CFrame = c.HumanoidRootPart.CFrame * CFrame.new(0, -3.6, 0)
        end
        
        if not c.HumanoidRootPart:FindFirstChild("BodyClip") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "BodyClip"
            bv.Parent = c.HumanoidRootPart
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    else
        local floor = Workspace:FindFirstChild("AutoFarmFloor")
        if floor then floor:Destroy() end
        local hrp = GetHRP()
        if hrp then
            local bv = hrp:FindFirstChild("BodyClip")
            if bv then bv:Destroy() end
        end
    end
end)

RunService.Stepped:Connect(function()
    if _G.AutoFarm then
        pcall(function()
            local c = GetChar()
            if not c then return end
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS COMPLETO - SEA 1
-- ═══════════════════════════════════════════════════════════════════════════════

local QuestMap_Sea1 = {
    {minLv = 1, maxLv = 9, mon = "Bandit", quest = "BanditQuest1", questLv = 1,
     qpos = CFrame.new(1059.37195, 15.4495068, 1550.4231),
     mpos = CFrame.new(1045.962646, 27.002508, 1560.8203125)},
    {minLv = 10, maxLv = 14, mon = "Monkey", quest = "JungleQuest", questLv = 1,
     qpos = CFrame.new(-1598.08911, 35.5501175, 153.377838),
     mpos = CFrame.new(-1448.518066, 67.853012, 11.465796)},
    {minLv = 15, maxLv = 29, mon = "Gorilla", quest = "JungleQuest", questLv = 2,
     qpos = CFrame.new(-1598.08911, 35.5501175, 153.377838),
     mpos = CFrame.new(-1129.883667, 40.463546, -525.423706)},
    {minLv = 30, maxLv = 39, mon = "Pirate", quest = "BuggyQuest1", questLv = 1,
     qpos = CFrame.new(-1141.07483, 4.10001802, 3831.5498),
     mpos = CFrame.new(-1103.513427, 13.752052, 3896.091064)},
    {minLv = 40, maxLv = 59, mon = "Brute", quest = "BuggyQuest1", questLv = 2,
     qpos = CFrame.new(-1141.07483, 4.10001802, 3831.5498),
     mpos = CFrame.new(-1140.083740, 14.809885, 4322.921386)},
    {minLv = 60, maxLv = 74, mon = "Desert Bandit", quest = "DesertQuest", questLv = 1,
     qpos = CFrame.new(894.488647, 5.14000702, 4392.43359),
     mpos = CFrame.new(924.799804, 6.448674, 4481.585937)},
    {minLv = 75, maxLv = 89, mon = "Desert Officer", quest = "DesertQuest", questLv = 2,
     qpos = CFrame.new(894.488647, 5.14000702, 4392.43359),
     mpos = CFrame.new(1608.282226, 8.614224, 4371.007324)},
    {minLv = 90, maxLv = 99, mon = "Snow Bandit", quest = "SnowQuest", questLv = 1,
     qpos = CFrame.new(1389.74451, 88.1519318, -1298.90796),
     mpos = CFrame.new(1354.347900, 87.272773, -1393.946533)},
    {minLv = 100, maxLv = 119, mon = "Snowman", quest = "SnowQuest", questLv = 2,
     qpos = CFrame.new(1389.74451, 88.1519318, -1298.90796),
     mpos = CFrame.new(1201.641235, 144.579589, -1550.067016)},
    {minLv = 120, maxLv = 149, mon = "Chief Petty Officer", quest = "MarineQuest2", questLv = 1,
     qpos = CFrame.new(-5039.58643, 27.3500385, 4324.68018),
     mpos = CFrame.new(-4881.230957, 22.652044, 4273.752441)},
    {minLv = 150, maxLv = 174, mon = "Sky Bandit", quest = "SkyQuest", questLv = 1,
     qpos = CFrame.new(-4839.53027, 716.368591, -2619.44165),
     mpos = CFrame.new(-4953.207031, 295.744201, -2899.229003)},
    {minLv = 175, maxLv = 189, mon = "Dark Master", quest = "SkyQuest", questLv = 2,
     qpos = CFrame.new(-4839.53027, 716.368591, -2619.44165),
     mpos = CFrame.new(-5259.844726, 391.397674, -2229.035400)},
    {minLv = 190, maxLv = 209, mon = "Prisoner", quest = "PrisonerQuest", questLv = 1,
     qpos = CFrame.new(5308.93115, 1.65517521, 475.120514),
     mpos = CFrame.new(5098.973632, -0.320405, 474.237335)},
    {minLv = 210, maxLv = 249, mon = "Dangerous Prisoner", quest = "PrisonerQuest", questLv = 2,
     qpos = CFrame.new(5308.93115, 1.65517521, 475.120514),
     mpos = CFrame.new(5654.563476, 15.633401, 866.299194)},
    {minLv = 250, maxLv = 274, mon = "Toga Warrior", quest = "ColosseumQuest", questLv = 1,
     qpos = CFrame.new(-1580.04663, 6.35000277, -2986.47534),
     mpos = CFrame.new(-1820.214843, 51.683856, -2740.665039)},
    {minLv = 275, maxLv = 299, mon = "Gladiator", quest = "ColosseumQuest", questLv = 2,
     qpos = CFrame.new(-1580.04663, 6.35000277, -2986.47534),
     mpos = CFrame.new(-1292.838134, 56.380882, -3339.031494)},
    {minLv = 300, maxLv = 324, mon = "Military Soldier", quest = "MagmaQuest", questLv = 1,
     qpos = CFrame.new(-5313.37012, 10.9500084, 8515.29395),
     mpos = CFrame.new(-5411.164550, 11.081554, 8454.292968)},
    {minLv = 325, maxLv = 374, mon = "Military Spy", quest = "MagmaQuest", questLv = 2,
     qpos = CFrame.new(-5313.37012, 10.9500084, 8515.29395),
     mpos = CFrame.new(-5802.868164, 86.262413, 8828.859375)},
    {minLv = 375, maxLv = 399, mon = "Fishman Warrior", quest = "FishmanQuest", questLv = 1,
     entrance = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875),
     qpos = CFrame.new(61122.652343, 18.497442, 1569.399780),
     mpos = CFrame.new(60878.300781, 18.482830, 1543.757446)},
    {minLv = 400, maxLv = 449, mon = "Fishman Commando", quest = "FishmanQuest", questLv = 2,
     entrance = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875),
     qpos = CFrame.new(61122.652343, 18.497442, 1569.399780),
     mpos = CFrame.new(61922.632812, 18.482830, 1493.934326)},
    {minLv = 450, maxLv = 474, mon = "God's Guard", quest = "SkyExp1Quest", questLv = 1,
     entrance = Vector3.new(-4607.82275, 872.54248, -1667.55688),
     qpos = CFrame.new(-4721.88867, 843.874695, -1949.96643),
     mpos = CFrame.new(-4710.042968, 845.276977, -1927.307983)},
    {minLv = 475, maxLv = 524, mon = "Shanda", quest = "SkyExp1Quest", questLv = 2,
     entrance = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047),
     qpos = CFrame.new(-7859.09814, 5544.19043, -381.476196),
     mpos = CFrame.new(-7678.489746, 5566.403808, -497.215606)},
    {minLv = 525, maxLv = 549, mon = "Royal Squad", quest = "SkyExp2Quest", questLv = 1,
     qpos = CFrame.new(-7906.81592, 5634.6626, -1411.99194),
     mpos = CFrame.new(-7624.252441, 5658.133300, -1467.354248)},
    {minLv = 550, maxLv = 624, mon = "Royal Soldier", quest = "SkyExp2Quest", questLv = 2,
     qpos = CFrame.new(-7906.81592, 5634.6626, -1411.99194),
     mpos = CFrame.new(-7836.753417, 5645.664062, -1790.623657)},
    {minLv = 625, maxLv = 649, mon = "Galley Pirate", quest = "FountainQuest", questLv = 1,
     qpos = CFrame.new(5259.81982, 37.3500175, 4050.0293),
     mpos = CFrame.new(5551.021972, 78.901351, 3930.412841)},
    {minLv = 650, maxLv = 700, mon = "Galley Captain", quest = "FountainQuest", questLv = 2,
     qpos = CFrame.new(5259.81982, 37.3500175, 4050.0293),
     mpos = CFrame.new(5441.951660, 42.502059, 4950.09375)},
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS COMPLETO - SEA 2
-- ═══════════════════════════════════════════════════════════════════════════════

local QuestMap_Sea2 = {
    {minLv = 700, maxLv = 724, mon = "Raider", quest = "Area1Quest", questLv = 1,
     qpos = CFrame.new(-429.543518, 71.7699966, 1836.18188),
     mpos = CFrame.new(-728.326721, 52.779319, 2345.770507)},
    {minLv = 725, maxLv = 774, mon = "Mercenary", quest = "Area1Quest", questLv = 2,
     qpos = CFrame.new(-429.543518, 71.7699966, 1836.18188),
     mpos = CFrame.new(-1004.324401, 80.158866, 1424.619384)},
    {minLv = 775, maxLv = 799, mon = "Swan Pirate", quest = "Area2Quest", questLv = 1,
     qpos = CFrame.new(638.43811, 71.769989, 918.282898),
     mpos = CFrame.new(1068.664306, 137.614288, 1322.106079)},
    {minLv = 800, maxLv = 874, mon = "Factory Staff", quest = "Area2Quest", questLv = 2,
     qpos = CFrame.new(632.698608, 73.1055908, 918.666321),
     mpos = CFrame.new(73.078674, 81.863441, -27.470672)},
    {minLv = 875, maxLv = 899, mon = "Marine Lieutenant", quest = "MarineQuest3", questLv = 1,
     qpos = CFrame.new(-2440.79639, 71.7140732, -3216.06812),
     mpos = CFrame.new(-2821.372314, 75.897277, -3070.089111)},
    {minLv = 900, maxLv = 949, mon = "Marine Captain", quest = "MarineQuest3", questLv = 2,
     qpos = CFrame.new(-2440.79639, 71.7140732, -3216.06812),
     mpos = CFrame.new(-1861.231079, 80.176582, -3254.697509)},
    {minLv = 950, maxLv = 974, mon = "Zombie", quest = "ZombieQuest", questLv = 1,
     qpos = CFrame.new(-5497.06152, 47.5923004, -795.237061),
     mpos = CFrame.new(-5657.776855, 78.969734, -928.687011)},
    {minLv = 975, maxLv = 999, mon = "Vampire", quest = "ZombieQuest", questLv = 2,
     qpos = CFrame.new(-5497.06152, 47.5923004, -795.237061),
     mpos = CFrame.new(-6037.667968, 32.184638, -1340.659790)},
    {minLv = 1000, maxLv = 1049, mon = "Snow Trooper", quest = "SnowMountainQuest", questLv = 1,
     qpos = CFrame.new(609.858826, 400.119904, -5372.25928),
     mpos = CFrame.new(549.147338, 427.387054, -5563.698730)},
    {minLv = 1050, maxLv = 1099, mon = "Winter Warrior", quest = "SnowMountainQuest", questLv = 2,
     qpos = CFrame.new(609.858826, 400.119904, -5372.25928),
     mpos = CFrame.new(1142.745117, 475.639801, -5199.416503)},
    {minLv = 1100, maxLv = 1124, mon = "Lab Subordinate", quest = "IceSideQuest", questLv = 1,
     qpos = CFrame.new(-6064.06885, 15.2422857, -4902.97852),
     mpos = CFrame.new(-5707.471679, 15.951709, -4513.392089)},
    {minLv = 1125, maxLv = 1174, mon = "Horned Warrior", quest = "IceSideQuest", questLv = 2,
     qpos = CFrame.new(-6064.06885, 15.2422857, -4902.97852),
     mpos = CFrame.new(-6341.366699, 15.951770, -5723.162109)},
    {minLv = 1175, maxLv = 1199, mon = "Magma Ninja", quest = "FireSideQuest", questLv = 1,
     qpos = CFrame.new(-5428.03174, 15.0622921, -5299.43457),
     mpos = CFrame.new(-5449.672851, 76.658744, -5808.200683)},
    {minLv = 1200, maxLv = 1249, mon = "Lava Pirate", quest = "FireSideQuest", questLv = 2,
     qpos = CFrame.new(-5428.03174, 15.0622921, -5299.43457),
     mpos = CFrame.new(-5213.331542, 49.737880, -4701.451171)},
    {minLv = 1250, maxLv = 1274, mon = "Ship Deckhand", quest = "ShipQuest1", questLv = 1,
     entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
     qpos = CFrame.new(1037.80127, 125.092171, 32911.6016),
     mpos = CFrame.new(1212.011108, 150.792053, 33059.246093)},
    {minLv = 1275, maxLv = 1299, mon = "Ship Engineer", quest = "ShipQuest1", questLv = 2,
     entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
     qpos = CFrame.new(1037.80127, 125.092171, 32911.6016),
     mpos = CFrame.new(919.478637, 43.544013, 32779.96875)},
    {minLv = 1300, maxLv = 1324, mon = "Ship Steward", quest = "ShipQuest2", questLv = 1,
     entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
     qpos = CFrame.new(968.80957, 125.092171, 33244.125),
     mpos = CFrame.new(919.438537, 129.555999, 33436.035156)},
    {minLv = 1325, maxLv = 1349, mon = "Ship Officer", quest = "ShipQuest2", questLv = 2,
     entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
     qpos = CFrame.new(968.80957, 125.092171, 33244.125),
     mpos = CFrame.new(1036.017944, 181.439041, 33315.726562)},
    {minLv = 1350, maxLv = 1374, mon = "Arctic Warrior", quest = "FrostQuest", questLv = 1,
     entrance = Vector3.new(-6508.5581054688, 5000.034996032715, -132.83953857422),
     qpos = CFrame.new(5667.6582, 26.7997818, -6486.08984),
     mpos = CFrame.new(5966.246093, 62.970020, -6179.382812)},
    {minLv = 1375, maxLv = 1424, mon = "Snow Lurker", quest = "FrostQuest", questLv = 2,
     entrance = Vector3.new(-6508.5581054688, 5000.034996032715, -132.83953857422),
     qpos = CFrame.new(5667.6582, 26.7997818, -6486.08984),
     mpos = CFrame.new(5407.073730, 69.194374, -6880.880371)},
    {minLv = 1425, maxLv = 1449, mon = "Sea Soldier", quest = "ForgottenQuest", questLv = 1,
     qpos = CFrame.new(-3054.44458, 235.544281, -10142.8193),
     mpos = CFrame.new(-3028.223632, 64.674514, -9775.426757)},
    {minLv = 1450, maxLv = 9999, mon = "Water Fighter", quest = "ForgottenQuest", questLv = 2,
     qpos = CFrame.new(-3054.44458, 235.544281, -10142.8193),
     mpos = CFrame.new(-3352.901367, 285.015563, -10534.841796)},
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS COMPLETO - SEA 3
-- ═══════════════════════════════════════════════════════════════════════════════

local QuestMap_Sea3 = {
    {minLv = 1500, maxLv = 1524, mon = "Pirate Millionaire", quest = "PiratePortQuest", questLv = 1,
     qpos = CFrame.new(-290.074677, 42.9034653, 5581.58984),
     mpos = CFrame.new(-245.996383, 47.3061523, 5584.100585)},
    {minLv = 1525, maxLv = 1574, mon = "Pistol Billionaire", quest = "PiratePortQuest", questLv = 2,
     qpos = CFrame.new(-290.074677, 42.9034653, 5581.58984),
     mpos = CFrame.new(-187.330154, 86.2398757, 6013.513671)},
    {minLv = 1575, maxLv = 1599, mon = "Dragon Crew Warrior", quest = "AmazonQuest", questLv = 1,
     qpos = CFrame.new(5832.83594, 51.6806107, -1101.51563),
     mpos = CFrame.new(6141.140625, 51.3513641, -1340.738525)},
    {minLv = 1600, maxLv = 1624, mon = "Dragon Crew Archer", quest = "AmazonQuest", questLv = 2,
     qpos = CFrame.new(5833.1147460938, 51.60498046875, -1103.0693359375),
     mpos = CFrame.new(6616.417480, 441.767059, 446.046997)},
    {minLv = 1625, maxLv = 1649, mon = "Female Islander", quest = "AmazonQuest2", questLv = 1,
     entrance = Vector3.new(5446.8793945313, 601.62945556641, 749.45672607422),
     qpos = CFrame.new(5446.879394, 601.629455, 749.456726),
     mpos = CFrame.new(4685.258300, 735.807800, 815.342590)},
    {minLv = 1650, maxLv = 1699, mon = "Giant Islander", quest = "AmazonQuest2", questLv = 2,
     entrance = Vector3.new(5446.8793945313, 601.62945556641, 749.45672607422),
     qpos = CFrame.new(5446.879394, 601.629455, 749.456726),
     mpos = CFrame.new(4729.094238, 590.436767, -36.976276)},
    {minLv = 1700, maxLv = 1724, mon = "Marine Commodore", quest = "MarineTreeIsland", questLv = 1,
     qpos = CFrame.new(2180.54126, 27.8156815, -6741.5498),
     mpos = CFrame.new(2286.007812, 73.1339187, -7159.809082)},
    {minLv = 1725, maxLv = 1774, mon = "Marine Rear Admiral", quest = "MarineTreeIsland", questLv = 2,
     qpos = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813),
     mpos = CFrame.new(3656.773681, 160.524063, -7001.598632)},
    {minLv = 1775, maxLv = 1799, mon = "Fishman Raider", quest = "DeepForestIsland3", questLv = 1,
     qpos = CFrame.new(-10581.6563, 330.872955, -8761.18652),
     mpos = CFrame.new(-10407.526367, 331.762634, -8368.516601)},
    {minLv = 1800, maxLv = 1824, mon = "Fishman Captain", quest = "DeepForestIsland3", questLv = 2,
     qpos = CFrame.new(-10581.6563, 330.872955, -8761.18652),
     mpos = CFrame.new(-10994.701171, 352.381408, -9002.110351)},
    {minLv = 1825, maxLv = 1849, mon = "Forest Pirate", quest = "DeepForestIsland", questLv = 1,
     entrance = Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375),
     qpos = CFrame.new(-13234.04, 331.488495, -7625.40137),
     mpos = CFrame.new(-13274.478515, 332.378143, -7769.580566)},
    {minLv = 1850, maxLv = 1899, mon = "Mythological Pirate", quest = "DeepForestIsland", questLv = 2,
     entrance = Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375),
     qpos = CFrame.new(-13234.04, 331.488495, -7625.40137),
     mpos = CFrame.new(-13680.607421, 501.081542, -6991.189453)},
    {minLv = 1900, maxLv = 1924, mon = "Jungle Pirate", quest = "DeepForestIsland2", questLv = 1,
     entrance = Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375),
     qpos = CFrame.new(-12680.3818, 389.971039, -9902.01953),
     mpos = CFrame.new(-12256.160156, 331.738281, -10485.836914)},
    {minLv = 1925, maxLv = 1974, mon = "Musketeer Pirate", quest = "DeepForestIsland2", questLv = 2,
     entrance = Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375),
     qpos = CFrame.new(-12680.3818, 389.971039, -9902.01953),
     mpos = CFrame.new(-13457.904296, 391.545654, -9859.177734)},
    {minLv = 1975, maxLv = 1999, mon = "Reborn Skeleton", quest = "HauntedQuest1", questLv = 1,
     qpos = CFrame.new(-9479.2168, 141.215088, 5566.09277),
     mpos = CFrame.new(-8763.723632, 165.722991, 6159.861816)},
    {minLv = 2000, maxLv = 2024, mon = "Living Zombie", quest = "HauntedQuest1", questLv = 2,
     qpos = CFrame.new(-9479.2168, 141.215088, 5566.09277),
     mpos = CFrame.new(-10144.131835, 138.626678, 5838.088867)},
    {minLv = 2025, maxLv = 2049, mon = "Demonic Soul", quest = "HauntedQuest2", questLv = 1,
     qpos = CFrame.new(-9516.99316, 172.017181, 6078.46533),
     mpos = CFrame.new(-9505.872070, 172.104827, 6158.993164)},
    {minLv = 2050, maxLv = 2074, mon = "Posessed Mummy", quest = "HauntedQuest2", questLv = 2,
     qpos = CFrame.new(-9516.99316, 172.017181, 6078.46533),
     mpos = CFrame.new(-9582.022460, 6.25152730, 6205.478515)},
    {minLv = 2075, maxLv = 2099, mon = "Peanut Scout", quest = "NutsIslandQuest", questLv = 1,
     qpos = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875),
     mpos = CFrame.new(-2143.241943, 47.7219848, -10029.995117)},
    {minLv = 2100, maxLv = 2124, mon = "Peanut President", quest = "NutsIslandQuest", questLv = 2,
     qpos = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875),
     mpos = CFrame.new(-1859.354003, 38.1031684, -10422.429687)},
    {minLv = 2125, maxLv = 2149, mon = "Ice Cream Chef", quest = "IceCreamIslandQuest", questLv = 1,
     qpos = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438),
     mpos = CFrame.new(-872.24658203125, 65.8195724, -10919.957031)},
    {minLv = 2150, maxLv = 2199, mon = "Ice Cream Commander", quest = "IceCreamIslandQuest", questLv = 2,
     qpos = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438),
     mpos = CFrame.new(-558.06103515625, 112.048957, -11290.774414)},
    {minLv = 2200, maxLv = 2224, mon = "Cookie Crafter", quest = "CakeQuest1", questLv = 1,
     qpos = CFrame.new(-2021.32007, 37.7982254, -12028.7295),
     mpos = CFrame.new(-2374.136718, 37.7982635, -12125.308593)},
    {minLv = 2225, maxLv = 2249, mon = "Cake Guard", quest = "CakeQuest1", questLv = 2,
     qpos = CFrame.new(-2021.32007, 37.7982254, -12028.7295),
     mpos = CFrame.new(-1598.3070068359375, 43.7731971, -12244.581054)},
    {minLv = 2250, maxLv = 2274, mon = "Baking Staff", quest = "CakeQuest2", questLv = 1,
     qpos = CFrame.new(-1927.91602, 37.7981339, -12842.5391),
     mpos = CFrame.new(-1887.8099365234375, 77.6185073, -12998.350585)},
    {minLv = 2275, maxLv = 2299, mon = "Head Baker", quest = "CakeQuest2", questLv = 2,
     qpos = CFrame.new(-1927.91602, 37.7981339, -12842.5391),
     mpos = CFrame.new(-2216.188232421875, 82.8845214, -12869.293945)},
    {minLv = 2300, maxLv = 2324, mon = "Cocoa Warrior", quest = "ChocQuest1", questLv = 1,
     qpos = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375),
     mpos = CFrame.new(-21.55328369140625, 80.5749969, -12352.387695)},
    {minLv = 2325, maxLv = 2349, mon = "Chocolate Bar Battler", quest = "ChocQuest1", questLv = 2,
     qpos = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375),
     mpos = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109)},
    {minLv = 2350, maxLv = 2374, mon = "Sweet Thief", quest = "ChocQuest2", questLv = 1,
     qpos = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875),
     mpos = CFrame.new(165.1884765625, 76.05885314941406, -12600.836914)},
    {minLv = 2375, maxLv = 2399, mon = "Candy Rebel", quest = "ChocQuest2", questLv = 2,
     qpos = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875),
     mpos = CFrame.new(134.86563110351562, 77.2476806640625, -12876.547851)},
    {minLv = 2400, maxLv = 2424, mon = "Candy Pirate", quest = "CandyQuest1", questLv = 1,
     qpos = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375),
     mpos = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296)},
    {minLv = 2425, maxLv = 2449, mon = "Snow Demon", quest = "CandyQuest1", questLv = 2,
     qpos = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375),
     mpos = CFrame.new(-880.2006225585938, 71.24776458740234, -14538.609375)},
    {minLv = 2450, maxLv = 2474, mon = "Isle Outlaw", quest = "TikiQuest1", questLv = 1,
     qpos = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812),
     mpos = CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656)},
    {minLv = 2475, maxLv = 2499, mon = "Island Boy", quest = "TikiQuest1", questLv = 2,
     qpos = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812),
     mpos = CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351562)},
    {minLv = 2500, maxLv = 2524, mon = "Sun-kissed Warrior", quest = "TikiQuest2", questLv = 1,
     qpos = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625),
     mpos = CFrame.new(-16349.8779296875, 92.0808334350586, 1123.4169921875)},
    {minLv = 2525, maxLv = 9999, mon = "Isle Champion", quest = "TikiQuest2", questLv = 2,
     qpos = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625),
     mpos = CFrame.new(-16347.4150390625, 92.09503936767578, 1122.335205078125)},
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  FUNÇÃO CHECK QUEST
-- ═══════════════════════════════════════════════════════════════════════════════

local CurrentQuestData = nil

local function CheckQuest()
    MyLevel = LocalPlayer.Data.Level.Value
    local map = World1 and QuestMap_Sea1 or World2 and QuestMap_Sea2 or QuestMap_Sea3
    for _, data in ipairs(map) do
        if MyLevel >= data.minLv and MyLevel <= data.maxLv then
            CurrentQuestData = data
            Mon = data.mon
            NameMon = data.mon
            NameQuest = data.quest
            LevelQuest = data.questLv
            CFrameQuest = data.qpos
            CFrameMon = data.mpos
            return
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ANTI-AFK
-- ═══════════════════════════════════════════════════════════════════════════════

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  INFINITE ENERGY
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local char = GetChar()
            if char and char:FindFirstChild("Energy") then
                char.Energy.Value = 10000
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  REMOVE CAMERA SHAKE
-- ═══════════════════════════════════════════════════════════════════════════════

pcall(function()
    local CamShake = require(ReplicatedStorage.Util.CameraShaker)
    CamShake:Stop()
    RunService.Heartbeat:Connect(function()
        pcall(function() CamShake:Stop() end)
    end)
end)

print("[DragonHUB V2] Sistema base carregado!")


-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 2: SISTEMAS AUTOMÁTICOS INTELIGENTES
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO FARM LEVEL PRINCIPAL
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if not _G.AutoFarm then return end
            
            local hrp = GetHRP()
            if not hrp then return end
            
            local char = GetChar()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                task.wait(5)
                return
            end
            
            CheckQuest()
            if not CurrentQuestData then return end
            
            MyLevel = LocalPlayer.Data.Level.Value
            
            -- Entrada para locais especiais
            if CurrentQuestData.entrance then
                local ent = CurrentQuestData.entrance
                if ent ~= Vector3.new(0, 0, 0) then
                    local dist = (CFrameQuest.Position - hrp.Position).Magnitude
                    if dist > 10000 then
                        CommF_:InvokeServer("requestEntrance", ent)
                        task.wait(2)
                    end
                end
            end
            
            local questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible
            
            -- Verifica se a quest ativa é a correta
            if questVisible then
                local ok, title = pcall(function()
                    return LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                end)
                if ok and title and not string.find(title, NameMon or "") then
                    StartMagnet = false
                    CommF_:InvokeServer("AbandonQuest")
                    questVisible = false
                end
            end
            
            -- Pega a quest
            if not questVisible then
                StartMagnet = false
                CheckQuest()
                if not CurrentQuestData then return end
                
                local distQ = (CFrameQuest.Position - hrp.Position).Magnitude
                if distQ > 5 then
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Indo ao NPC: " .. tostring(NameQuest), Color3.fromRGB(255, 200, 0))
                    end
                    
                    if _G.Config.BypassTP and distQ > 1500 then
                        BTP(CFrameQuest)
                    else
                        TP1(CFrameQuest)
                    end
                    
                    local t = 0
                    repeat
                        task.wait(0.1)
                        t = t + 0.1
                        hrp = GetHRP()
                        if not hrp then break end
                    until (CFrameQuest.Position - hrp.Position).Magnitude <= 5 or t >= 10
                end
                
                if _G.UpdateStatus then
                    _G.UpdateStatus("Pegando quest: " .. tostring(NameQuest), Color3.fromRGB(0, 200, 255))
                end
                
                CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                task.wait(0.5)
                StartMagnet = true
            end
            
            -- Ataca os mobs
            if LocalPlayer.PlayerGui.Main.Quest.Visible then
                StartMagnet = true
                CheckQuest()
                
                if Workspace.Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") 
                            and v:FindFirstChild("Humanoid") 
                            and v.Humanoid.Health > 0 
                            and v.Name == Mon then
                            
                            local ok, title = pcall(function()
                                return LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                            end)
                            
                            if ok and title and string.find(title, NameMon or "") then
                                if _G.UpdateStatus then
                                    _G.UpdateStatus("Atacando: " .. tostring(Mon), Color3.fromRGB(255, 80, 80))
                                end
                                
                                repeat
                                    task.wait()
                                    EquipWeapon(_G.Config.SelectWeapon or "Melee")
                                    AutoHaki()
                                    
                                    PosMon = v.HumanoidRootPart.CFrame
                                    TP1(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                                    
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                    StartMagnet = true
                                    
                                    -- Skills quando mob estiver com pouca vida
                                    if v.Humanoid.Health / v.Humanoid.MaxHealth * 100 <= _G.Config.KillAt then
                                        pcall(function()
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                                            task.wait(0.1)
                                            game:GetService("VirtualInputManager"):SendKeyEvent(false, "Z", false, game)
                                        end)
                                        pcall(function()
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "X", false, game)
                                            task.wait(0.1)
                                            game:GetService("VirtualInputManager"):SendKeyEvent(false, "X", false, game)
                                        end)
                                    end
                                until not _G.AutoFarm 
                                    or v.Humanoid.Health <= 0 
                                    or not v.Parent 
                                    or not LocalPlayer.PlayerGui.Main.Quest.Visible
                            else
                                StartMagnet = false
                                CommF_:InvokeServer("AbandonQuest")
                            end
                        end
                    end
                else
                    -- Mob não encontrado - vai até a posição de spawn
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Procurando: " .. tostring(Mon), Color3.fromRGB(180, 180, 255))
                    end
                    TP1(CFrameMon)
                    task.wait(0.5)
                    StartMagnet = false
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO STATS
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(2) do
        pcall(function()
            if not _G.Config.AutoStats then return end
            local points = LocalPlayer.Data.Points.Value
            if points <= 0 then return end
            
            local statMap = {
                Melee = "Strength",
                Fruit = "Defense",
                Gun = "Blox_Fruit",
                Defense = "Defense"
            }
            local stat = statMap[_G.Config.StatPriority] or "Strength"
            CommF_:InvokeServer("Stat", stat)
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO SUPERHUMAN (EVOLUÇÃO COMPLETA)
-- ═══════════════════════════════════════════════════════════════════════════════

local FightingStyles = {
    "Godhuman", "Dragon Talon", "Electric Claw", "Sharkman Karate",
    "Death Step", "Superhuman", "Dragon Claw", "Fishman Karate",
    "Electro", "Black Leg", "Combat"
}

local function GetBestFightingStyle()
    for _, name in ipairs(FightingStyles) do
        if HasWeapon(name) then
            return name
        end
    end
    return "Combat"
end

spawn(function()
    while task.wait(5) do
        pcall(function()
            local beli = LocalPlayer.Data.Beli.Value
            local frags = LocalPlayer.Data.Fragments.Value
            
            -- Combat -> Black Leg
            if HasWeapon("Combat") and beli >= 150000 and not HasWeapon("Black Leg") then
                UnEquipWeapon("Combat")
                task.wait(0.2)
                CommF_:InvokeServer("BuyBlackLeg")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Black Leg!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Black Leg -> Electro
            local bl = HasWeapon("Black Leg")
            if bl and bl:FindFirstChild("Level") and bl.Level.Value >= 300 and beli >= 300000 and not HasWeapon("Electro") then
                UnEquipWeapon("Black Leg")
                task.wait(0.2)
                CommF_:InvokeServer("BuyElectro")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Electro!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Electro -> Fishman Karate
            local el = HasWeapon("Electro")
            if el and el:FindFirstChild("Level") and el.Level.Value >= 300 and beli >= 750000 and not HasWeapon("Fishman Karate") then
                UnEquipWeapon("Electro")
                task.wait(0.2)
                CommF_:InvokeServer("BuyFishmanKarate")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Fishman Karate!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Fishman Karate -> Dragon Claw
            local fk = HasWeapon("Fishman Karate")
            if fk and fk:FindFirstChild("Level") and fk.Level.Value >= 300 and frags >= 1500 and not HasWeapon("Dragon Claw") then
                UnEquipWeapon("Fishman Karate")
                task.wait(0.2)
                CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
                CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Dragon Claw!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Dragon Claw -> Superhuman
            local dc = HasWeapon("Dragon Claw")
            if dc and dc:FindFirstChild("Level") and dc.Level.Value >= 300 and beli >= 3000000 and not HasWeapon("Superhuman") then
                UnEquipWeapon("Dragon Claw")
                task.wait(0.2)
                CommF_:InvokeServer("BuySuperhuman")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Superhuman!", Color3.fromRGB(0, 255, 100))
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO BUY HAKI ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    task.wait(10)
    while task.wait(30) do
        pcall(function()
            CommF_:InvokeServer("KenTalk", "Buy")
            CommF_:InvokeServer("BuyHaki", "Geppo")
            CommF_:InvokeServer("BuyHaki", "Buso")
            CommF_:InvokeServer("BuyHaki", "Soru")
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO REDEEM CODES
-- ═══════════════════════════════════════════════════════════════════════════════

local x2Code = {
    "Sub2Fer999", "Sub2OfficialNoobie", "Sub2Daigrock", "Enyu_yt", "Starcodeheo",
    "Sub2Noobmaster123", "Sub2GamerRobot", "fudd10_v2", "JCWK", "Sub2UncleKizaru",
    "BYrantis", "chandler", "StrawHatMaine", "sub2liveevil", "Axiore", "TantaiGaming",
    "fudd10", "Sub2Brawlexe", "Bluxxy", "Magicbus", "kittgaming"
}

spawn(function()
    task.wait(5)
    while task.wait(120) do
        pcall(function()
            if MyLevel < 10 then return end
            for _, code in ipairs(x2Code) do
                CommF_:InvokeServer("Redeem", code)
                task.wait(0.1)
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO SECOND SEA (COMPLETO)
-- ═══════════════════════════════════════════════════════════════════════════════

local function AutoSecondSeaQuest()
    if not World1 then return end
    MyLevel = LocalPlayer.Data.Level.Value
    if MyLevel < 700 then return end
    
    _G.AutoFarm = false
    if _G.UpdateStatus then
        _G.UpdateStatus("Iniciando quest Second Sea...", Color3.fromRGB(255, 200, 0))
    end
    
    local Door = Workspace.Map.Ice and Workspace.Map.Ice:FindFirstChild("Door")
    
    if Door and Door.CanCollide == true and Door.Transparency == 0 then
        -- Precisa da chave
        local keyPos = CFrame.new(4851.8720703125, 5.6514348983765, 718.47094726563)
        repeat task.wait() TP(keyPos) until (keyPos.Position - GetHRP().Position).Magnitude <= 3
        task.wait(1)
        CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
        EquipWeapon("Key")
        local nextPos = CFrame.new(1347.7124, 37.3751602, -1325.6488)
        repeat task.wait() TP(nextPos) until (nextPos.Position - GetHRP().Position).Magnitude <= 3
        task.wait(3)
    elseif Door and Door.CanCollide == false then
        -- Porta aberta, matar Ice Admiral
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v.Name == "Ice Admiral" and v.Humanoid and v.Humanoid.Health > 0 then
                repeat
                    task.wait()
                    AutoHaki()
                    EquipWeapon(GetBestFightingStyle())
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                    TP(v.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(1280, 870), Workspace.CurrentCamera.CFrame)
                until v.Humanoid.Health <= 0 or not v.Parent
                CommF_:InvokeServer("TravelDressrosa")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Viajando para Second Sea!", Color3.fromRGB(0, 255, 100))
                end
            end
        end
    else
        CommF_:InvokeServer("TravelDressrosa")
        if _G.UpdateStatus then
            _G.UpdateStatus("Viajando para Second Sea!", Color3.fromRGB(0, 255, 100))
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO THIRD SEA (COMPLETO)
-- ═══════════════════════════════════════════════════════════════════════════════

local function AutoThirdSeaQuest()
    if not World2 then return end
    MyLevel = LocalPlayer.Data.Level.Value
    if MyLevel < 1500 then return end
    
    _G.AutoFarm = false
    if _G.UpdateStatus then
        _G.UpdateStatus("Viajando para Third Sea...", Color3.fromRGB(255, 200, 0))
    end
    
    CommF_:InvokeServer("TravelZou")
    if _G.UpdateStatus then
        _G.UpdateStatus("Chegou no Third Sea!", Color3.fromRGB(0, 255, 100))
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  VERIFICADOR INTELIGENTE DE PROGRESSO
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(10) do
        pcall(function()
            if not _G.AutoFarm then return end
            
            MyLevel = LocalPlayer.Data.Level.Value
            
            -- Verifica Second Sea
            if World1 and MyLevel >= 700 then
                AutoSecondSeaQuest()
                return
            end
            
            -- Verifica Third Sea
            if World2 and MyLevel >= 1500 then
                AutoThirdSeaQuest()
                return
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  PROTEÇÃO ANTI-MORTE
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(1) do
        pcall(function()
            if not _G.AutoFarm then return end
            local char = GetChar()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then
                if _G.UpdateStatus then
                    _G.UpdateStatus("Morreu! Aguardando respawn...", Color3.fromRGB(255, 50, 50))
                end
                _G.AutoFarm = false
                repeat task.wait(0.5) until GetChar() ~= char
                task.wait(5)
                _G.AutoFarm = true
                if _G.UpdateStatus then
                    _G.UpdateStatus("Farm retomado!", Color3.fromRGB(100, 255, 100))
                end
            end
        end)
    end
end)

print("[DragonHUB V2] Sistemas automáticos carregados!")


-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 3: QUESTS DE ITENS AUTOMÁTICAS
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO SABER (SEA 1)
-- ═══════════════════════════════════════════════════════════════════════════════

local SaberCompleted = false

spawn(function()
    while task.wait(5) do
        pcall(function()
            if SaberCompleted then return end
            if not World1 then return end
            if HasWeapon("Saber") then
                SaberCompleted = true
                return
            end
            
            local lv = LocalPlayer.Data.Level.Value
            if lv < 200 then return end
            
            if _G.UpdateStatus then
                _G.UpdateStatus("Fazendo quest da Saber...", Color3.fromRGB(255, 200, 0))
            end
            
            -- Falar com o NPC da Saber
            local shanks = Workspace:FindFirstChild("Shanks") or Workspace.Map:FindFirstChild("Shanks")
            if shanks then
                repeat
                    task.wait()
                    TP(shanks.CFrame * CFrame.new(0, 0, 3))
                until (shanks.Position - GetHRP().Position).Magnitude <= 5
                task.wait(1)
                CommF_:InvokeServer("SaberExpert", "talk")
                task.wait(0.5)
            end
            
            -- Verificar se completou a quest
            local result = CommF_:InvokeServer("ProQuestProgress", "GetSaber")
            if result and result ~= "Not Started" then
                SaberCompleted = true
                if _G.UpdateStatus then
                    _G.UpdateStatus("Quest da Saber completada!", Color3.fromRGB(0, 255, 100))
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO BARTILO (SEA 2)
-- ═══════════════════════════════════════════════════════════════════════════════

local BartiloCompleted = false

spawn(function()
    while task.wait(5) do
        pcall(function()
            if BartiloCompleted then return end
            if not World2 then return end
            if HasWeapon("Pole (2nd Form)") or HasWeapon("True Triple Katana") then
                BartiloCompleted = true
                return
            end
            
            local lv = LocalPlayer.Data.Level.Value
            if lv < 850 then return end
            
            if _G.UpdateStatus then
                _G.UpdateStatus("Fazendo quest do Bartilo...", Color3.fromRGB(255, 200, 0))
            end
            
            CommF_:InvokeServer("BartiloQuest", "Start")
            task.wait(0.5)
            
            -- Matar 50 Swan Pirates
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == "Swan Pirate" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    repeat
                        task.wait()
                        EquipWeapon(GetBestFightingStyle())
                        AutoHaki()
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until v.Humanoid.Health <= 0 or not v.Parent
                end
            end
            
            -- Verificar se completou
            local result = CommF_:InvokeServer("BartiloQuest", "Check")
            if result and result == "Completed" then
                BartiloCompleted = true
                if _G.UpdateStatus then
                    _G.UpdateStatus("Quest do Bartilo completada!", Color3.fromRGB(0, 255, 100))
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO RENGOKU (SEA 2)
-- ═══════════════════════════════════════════════════════════════════════════════

local RengokuCompleted = false

spawn(function()
    while task.wait(10) do
        pcall(function()
            if RengokuCompleted then return end
            if not World2 then return end
            if HasWeapon("Rengoku") then
                RengokuCompleted = true
                return
            end
            
            local lv = LocalPlayer.Data.Level.Value
            if lv < 1100 then return end
            
            -- Verificar se tem a chave
            local hasKey = CheckItem("Hidden Key")
            if not hasKey then
                -- Farmar Ectoplasm para comprar a chave
                if _G.UpdateStatus then
                    _G.UpdateStatus("Farmando Ectoplasm para Rengoku...", Color3.fromRGB(255, 200, 0))
                end
                return
            end
            
            if _G.UpdateStatus then
                _G.UpdateStatus("Pegando Rengoku...", Color3.fromRGB(255, 200, 0))
            end
            
            -- Ir até a caverna do Rengoku
            local rengokuPos = CFrame.new(-1410.6837158203125, 5000.60595703125, -4361.705078125)
            repeat
                task.wait()
                TP(rengokuPos)
            until (rengokuPos.Position - GetHRP().Position).Magnitude <= 5
            
            task.wait(1)
            CommF_:InvokeServer("RengokuQuest", "Check")
            task.wait(0.5)
            CommF_:InvokeServer("RengokuQuest", "GetWeapon")
            
            if HasWeapon("Rengoku") then
                RengokuCompleted = true
                if _G.UpdateStatus then
                    _G.UpdateStatus("Rengoku obtida!", Color3.fromRGB(0, 255, 100))
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO POLE (SEA 2)
-- ═══════════════════════════════════════════════════════════════════════════════

local PoleCompleted = false

spawn(function()
    while task.wait(10) do
        pcall(function()
            if PoleCompleted then return end
            if not World2 then return end
            if HasWeapon("Pole (2nd Form)") then
                PoleCompleted = true
                return
            end
            
            local lv = LocalPlayer.Data.Level.Value
            if lv < 800 then return end
            
            if _G.UpdateStatus then
                _G.UpdateStatus("Farmando Pole (2nd Form)...", Color3.fromRGB(255, 200, 0))
            end
            
            -- Procurar o boss Thunder God
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == "Thunder God" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    repeat
                        task.wait()
                        EquipWeapon(GetBestFightingStyle())
                        AutoHaki()
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until v.Humanoid.Health <= 0 or not v.Parent
                    
                    if HasWeapon("Pole (2nd Form)") then
                        PoleCompleted = true
                        if _G.UpdateStatus then
                            _G.UpdateStatus("Pole (2nd Form) obtida!", Color3.fromRGB(0, 255, 100))
                        end
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO DARK DAGGER (SEA 2)
-- ═══════════════════════════════════════════════════════════════════════════════

local DarkDaggerCompleted = false

spawn(function()
    while task.wait(10) do
        pcall(function()
            if DarkDaggerCompleted then return end
            if not World2 then return end
            if HasWeapon("Dark Dagger") then
                DarkDaggerCompleted = true
                return
            end
            
            local lv = LocalPlayer.Data.Level.Value
            if lv < 1000 then return end
            
            if _G.UpdateStatus then
                _G.UpdateStatus("Farmando Dark Dagger...", Color3.fromRGB(255, 200, 0))
            end
            
            -- Procurar o boss Darkbeard
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == "Darkbeard" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    repeat
                        task.wait()
                        EquipWeapon(GetBestFightingStyle())
                        AutoHaki()
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until v.Humanoid.Health <= 0 or not v.Parent
                    
                    if HasWeapon("Dark Dagger") then
                        DarkDaggerCompleted = true
                        if _G.UpdateStatus then
                            _G.UpdateStatus("Dark Dagger obtida!", Color3.fromRGB(0, 255, 100))
                        end
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO ECTOPLASM FARM (SEA 2)
-- ═══════════════════════════════════════════════════════════════════════════════

local EctoplasmFarm = false

spawn(function()
    while task.wait(10) do
        pcall(function()
            if not World2 then return end
            
            local ectoplasm = CheckMaterial("Ectoplasm")
            if ectoplasm >= 250 then return end
            
            EctoplasmFarm = true
            if _G.UpdateStatus then
                _G.UpdateStatus("Farmando Ectoplasm: " .. ectoplasm .. "/250", Color3.fromRGB(255, 200, 0))
            end
            
            -- Farmar em Barco Fantasma
            local shipPos = CFrame.new(923.21252441406, 126.9760055542, 32852.83203125)
            if (shipPos.Position - GetHRP().Position).Magnitude > 10000 then
                CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                task.wait(2)
            end
            
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if (v.Name == "Ship Deckhand" or v.Name == "Ship Engineer" or v.Name == "Ship Steward" or v.Name == "Ship Officer")
                    and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    repeat
                        task.wait()
                        EquipWeapon(GetBestFightingStyle())
                        AutoHaki()
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until v.Humanoid.Health <= 0 or not v.Parent
                end
            end
            
            EctoplasmFarm = false
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO FARM BOSSES
-- ═══════════════════════════════════════════════════════════════════════════════

local BossPriority = {
    -- Sea 1
    "Saber Expert", "The Saw", "Greybeard", "Mob Leader",
    -- Sea 2
    "Diamond", "Jeremy", "Fajita", "Smoke Admiral", "Awakened Ice Admiral",
    "Tide Keeper", "Darkbeard", "Cursed Captain", "Order",
    -- Sea 3
    "Stone", "Island Empress", "Kilo Admiral", "Captain Elephant",
    "Beautiful Pirate", "Longma", "Cake Queen", "Soul Reaper"
}

spawn(function()
    while task.wait(10) do
        pcall(function()
            if not _G.AutoFarm then return end
            if EctoplasmFarm then return end
            
            for _, bossName in ipairs(BossPriority) do
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v.Name == bossName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if _G.UpdateStatus then
                            _G.UpdateStatus("Matando Boss: " .. bossName, Color3.fromRGB(255, 100, 100))
                        end
                        
                        repeat
                            task.wait()
                            EquipWeapon(GetBestFightingStyle())
                            AutoHaki()
                            TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                            v.HumanoidRootPart.CanCollide = false
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        until v.Humanoid.Health <= 0 or not v.Parent
                        
                        if _G.UpdateStatus then
                            _G.UpdateStatus("Boss " .. bossName .. " morto!", Color3.fromRGB(0, 255, 100))
                        end
                        task.wait(2)
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  AUTO ELITE HUNTER (SEA 3)
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(10) do
        pcall(function()
            if not World3 then return end
            
            MyLevel = LocalPlayer.Data.Level.Value
            if MyLevel < 1500 then return end
            
            -- Verificar se tem quest de Elite Hunter
            local questTitle = ""
            pcall(function()
                questTitle = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
            end)
            
            if not string.find(questTitle, "Elite Hunter") then
                -- Pegar quest
                local elitePos = CFrame.new(-5411.22021484375, 313.7965393066406, -2826.278076171875)
                repeat
                    task.wait()
                    TP(elitePos)
                until (elitePos.Position - GetHRP().Position).Magnitude <= 5
                
                task.wait(1)
                CommF_:InvokeServer("EliteHunter")
            end
            
            -- Procurar Elite Boss
            local eliteBosses = {"Diablo", "Deandre", "Urban"}
            for _, bossName in ipairs(eliteBosses) do
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v.Name == bossName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if _G.UpdateStatus then
                            _G.UpdateStatus("Matando Elite: " .. bossName, Color3.fromRGB(255, 100, 100))
                        end
                        
                        repeat
                            task.wait()
                            EquipWeapon(GetBestFightingStyle())
                            AutoHaki()
                            TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                            v.HumanoidRootPart.CanCollide = false
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        until v.Humanoid.Health <= 0 or not v.Parent
                        
                        if _G.UpdateStatus then
                            _G.UpdateStatus("Elite " .. bossName .. " morto!", Color3.fromRGB(0, 255, 100))
                        end
                    end
                end
            end
        end)
    end
end)

print("[DragonHUB V2] Quests de itens carregadas!")


-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 4: ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local ESP = {
    Player = false,
    Chest = false,
    Fruit = false,
    Mob = false,
    Island = false,
    SeaBeast = false
}

local Number = math.random(1, 1000000)

local function round(n)
    return math.floor(tonumber(n) + 0.5)
end

-- ESP Player
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, v in pairs(Players:GetChildren()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    if ESP.Player then
                        if not v.Character.Head:FindFirstChild("NameEsp" .. Number) then
                            local bill = Instance.new("BillboardGui", v.Character.Head)
                            bill.Name = "NameEsp" .. Number
                            bill.ExtentsOffset = Vector3.new(0, 1, 0)
                            bill.Size = UDim2.new(1, 200, 1, 30)
                            bill.Adornee = v.Character.Head
                            bill.AlwaysOnTop = true
                            local name = Instance.new("TextLabel", bill)
                            name.Font = Enum.Font.GothamSemibold
                            name.FontSize = Enum.FontSize.Size14
                            name.TextWrapped = true
                            name.Size = UDim2.new(1, 0, 1, 0)
                            name.TextYAlignment = Enum.TextYAlignment.Top
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            if v.Team == LocalPlayer.Team then
                                name.TextColor3 = Color3.new(0, 255, 0)
                            else
                                name.TextColor3 = Color3.new(255, 0, 0)
                            end
                        else
                            local dist = round((LocalPlayer.Character.Head.Position - v.Character.Head.Position).Magnitude / 3)
                            local hp = round(v.Character.Humanoid.Health * 100 / v.Character.Humanoid.MaxHealth)
                            v.Character.Head["NameEsp" .. Number].TextLabel.Text = v.Name .. " | " .. dist .. "m | HP: " .. hp .. "%"
                        end
                    else
                        if v.Character.Head:FindFirstChild("NameEsp" .. Number) then
                            v.Character.Head["NameEsp" .. Number]:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Chest
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, v in pairs(Workspace:GetChildren()) do
                if string.find(v.Name, "Chest") then
                    if ESP.Chest then
                        if not v:FindFirstChild("NameEsp" .. Number) then
                            local bill = Instance.new("BillboardGui", v)
                            bill.Name = "NameEsp" .. Number
                            bill.ExtentsOffset = Vector3.new(0, 1, 0)
                            bill.Size = UDim2.new(1, 200, 1, 30)
                            bill.Adornee = v
                            bill.AlwaysOnTop = true
                            local name = Instance.new("TextLabel", bill)
                            name.Font = Enum.Font.GothamSemibold
                            name.FontSize = Enum.FontSize.Size14
                            name.TextWrapped = true
                            name.Size = UDim2.new(1, 0, 1, 0)
                            name.TextYAlignment = Enum.TextYAlignment.Top
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            
                            if v.Name == "Chest1" then
                                name.TextColor3 = Color3.fromRGB(109, 109, 109)
                            elseif v.Name == "Chest2" then
                                name.TextColor3 = Color3.fromRGB(173, 158, 21)
                            elseif v.Name == "Chest3" then
                                name.TextColor3 = Color3.fromRGB(85, 255, 255)
                            end
                        else
                            local dist = round((LocalPlayer.Character.Head.Position - v.Position).Magnitude / 3)
                            v["NameEsp" .. Number].TextLabel.Text = v.Name .. " | " .. dist .. "m"
                        end
                    else
                        if v:FindFirstChild("NameEsp" .. Number) then
                            v["NameEsp" .. Number]:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Fruit
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, v in pairs(Workspace:GetChildren()) do
                if string.find(v.Name, "Fruit") and v:FindFirstChild("Handle") then
                    if ESP.Fruit then
                        if not v.Handle:FindFirstChild("NameEsp" .. Number) then
                            local bill = Instance.new("BillboardGui", v.Handle)
                            bill.Name = "NameEsp" .. Number
                            bill.ExtentsOffset = Vector3.new(0, 1, 0)
                            bill.Size = UDim2.new(1, 200, 1, 30)
                            bill.Adornee = v.Handle
                            bill.AlwaysOnTop = true
                            local name = Instance.new("TextLabel", bill)
                            name.Font = Enum.Font.GothamSemibold
                            name.FontSize = Enum.FontSize.Size14
                            name.TextWrapped = true
                            name.Size = UDim2.new(1, 0, 1, 0)
                            name.TextYAlignment = Enum.TextYAlignment.Top
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            name.TextColor3 = Color3.fromRGB(255, 255, 255)
                        else
                            local dist = round((LocalPlayer.Character.Head.Position - v.Handle.Position).Magnitude / 3)
                            v.Handle["NameEsp" .. Number].TextLabel.Text = v.Name .. " | " .. dist .. "m"
                        end
                    else
                        if v.Handle:FindFirstChild("NameEsp" .. Number) then
                            v.Handle["NameEsp" .. Number]:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Mob
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                    if ESP.Mob then
                        if not v:FindFirstChild("MobEsp") then
                            local bill = Instance.new("BillboardGui", v)
                            bill.Name = "MobEsp"
                            bill.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            bill.Active = true
                            bill.AlwaysOnTop = true
                            bill.LightInfluence = 1
                            bill.Size = UDim2.new(0, 200, 0, 50)
                            bill.StudsOffset = Vector3.new(0, 2.5, 0)
                            
                            local name = Instance.new("TextLabel", bill)
                            name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            name.BackgroundTransparency = 1
                            name.Size = UDim2.new(0, 200, 0, 50)
                            name.Font = Enum.Font.GothamBold
                            name.TextColor3 = Color3.fromRGB(7, 236, 240)
                            name.TextSize = 14
                        else
                            local dist = round((LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude / 3)
                            v.MobEsp.TextLabel.Text = v.Name .. " - " .. dist .. "m"
                        end
                    else
                        if v:FindFirstChild("MobEsp") then
                            v.MobEsp:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Island
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations") then
                for _, v in pairs(Workspace._WorldOrigin.Locations:GetChildren()) do
                    if v.Name ~= "Sea" then
                        if ESP.Island then
                            if not v:FindFirstChild("NameEsp") then
                                local bill = Instance.new("BillboardGui", v)
                                bill.Name = "NameEsp"
                                bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                bill.Size = UDim2.new(1, 200, 1, 30)
                                bill.Adornee = v
                                bill.AlwaysOnTop = true
                                local name = Instance.new("TextLabel", bill)
                                name.Font = Enum.Font.GothamBold
                                name.FontSize = Enum.FontSize.Size14
                                name.TextWrapped = true
                                name.Size = UDim2.new(1, 0, 1, 0)
                                name.TextYAlignment = Enum.TextYAlignment.Top
                                name.BackgroundTransparency = 1
                                name.TextStrokeTransparency = 0.5
                                name.TextColor3 = Color3.fromRGB(7, 236, 240)
                            else
                                local dist = round((LocalPlayer.Character.Head.Position - v.Position).Magnitude / 3)
                                v.NameEsp.TextLabel.Text = v.Name .. " | " .. dist .. "m"
                            end
                        else
                            if v:FindFirstChild("NameEsp") then
                                v.NameEsp:Destroy()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Sea Beast
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Workspace:FindFirstChild("SeaBeasts") then
                for _, v in pairs(Workspace.SeaBeasts:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") then
                        if ESP.SeaBeast then
                            if not v:FindFirstChild("SeaBeastEsp") then
                                local bill = Instance.new("BillboardGui", v)
                                bill.Name = "SeaBeastEsp"
                                bill.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                                bill.Active = true
                                bill.AlwaysOnTop = true
                                bill.LightInfluence = 1
                                bill.Size = UDim2.new(0, 200, 0, 50)
                                bill.StudsOffset = Vector3.new(0, 2.5, 0)
                                
                                local name = Instance.new("TextLabel", bill)
                                name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                name.BackgroundTransparency = 1
                                name.Size = UDim2.new(0, 200, 0, 50)
                                name.Font = Enum.Font.GothamBold
                                name.TextColor3 = Color3.fromRGB(255, 0, 255)
                                name.TextSize = 14
                            else
                                local dist = round((LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude / 3)
                                v.SeaBeastEsp.TextLabel.Text = v.Name .. " - " .. dist .. "m"
                            end
                        else
                            if v:FindFirstChild("SeaBeastEsp") then
                                v.SeaBeastEsp:Destroy()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Ativar ESP automaticamente
spawn(function()
    task.wait(15)
    ESP.Player = true
    ESP.Chest = true
    ESP.Fruit = true
    ESP.Mob = true
    ESP.Island = true
    ESP.SeaBeast = true
    if _G.UpdateStatus then
        _G.UpdateStatus("ESP Ativado!", Color3.fromRGB(0, 255, 100))
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 5: INTERFACE SIMPLES (LOADER + CONTROLES)
-- ═══════════════════════════════════════════════════════════════════════════════

if CoreGui:FindFirstChild("DragonHubV2Auto") then
    CoreGui.DragonHubV2Auto:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DragonHubV2Auto"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer.PlayerGui
end

local MainColor = Color3.fromRGB(200, 0, 0)
local DarkBg = Color3.fromRGB(12, 12, 12)

-- LOADER
local LoaderFrame = Instance.new("Frame", ScreenGui)
LoaderFrame.Size = UDim2.new(0, 350, 0, 200)
LoaderFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
LoaderFrame.BackgroundColor3 = DarkBg
LoaderFrame.BorderSizePixel = 0
LoaderFrame.ClipsDescendants = true
Instance.new("UICorner", LoaderFrame).CornerRadius = UDim.new(0, 10)
local UIStrokeL = Instance.new("UIStroke", LoaderFrame)
UIStrokeL.Color = MainColor
UIStrokeL.Thickness = 2

local Title = Instance.new("TextLabel", LoaderFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 15)
Title.Text = "DragonHUB V2"
Title.TextColor3 = MainColor
Title.Font = Enum.Font.GothamBold
Title.TextSize = 34
Title.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", LoaderFrame)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 52)
SubTitle.Text = "Versão Automática Completa"
SubTitle.TextColor3 = Color3.fromRGB(160, 160, 160)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 13
SubTitle.BackgroundTransparency = 1

local BarBg = Instance.new("Frame", LoaderFrame)
BarBg.Size = UDim2.new(0, 280, 0, 3)
BarBg.Position = UDim2.new(0.5, -140, 0, 145)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = MainColor

local ActionText = Instance.new("TextLabel", LoaderFrame)
ActionText.Size = UDim2.new(1, 0, 0, 20)
ActionText.Position = UDim2.new(0, 0, 0, 160)
ActionText.Text = "Iniciando sistema..."
ActionText.TextColor3 = Color3.fromRGB(100, 100, 100)
ActionText.Font = Enum.Font.Code
ActionText.TextSize = 12
ActionText.BackgroundTransparency = 1

-- TRACKER (Status)
local TrackerFrame = Instance.new("Frame", ScreenGui)
TrackerFrame.Name = "Tracker"
TrackerFrame.Size = UDim2.new(0, 340, 0, 26)
TrackerFrame.Position = UDim2.new(0.5, -170, 0, 15)
TrackerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TrackerFrame.BackgroundTransparency = 0.4
TrackerFrame.BorderSizePixel = 1
TrackerFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
TrackerFrame.Visible = false

local StatusLabel = Instance.new("TextLabel", TrackerFrame)
StatusLabel.Size = UDim2.new(1, -20, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Aguardando START..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Função de update do status
_G.UpdateStatus = function(msg, color)
    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = "Status: " .. tostring(msg)
        StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        task.spawn(function()
            StatusLabel.TextTransparency = 0.5
            task.wait(0.1)
            StatusLabel.TextTransparency = 0
        end)
    end
end

-- PAINEL DE CONTROLE
local ControlFrame = Instance.new("Frame", ScreenGui)
ControlFrame.Size = UDim2.new(0, 220, 0, 40)
ControlFrame.Position = UDim2.new(0.5, -110, 0, 50)
ControlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ControlFrame.BackgroundTransparency = 0.2
ControlFrame.Visible = false
ControlFrame.Draggable = true
ControlFrame.Active = true

local UIListLayout = Instance.new("UIListLayout", ControlFrame)
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

local function CriarBotao(nome, cor, callback)
    local btn = Instance.new("TextButton", ControlFrame)
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.BackgroundColor3 = cor
    btn.Text = nome
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- BOTÃO START
CriarBotao("START", Color3.fromRGB(40, 150, 40), function()
    if not _G.ScriptRodando then
        _G.ScriptRodando = true
        _G.AutoFarm = true
        _G.Config.FastAttack = true
        _G.Config.BringMonster = true
        _G.UpdateStatus("Farm ATIVO!", Color3.fromRGB(100, 255, 100))
    end
end)

-- BOTÃO STOP
CriarBotao("STOP", Color3.fromRGB(150, 40, 40), function()
    _G.ScriptRodando = false
    _G.AutoFarm = false
    _G.UpdateStatus("Farm pausado", Color3.fromRGB(255, 80, 80))
end)

-- BOTÃO FECHAR
CriarBotao("X", Color3.fromRGB(60, 60, 60), function()
    _G.ScriptRodando = false
    _G.AutoFarm = false
    _G.FecharTudo = true
    ScreenGui:Destroy()
end)

-- MONITOR EM TEMPO REAL
task.spawn(function()
    while task.wait(2) do
        if _G.FecharTudo then break end
        if not TrackerFrame or not TrackerFrame.Visible then continue end
        if not _G.ScriptRodando then continue end
        pcall(function()
            local lv = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 0
            local sea = SeaName
            local mobAtual = tostring(Mon or "Detectando...")
            _G.UpdateStatus(
                string.format("[%s] Lv %d | %s", sea, lv, mobAtual),
                Color3.fromRGB(255, 255, 255)
            )
        end)
    end
end)

-- ANIMAÇÃO DO LOADER
task.spawn(function()
    local etapas = {
        {0.2, "Carregando configurações..."},
        {0.4, "Inicializando Fast Attack..."},
        {0.6, "Carregando ESP..."},
        {0.8, "Conectando sistemas..."},
        {1.0, "DragonHUB V2 Pronto!"}
    }
    for _, etapa in ipairs(etapas) do
        TweenService:Create(
            BarFill,
            TweenInfo.new(1, Enum.EasingStyle.Quart),
            {Size = UDim2.new(etapa[1], 0, 1, 0)}
        ):Play()
        ActionText.Text = etapa[2]
        task.wait(1.2)
    end
    TweenService:Create(
        LoaderFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quart),
        {BackgroundTransparency = 1}
    ):Play()
    task.wait(0.4)
    LoaderFrame:Destroy()
    TrackerFrame.Visible = true
    ControlFrame.Visible = true
    _G.UpdateStatus("Aguardando START...", Color3.fromRGB(180, 180, 180))
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  MENSAGEM FINAL
-- ═══════════════════════════════════════════════════════════════════════════════

print("═══════════════════════════════════════════════════════════")
print("[DragonHUB V2] SISTEMA COMPLETO CARREGADO!")
print("[DragonHUB V2] Sea: " .. SeaName)
print("[DragonHUB V2] Funcionalidades:")
print("  - Auto Farm Level (Quest)")
print("  - Auto Second Sea (Lv 700+)")
print("  - Auto Third Sea (Lv 1500+)")
print("  - Auto Superhuman Evolution")
print("  - Auto Saber (Sea 1)")
print("  - Auto Bartilo (Sea 2)")
print("  - Auto Rengoku (Sea 2)")
print("  - Auto Pole (Sea 2)")
print("  - Auto Dark Dagger (Sea 2)")
print("  - Auto Farm Bosses")
print("  - Auto Elite Hunter (Sea 3)")
print("  - Auto Ectoplasm Farm")
print("  - ESP (Player, Chest, Fruit, Mob, Island, Sea Beast)")
print("  - Fast Attack Otimizado")
print("  - Bring Mobs")
print("  - Auto Stats")
print("  - Auto Buy Abilities")
print("  - Auto Redeem Codes")
print("[DragonHUB V2] Clique START para iniciar!")
print("═══════════════════════════════════════════════════════════")


-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 6: AUTO MASTERY SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

-- Auto Mastery Fruit
spawn(function()
    while task.wait(10) do
        pcall(function()
            if not _G.AutoFarm then return end
            
            local fruitName = LocalPlayer.Data.DevilFruit.Value
            if fruitName == "" then return end
            
            local fruit = HasWeapon(fruitName)
            if not fruit then return end
            
            local mastery = fruit:FindFirstChild("Level")
            if not mastery then return end
            
            if mastery.Value < 600 then
                if _G.UpdateStatus then
                    _G.UpdateStatus("Subindo Mastery Fruit: " .. mastery.Value .. "/600", Color3.fromRGB(255, 200, 0))
                end
                
                -- Equipar fruta
                EquipWeapon(fruitName)
            end
        end)
    end
end)

-- Auto Mastery Gun
spawn(function()
    while task.wait(10) do
        pcall(function()
            if not _G.AutoFarm then return end
            
            local gunName = nil
            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("RemoteFunctionShoot") then
                    gunName = v.Name
                    break
                end
            end
            
            if not gunName then return end
            
            local gun = HasWeapon(gunName)
            if not gun then return end
            
            local mastery = gun:FindFirstChild("Level")
            if not mastery then return end
            
            if mastery.Value < 600 then
                if _G.UpdateStatus then
                    _G.UpdateStatus("Subindo Mastery Gun: " .. mastery.Value .. "/600", Color3.fromRGB(255, 200, 0))
                end
            end
        end)
    end
end)

-- Auto Mastery Sword
spawn(function()
    while task.wait(10) do
        pcall(function()
            if not _G.AutoFarm then return end
            
            local swordName = nil
            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") and v.ToolTip == "Sword" then
                    swordName = v.Name
                    break
                end
            end
            
            if not swordName then return end
            
            local sword = HasWeapon(swordName)
            if not sword then return end
            
            local mastery = sword:FindFirstChild("Level")
            if not mastery then return end
            
            if mastery.Value < 600 then
                if _G.UpdateStatus then
                    _G.UpdateStatus("Subindo Mastery Sword: " .. mastery.Value .. "/600", Color3.fromRGB(255, 200, 0))
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 7: TELEPORTES PARA ILHAS
-- ═══════════════════════════════════════════════════════════════════════════════

local IslandPositions = {
    -- Sea 1
    ["Starter Island"] = CFrame.new(1059.37195, 15.4495068, 1550.4231),
    ["Jungle"] = CFrame.new(-1598.08911, 35.5501175, 153.377838),
    ["Pirate Village"] = CFrame.new(-1141.07483, 4.10001802, 3831.5498),
    ["Desert"] = CFrame.new(894.488647, 5.14000702, 4392.43359),
    ["Frozen Village"] = CFrame.new(1389.74451, 88.1519318, -1298.90796),
    ["Marine Fortress"] = CFrame.new(-5039.58643, 27.3500385, 4324.68018),
    ["Skylands"] = CFrame.new(-4839.53027, 716.368591, -2619.44165),
    ["Prison"] = CFrame.new(5308.93115, 1.65517521, 475.120514),
    ["Colosseum"] = CFrame.new(-1580.04663, 6.35000277, -2986.47534),
    ["Magma Village"] = CFrame.new(-5313.37012, 10.9500084, 8515.29395),
    ["Underwater City"] = CFrame.new(61122.652343, 18.497442, 1569.399780),
    ["Fountain City"] = CFrame.new(5259.81982, 37.3500175, 4050.0293),
    
    -- Sea 2
    ["Kingdom of Rose"] = CFrame.new(-429.543518, 71.7699966, 1836.18188),
    ["Green Zone"] = CFrame.new(-2440.79639, 71.7140732, -3216.06812),
    ["Graveyard Island"] = CFrame.new(-5497.06152, 47.5923004, -795.237061),
    ["Dark Arena"] = CFrame.new(316.005615, 11.2347345, 2948.99561),
    ["Snow Mountain"] = CFrame.new(609.858826, 400.119904, -5372.25928),
    ["Hot and Cold"] = CFrame.new(-6064.06885, 15.2422857, -4902.97852),
    ["Cursed Ship"] = CFrame.new(923.21252441406, 126.9760055542, 32852.83203125),
    ["Ice Castle"] = CFrame.new(5667.6582, 26.7997818, -6486.08984),
    ["Forgotten Island"] = CFrame.new(-3054.44458, 235.544281, -10142.8193),
    ["Usoapp's Island"] = CFrame.new(4747.30566, 9.15104675, 2868.27588),
    
    -- Sea 3
    ["Port Town"] = CFrame.new(-290.074677, 42.9034653, 5581.58984),
    ["Hydra Island"] = CFrame.new(5229.47852, 68.3503647, 1440.48206),
    ["Great Tree"] = CFrame.new(2180.54126, 27.8156815, -6741.5498),
    ["Floating Turtle"] = CFrame.new(-13234.04, 331.488495, -7625.40137),
    ["Castle on the Sea"] = CFrame.new(-5076.99854, 313.768921, -3151.82495),
    ["Haunted Castle"] = CFrame.new(-9479.2168, 141.215088, 5566.09277),
    ["Peanut Island"] = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875),
    ["Ice Cream Island"] = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438),
    ["Cake Island"] = CFrame.new(-2021.32007, 37.7982254, -12028.7295),
    ["Chocolate Island"] = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375),
    ["Candy Island"] = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375),
    ["Tiki Island"] = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812),
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 8: AUTO FARM MATERIAIS
-- ═══════════════════════════════════════════════════════════════════════════════

local Materials = {
    ["Magma Ore"] = {mon = "Military Soldier", world = 1},
    ["Leather"] = {mon = "Pirate", world = 1},
    ["Scrap Metal"] = {mon = "Brute", world = 1},
    ["Angel Wings"] = {mon = "God's Guard", world = 1},
    ["Fish Tail"] = {mon = "Fishman Warrior", world = 1},
    ["Gunpowder"] = {mon = "Pistol Billionaire", world = 3},
    ["Mini Tusk"] = {mon = "Mythological Pirate", world = 3},
    ["Conjured Cocoa"] = {mon = "Cocoa Warrior", world = 3},
    ["Dragon Scale"] = {mon = "Dragon Crew Warrior", world = 3},
    ["Radioactive Material"] = {mon = "Factory Staff", world = 2},
    ["Vampire Fang"] = {mon = "Vampire", world = 2},
    ["Mystic Droplet"] = {mon = "Water Fighter", world = 2},
}

spawn(function()
    while task.wait(30) do
        pcall(function()
            if not _G.AutoFarm then return end
            
            for materialName, data in pairs(Materials) do
                local currentWorld = World1 and 1 or World2 and 2 or 3
                if data.world ~= currentWorld then continue end
                
                local count = CheckMaterial(materialName)
                if count < 20 then
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Farmando " .. materialName .. ": " .. count .. "/20", Color3.fromRGB(255, 200, 0))
                    end
                    
                    -- Procurar o mob específico
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == data.mon and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                EquipWeapon(GetBestFightingStyle())
                                AutoHaki()
                                TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                            until v.Humanoid.Health <= 0 or not v.Parent
                        end
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 9: MAIS BOSSES
-- ═══════════════════════════════════════════════════════════════════════════════

local AllBosses = {
    -- Sea 1
    ["The Gorilla King"] = {level = 25, pos = CFrame.new(-1129.883667, 40.463546, -525.423706)},
    ["Bobby"] = {level = 55, pos = CFrame.new(-1140.083740, 14.809885, 4322.921386)},
    ["Yeti"] = {level = 110, pos = CFrame.new(1201.641235, 144.579589, -1550.067016)},
    ["Mob Leader"] = {level = 120, pos = CFrame.new(-2841.99854, 7.41805029, 5319.70898)},
    ["Vice Admiral"] = {level = 130, pos = CFrame.new(-4881.230957, 22.652044, 4273.752441)},
    ["Warden"] = {level = 220, pos = CFrame.new(5098.973632, -0.320405, 474.237335)},
    ["Chief Warden"] = {level = 230, pos = CFrame.new(5098.973632, -0.320405, 474.237335)},
    ["Swan"] = {level = 240, pos = CFrame.new(5231.37158, 4.53655004, 1196.47009)},
    ["Magma Admiral"] = {level = 350, pos = CFrame.new(-5411.164550, 11.081554, 8454.292968)},
    ["Fishman Lord"] = {level = 425, pos = CFrame.new(60878.300781, 18.482830, 1543.757446)},
    ["Wysper"] = {level = 500, pos = CFrame.new(-4710.042968, 845.276977, -1927.307983)},
    ["Thunder God"] = {level = 575, pos = CFrame.new(-7678.489746, 5566.403808, -497.215606)},
    ["Cyborg"] = {level = 675, pos = CFrame.new(5441.951660, 42.502059, 4950.09375)},
    
    -- Sea 2
    ["Diamond"] = {level = 750, pos = CFrame.new(-1568.29236, 195.716675, -735.040039)},
    ["Jeremy"] = {level = 850, pos = CFrame.new(2205.24585, 448.998566, 2239.61182)},
    ["Fajita"] = {level = 925, pos = CFrame.new(-2151.06738, 73.914299, -10304.0225)},
    ["Don Swan"] = {level = 1000, pos = CFrame.new(2286.00781, 15.277894, 739.835693)},
    ["Smoke Admiral"] = {level = 1150, pos = CFrame.new(-5069.38623, 283.728607, -2844.80859)},
    ["Cursed Captain"] = {level = 1325, pos = CFrame.new(916.417603, 181.388062, 33494.4609)},
    ["Awakened Ice Admiral"] = {level = 1400, pos = CFrame.new(6400.8335, 340.21167, -6894.26709)},
    ["Tide Keeper"] = {level = 1475, pos = CFrame.new(-3713.22144, 13.9334717, -11421.0996)},
    
    -- Sea 3
    ["Stone"] = {level = 1550, pos = CFrame.new(-1046.74158, 76.3234024, 5432.5293)},
    ["Island Empress"] = {level = 1675, pos = CFrame.new(5733.59277, 610.296021, 202.76709)},
    ["Kilo Admiral"] = {level = 1750, pos = CFrame.new(2879.99878, 423.855408, -7203.03174)},
    ["Captain Elephant"] = {level = 1875, pos = CFrame.new(-13493.4629, 318.866852, -8403.46191)},
    ["Beautiful Pirate"] = {level = 1950, pos = CFrame.new(5314.58203, 25.4193878, -125.942276)},
    ["Cake Queen"] = {level = 2175, pos = CFrame.new(-709.518311, 382.502045, -11019.3604)},
    ["Longma"] = {level = 2000, pos = CFrame.new(-10271.7666, 330.762634, -9306.69336)},
    ["Soul Reaper"] = {level = 2100, pos = CFrame.new(-9524.23438, 316.90329, 6693.14844)},
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 10: GODHUMAN EVOLUTION (SEA 3)
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(10) do
        pcall(function()
            if not World3 then return end
            if HasWeapon("Godhuman") then return end
            
            local function GetMastery(name)
                local weapon = HasWeapon(name)
                if weapon and weapon:FindFirstChild("Level") then
                    return weapon.Level.Value
                end
                return 0
            end
            
            -- Verificar requisitos
            local superhumanMastery = GetMastery("Superhuman")
            local deathStepMastery = GetMastery("Death Step")
            local sharkmanMastery = GetMastery("Sharkman Karate")
            local electricClawMastery = GetMastery("Electric Claw")
            local dragonTalonMastery = GetMastery("Dragon Talon")
            
            -- Comprar Death Step se necessário
            if superhumanMastery >= 400 and not HasWeapon("Death Step") then
                CommF_:InvokeServer("BuyDeathStep")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Death Step!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Comprar Sharkman Karate se necessário
            if deathStepMastery >= 400 and not HasWeapon("Sharkman Karate") then
                CommF_:InvokeServer("BuySharkmanKarate")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Sharkman Karate!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Comprar Electric Claw se necessário
            if sharkmanMastery >= 400 and not HasWeapon("Electric Claw") then
                CommF_:InvokeServer("BuyElectricClaw")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Electric Claw!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Comprar Dragon Talon se necessário
            if electricClawMastery >= 400 and not HasWeapon("Dragon Talon") then
                CommF_:InvokeServer("BuyDragonTalon")
                if _G.UpdateStatus then
                    _G.UpdateStatus("Comprou Dragon Talon!", Color3.fromRGB(0, 255, 100))
                end
            end
            
            -- Comprar Godhuman se todos os requisitos forem atendidos
            if dragonTalonMastery >= 400 then
                local result = CommF_:InvokeServer("BuyGodhuman")
                if result and HasWeapon("Godhuman") then
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Godhuman desbloqueado!", Color3.fromRGB(0, 255, 100))
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 11: CAKE PRINCE / DOUGH KING FARM
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(10) do
        pcall(function()
            if not World3 then return end
            
            -- Verificar se Cake Prince está spawnado
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == "Cake Prince" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Matando Cake Prince!", Color3.fromRGB(255, 100, 100))
                    end
                    
                    repeat
                        task.wait()
                        EquipWeapon(GetBestFightingStyle())
                        AutoHaki()
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until v.Humanoid.Health <= 0 or not v.Parent
                    
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Cake Prince morto!", Color3.fromRGB(0, 255, 100))
                    end
                end
            end
            
            -- Verificar se Dough King está spawnado
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == "Dough King" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Matando Dough King!", Color3.fromRGB(255, 100, 100))
                    end
                    
                    repeat
                        task.wait()
                        EquipWeapon(GetBestFightingStyle())
                        AutoHaki()
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until v.Humanoid.Health <= 0 or not v.Parent
                    
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Dough King morto!", Color3.fromRGB(0, 255, 100))
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  PARTE 12: OBSERVATION HAKI V2 (SEA 3)
-- ═══════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(30) do
        pcall(function()
            if not World3 then return end
            
            -- Verificar se já tem Observation V2
            local result = CommF_:InvokeServer("BuyObservationHaki", "Check")
            if result and result == 2 then return end
            
            local lv = LocalPlayer.Data.Level.Value
            if lv < 1800 then return end
            
            if _G.UpdateStatus then
                _G.UpdateStatus("Fazendo quest Observation Haki V2...", Color3.fromRGB(255, 200, 0))
            end
            
            -- Ir até o NPC
            local npcPos = CFrame.new(-12471.169921875, 374.94024658203, -7551.677734375)
            repeat
                task.wait()
                TP(npcPos)
            until (npcPos.Position - GetHRP().Position).Magnitude <= 5
            
            task.wait(1)
            CommF_:InvokeServer("BuyObservationHaki")
        end)
    end
end)

print("[DragonHUB V2] Sistemas adicionais carregados!")
