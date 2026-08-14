
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════════
--  DETECTAR O MAR (SEA)
-- ════════════════════════════════════════════════════════════════════════════

local PlaceId = game.PlaceId
local World1 = PlaceId == 2753915549
local World2 = PlaceId == 4442272183
local World3 = PlaceId == 7449423635

if not (World1 or World2 or World3) then
    warn("[DragonHUB V3] Jogo não reconhecido!")
    return
end

local SeaName = World1 and "Sea 1" or World2 and "Sea 2" or "Sea 3"
print("[DragonHUB V3] Detectado: " .. SeaName)

-- ════════════════════════════════════════════════════════════════════════════
--  SERVIÇOS
-- ════════════════════════════════════════════════════════════════════════════

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local VirtualUser    = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local CoreGui        = game:GetService("CoreGui")
local Workspace      = game:GetService("Workspace")
local HttpService    = game:GetService("HttpService")

local LocalPlayer   = Players.LocalPlayer
local CommF_        = ReplicatedStorage.Remotes.CommF_
local CommE         = ReplicatedStorage.Remotes.CommE

-- ════════════════════════════════════════════════════════════════════════════
--  FLAGS GLOBAIS DE CONTROLE
-- ════════════════════════════════════════════════════════════════════════════

_G.AutoFarm          = false  -- Farm de level principal
_G.ScriptRodando     = false  -- Controle geral
_G.FecharTudo        = false  -- Fecha a GUI

-- Prioridades - ao detectar um alvo prioritário, interrompe o que estava fazendo
_G.PrioridadeAtiva   = false  -- true enquanto estiver lidando com spawn raro
_G.AlvoPrioridade    = nil    -- referência ao mob prioritário atual

-- Flags de farm específico (ativadas pelo sistema automático)
_G.FarmandoLevel     = false
_G.FarmandoBoss      = false
_G.FarmandoMaterial  = false
_G.FarmandoRaid      = false

-- Configurações automáticas (o script decide sozinho)
_G.Config = {
    BringMonster     = true,
    BringMode        = 375,
    FastAttack       = true,
    FastAttackDelay  = 0.03,
    AutoHakiKen      = true,
    AutoBuso         = true,
    AutoStats        = true,
    StatPriority     = "Melee",  -- Melee / Defense / Sword / Gun / Fruit
    KillAt           = 25,
    BypassTP         = true,
    PosY             = 30,
    SelectWeapon     = "Melee",
    SkillZ           = true,
    SkillX           = true,
    SkillC           = true,
    SkillV           = true,
}

-- Variáveis de estado do farm
local Mon, NameQuest, LevelQuest, CFrameQuest, CFrameMon, NameMon
local MyLevel        = 1
local StartMagnet    = false
local PosMon         = CFrame.new(0, 30, 0)
local CurrentQuestData = nil

-- Variáveis de magnet para funções específicas
local PosMonMasteryFruit  = CFrame.new(0, 30, 0)
local PosMonBone          = CFrame.new(0, 30, 0)
local PosMonDoughtOpenDoor= CFrame.new(0, 30, 0)
local PosMonEvo           = CFrame.new(0, 30, 0)
local PosMonBarto         = CFrame.new(0, 30, 0)
local PosMonEctoplasm      = CFrame.new(0, 30, 0)
local FastMon              = CFrame.new(0, 30, 0)
local PosGG                = CFrame.new(0, 30, 0)
local PosGay               = CFrame.new(0, 30, 0)
local RengokuMon           = CFrame.new(0, 30, 0)
local MusketeerHatMon      = CFrame.new(0, 30, 0)
local EctoplasmMon         = CFrame.new(0, 30, 0)

-- Flags de magnet
local StartMagnetBoneMon     = false
local MagnetDought           = false
local StartMasteryFruitMagnet = false
local StartEctoplasmMagnet   = false
local StartRengokuMagnet     = false
local StartMagnetMusketeerhat= false
local AutoBartiloBring       = false
local StartEvoMagnet         = false
local MakoriGayMag           = false
local StardMag               = false
local FarmMag                = false
local SelectMag              = false
local AutoFarmNearestMagnet  = false
local StartCandyMagnet       = false
local AutoSwordMasteryMag    = false

-- Flags especiais
local UseSkill      = false
local UseSkillKub   = false
local Fastattack    = false
local UseFastAttack = false
local BypassTP      = true

-- Para weapon gun mastery
local SelectWeaponGun = ""

-- ════════════════════════════════════════════════════════════════════════════
--  PROTEÇÃO ANTI-DETECÇÃO (do original)
-- ════════════════════════════════════════════════════════════════════════════

pcall(function()
    if getrawmetatable and setreadonly and newcclosure then
        local grm = getrawmetatable(game)
        setreadonly(grm, false)
        local oldnc = grm.__namecall
        grm.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local blocked = {
                "TeleportDetect","CHECKER_1","CHECKER","GUI_CHECK",
                "OneMoreTime","checkingSPEED","BANREMOTE","PERMAIDBAN",
                "KICKREMOTE","BR_KICKPC","BR_KICKMOBILE"
            }
            if args[1] then
                for _, v in ipairs(blocked) do
                    if tostring(args[1]) == v then return end
                end
            end
            return oldnc(self, ...)
        end)
    end
end)

-- Safe Farm (remove scripts de detecção do personagem)
_G.SafeFarm = true
spawn(function()
    while task.wait(1) do
        if _G.SafeFarm then
            pcall(function()
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("LocalScript") then
                        local n = v.Name
                        if n=="General" or n=="Shiftlock" or n=="FallDamage" or
                           n=="4444" or n=="CamBob" or n=="JumpCD" or
                           n=="Looking" or n=="Run" then
                            v:Destroy()
                        end
                    end
                end
                for _, v in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
                    if v:IsA("LocalScript") then
                        local n = v.Name
                        if n=="RobloxMotor6DBugFix" or n=="Clans" or n=="Codes" or
                           n=="CustomForceField" or n=="MenuBloodSp" or n=="PlayerList" then
                            v:Destroy()
                        end
                    end
                end
            end)
        end
    end
end)

-- Bloquear screenshot de abuso
_G.setfflag = true
spawn(function()
    while task.wait(1) do
        if _G.setfflag then
            pcall(function()
                setfflag("AbuseReportScreenshot", "False")
                setfflag("AbuseReportScreenshotPercentage", "0")
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  FUNÇÕES UTILITÁRIAS BÁSICAS
-- ════════════════════════════════════════════════════════════════════════════

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
    if not name or name == "" then return nil end
    return LocalPlayer.Backpack:FindFirstChild(name) or
           (GetChar() and GetChar():FindFirstChild(name))
end

local function CheckItem(name)
    local ok, inv = pcall(function()
        return CommF_:InvokeServer("getInventory")
    end)
    if not ok or not inv then return nil end
    for _, v in pairs(inv) do
        if v.Name == name then return v end
    end
    return nil
end

local function CheckMaterial(name)
    local ok, inv = pcall(function()
        return CommF_:InvokeServer("getInventory")
    end)
    if not ok or not inv then return 0 end
    for _, v in pairs(inv) do
        if v.Type == "Material" and v.Name == name then
            return v.Count or 0
        end
    end
    return 0
end

local function isnil(thing)
    return thing == nil
end

local function round(n)
    return math.floor(tonumber(n) + 0.5)
end

local Number = math.random(1, 1000000)

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE TELEPORTE (idêntico ao original)
-- ════════════════════════════════════════════════════════════════════════════

local function TP1(Pos)
    local hrp = GetHRP()
    if not hrp then return end
    local Distance = (Pos.Position - hrp.Position).Magnitude
    if GetHumanoid() and GetHumanoid().Sit == true then
        GetHumanoid().Sit = false
    end
    pcall(function()
        local tween = TweenService:Create(hrp, TweenInfo.new(Distance/210, Enum.EasingStyle.Linear), {CFrame = Pos})
        tween:Play()
        if Distance <= 250 then
            tween:Cancel()
            hrp.CFrame = Pos
        end
    end)
end

local function TP(Pos)
    local hrp = GetHRP()
    if not hrp then return end
    local Distance = (Pos.Position - hrp.Position).Magnitude
    local Speed
    if Distance < 10 then Speed = 20000
    elseif Distance < 25 then Speed = 10000
    elseif Distance < 50 then Speed = 5000
    elseif Distance < 150 then Speed = 2500
    elseif Distance < 250 then Speed = 1250
    elseif Distance < 500 then Speed = 625
    elseif Distance < 750 then Speed = 450
    else Speed = 370 end

    TweenService:Create(hrp, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = Pos}):Play()
    _G.Clip = true
    task.wait(Distance/Speed)
    _G.Clip = false
end

local function topos(Pos)
    local hrp = GetHRP()
    if not hrp then return end
    local Distance = (Pos.Position - hrp.Position).Magnitude
    if GetHumanoid() and GetHumanoid().Sit == true then
        GetHumanoid().Sit = false
    end
    pcall(function()
        local tween = TweenService:Create(hrp, TweenInfo.new(Distance/210, Enum.EasingStyle.Linear), {CFrame = Pos})
        tween:Play()
        if Distance <= 250 then
            tween:Cancel()
            hrp.CFrame = Pos
        end
    end)
end

local function BTP(P)
    pcall(function()
        local hrp = GetHRP()
        if not hrp then return end
        if (P.Position - hrp.Position).Magnitude >= 1500 then
            repeat
                task.wait()
                hrp = GetHRP()
                if not hrp then break end
                hrp.CFrame = P
                task.wait(0.05)
                if GetChar() and GetChar():FindFirstChild("Head") then
                    GetChar().Head:Destroy()
                end
                hrp = GetHRP()
                if hrp then hrp.CFrame = P end
            until not GetHRP() or (P.Position - GetHRP().Position).Magnitude < 1500
        end
    end)
end

local function InstancePos(pos)
    local hrp = GetHRP()
    if hrp then hrp.CFrame = pos end
end

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE EQUIPAR ARMAS
-- ════════════════════════════════════════════════════════════════════════════

local _G_NotAutoEquip = false

local function UnEquipWeapon(Weapon)
    if GetChar() and GetChar():FindFirstChild(Weapon) then
        _G_NotAutoEquip = true
        task.wait(0.5)
        pcall(function()
            GetChar():FindFirstChild(Weapon).Parent = LocalPlayer.Backpack
        end)
        task.wait(0.1)
        _G_NotAutoEquip = false
    end
end

local function EquipWeapon(ToolSe)
    if not _G_NotAutoEquip then
        pcall(function()
            if LocalPlayer.Backpack:FindFirstChild(ToolSe) then
                local Tool = LocalPlayer.Backpack:FindFirstChild(ToolSe)
                task.wait(0.1)
                GetHumanoid():EquipTool(Tool)
            end
        end)
    end
end

local function EquipWeaponSword()
    pcall(function()
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v.ToolTip == "Sword" and v:IsA("Tool") then
                GetHumanoid():EquipTool(v)
            end
        end
    end)
end

local function EquipAllWeapon()
    pcall(function()
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and not (v.Name == "Summon Sea Beast" or v.Name == "Water Body" or v.Name == "Awakening") then
                GetHumanoid():EquipTool(v)
                task.wait(1)
            end
        end
    end)
end

-- Auto seleção de arma por tipo
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if _G.Config.SelectWeapon == "Melee" then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Melee" then
                        _G.Config.SelectWeapon = v.Name
                    end
                end
            elseif _G.Config.SelectWeapon == "Sword" then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Sword" then
                        _G.Config.SelectWeapon = v.Name
                    end
                end
            elseif _G.Config.SelectWeapon == "Gun" then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Gun" then
                        _G.Config.SelectWeapon = v.Name
                    end
                end
            elseif _G.Config.SelectWeapon == "Fruit" then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Blox Fruit" then
                        _G.Config.SelectWeapon = v.Name
                    end
                end
            end
        end)
    end
end)

-- Detectar arma gun automaticamente
spawn(function()
    pcall(function()
        while task.wait() do
            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("RemoteFunctionShoot") then
                    SelectWeaponGun = v.Name
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE HAKI
-- ════════════════════════════════════════════════════════════════════════════

local function AutoHaki()
    pcall(function()
        if _G.Config.AutoBuso and not (GetChar() and GetChar():FindFirstChild("HasBuso")) then
            CommF_:InvokeServer("Buso")
        end
    end)
end

-- Auto Haki Ken (Observação) - ativa constantemente durante o farm
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.AutoFarm and _G.Config.AutoHakiKen then
                CommE:FireServer("Ken", true)
            end
        end)
    end
end)

-- Auto set spawn point
spawn(function()
    while task.wait(5) do
        pcall(function()
            CommF_:InvokeServer("SetSpawnPoint")
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE FAST ATTACK (COMPLETO DO ORIGINAL)
-- ════════════════════════════════════════════════════════════════════════════

-- Carregar CombatFramework para fast attack
pcall(function()
    getgenv().A = require(ReplicatedStorage.CombatFramework.RigLib).wrapAttackAnimationAsync
end)
pcall(function()
    getgenv().B = require(LocalPlayer.PlayerScripts.CombatFramework.Particle).play
end)

-- Patch de animação (do original)
local abc = true
task.spawn(function()
    local a = LocalPlayer
    local b = nil
    local c = nil
    pcall(function() b = require(a.PlayerScripts.CombatFramework.Particle) end)
    pcall(function() c = require(ReplicatedStorage.CombatFramework.RigLib) end)
    if not c then return end
    if not shared.orl then shared.orl = c.wrapAttackAnimationAsync end
    if not shared.cpc then
        pcall(function() shared.cpc = b.play end)
    end
    if abc then
        pcall(function()
            c.wrapAttackAnimationAsync = function(d, e, f, g, h)
                local i = c.getBladeHits(e, f, g)
                if i then
                    pcall(function() b.play = function() end end)
                    d:Play(0.1, 0.1, 0.1)
                    h(i)
                    pcall(function() b.play = shared.cpc end)
                    task.wait(0.5)
                    d:Stop()
                end
            end
        end)
    end
end)

-- Caclo (fast hit do original - método mais eficaz)
local Combatfram1 = nil
local Combatfram2 = nil
pcall(function()
    if debug and debug.getupvalues then
        Combatfram1 = debug.getupvalues(require(LocalPlayer.PlayerScripts.CombatFramework))
        if Combatfram1 then Combatfram2 = Combatfram1[2] end
    end
end)

local function GetCurrentBlade()
    pcall(function()
        local p13 = Combatfram2.activeController
        local ret = p13.blades[1]
        if not ret then return end
        while ret.Parent ~= GetChar() do
            ret = ret.Parent
        end
        return ret
    end)
end

local function Caclo()
    pcall(function()
        local a = LocalPlayer
        local b = nil
        pcall(function()
            if getupvalues then
                b = getupvalues(require(a.PlayerScripts.CombatFramework))[2]
            end
        end)
        if not b then return end
        local e = b.activeController
        for f = 1, 1 do
            local g = require(ReplicatedStorage.CombatFramework.RigLib).getBladeHits(
                a.Character, {a.Character.HumanoidRootPart}, 60)
            local h = {}
            local i = {}
            for j, k in pairs(g) do
                if k.Parent:FindFirstChild("HumanoidRootPart") and not i[k.Parent] then
                    table.insert(h, k.Parent.HumanoidRootPart)
                    i[k.Parent] = true
                end
            end
            g = h
            if #g > 0 then
                local l = debug.getupvalue(e.attack, 5)
                local m = debug.getupvalue(e.attack, 6)
                local n = debug.getupvalue(e.attack, 4)
                local o = debug.getupvalue(e.attack, 7)
                local p = (l * 798405 + n * 727595) % m
                local q = n * 798405
                p = (p * m + q) % 1099511627776
                l = math.floor(p / m)
                n = p - l * m
                o = o + 1
                debug.setupvalue(e.attack, 5, l)
                debug.setupvalue(e.attack, 6, m)
                debug.setupvalue(e.attack, 4, n)
                debug.setupvalue(e.attack, 7, o)
                pcall(function()
                    if a.Character:FindFirstChildOfClass("Tool") and e.blades and e.blades[1] then
                        e.animator.anims.basic[1]:Play(0.01, 0.01, 0.01)
                        ReplicatedStorage.RigControllerEvent:FireServer("weaponChange", tostring(GetCurrentBlade()))
                        ReplicatedStorage.Remotes.Validator:FireServer(math.floor(p / 1099511627776 * 16777215), o)
                        ReplicatedStorage.RigControllerEvent:FireServer("hit", g, f, "")
                    end
                end)
            end
        end
        b.activeController.timeToNextAttack = -math.huge
        b.activeController.attacking = false
        b.activeController.timeToNextBlock = 0
        b.activeController.humanoid.AutoRotate = 80
        b.activeController.increment = 4
        b.activeController.blocking = false
        b.activeController.hitboxMagnitude = 200
    end)
end

-- Configuração de attack
if not _G.AttackConfig then
    _G.AttackConfig = {
        ["Fast Attack Aura"] = true,
        ["Fast Attack Delay"] = 0.1,
    }
end

local LastAz = 0
RunService.Heartbeat:Connect(function()
    if UseFastAttack or _G.AttackConfig["Fast Attack Aura"] then
        if tick() - LastAz >= _G.AttackConfig["Fast Attack Delay"] then
            LastAz = tick()
            Caclo()
        end
    end
end)

-- RemoteAttack (fallback para quando Caclo não funciona)
local function RemoteAttack(target)
    pcall(function()
        local RS = ReplicatedStorage
        local Net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
        if Net then
            local RegisterAttack = Net["RE/RegisterAttack"]
            local RegisterHit = Net["RE/RegisterHit"]
            if RegisterAttack and RegisterHit and target then
                RegisterAttack:FireServer(0.0000001)
                RegisterHit:FireServer(target, {})
            end
        end
    end)
end

local function Click()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
    end)
end

-- Click automático
RunService.RenderStepped:Connect(function()
    if _G.AutoClick or Fastattack then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE PRIORIDADE (NOVO - interrompe farm para bosses/spawns raros)
-- ════════════════════════════════════════════════════════════════════════════

-- Lista de mobs prioritários por Sea
local MobsPrioritarios = {
    -- Bosses World 1
    "The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral",
    "Warden","Chief Warden","Swan","Saber Expert","Magma Admiral","Fishman Lord",
    "Wysper","Thunder God","Cyborg","Greybeard",
    -- Bosses World 2
    "Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral","Awakened Ice Admiral",
    "Tide Keeper","Order","Darkbeard","Cursed Captain",
    -- Bosses World 3
    "Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate",
    "Longma","Cake Queen","Soul Reaper","Cake Prince","Dough King",
    -- Elite Hunters
    "Diablo","Deandre","Urban",
    -- Spawns raros de Sea
    "Terrorshark","Shark",
}

local function CheckPrioridade()
    for _, bossName in ipairs(MobsPrioritarios) do
        local b = Workspace.Enemies:FindFirstChild(bossName)
        if b and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then
            return b
        end
        -- Também checar no ReplicatedStorage (boss à distância)
        local br = ReplicatedStorage:FindFirstChild(bossName)
        if br and br:FindFirstChild("HumanoidRootPart") then
            return br
        end
    end
    return nil
end

-- Monitor de prioridade - roda constantemente
spawn(function()
    while task.wait(2) do
        pcall(function()
            if not _G.AutoFarm then return end
            local alvo = CheckPrioridade()
            if alvo and not _G.PrioridadeAtiva then
                _G.PrioridadeAtiva = true
                _G.AlvoPrioridade = alvo
                StartMagnet = false
                if _G.UpdateStatus then
                    _G.UpdateStatus("⚡ PRIORIDADE: " .. alvo.Name, Color3.fromRGB(255, 100, 0))
                end
            elseif not alvo then
                _G.PrioridadeAtiva = false
                _G.AlvoPrioridade = nil
            end
        end)
    end
end)

-- Farm de prioridade (quando detecta boss/spawn raro)
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if not _G.AutoFarm then return end
            if not _G.PrioridadeAtiva then return end
            
            local alvo = _G.AlvoPrioridade
            if not alvo then
                _G.PrioridadeAtiva = false
                return
            end
            
            -- Verificar se o alvo ainda existe e está vivo
            local hrp = alvo:FindFirstChild("HumanoidRootPart")
            local hum = alvo:FindFirstChild("Humanoid")
            
            if not hrp or not hum or hum.Health <= 0 or not alvo.Parent then
                _G.PrioridadeAtiva = false
                _G.AlvoPrioridade = nil
                if _G.UpdateStatus then
                    _G.UpdateStatus("Prioridade concluída, retomando farm...", Color3.fromRGB(0, 255, 100))
                end
                return
            end
            
            -- Verificar se alvo está no ReplicatedStorage (longe)
            if alvo.Parent == ReplicatedStorage then
                topos(hrp.CFrame * CFrame.new(5, 10, 2))
                return
            end
            
            -- Atacar o alvo prioritário
            EquipWeapon(_G.Config.SelectWeapon)
            AutoHaki()
            hrp.CanCollide = false
            hum.WalkSpeed = 0
            hrp.Size = Vector3.new(80, 80, 80)
            topos(hrp.CFrame * CFrame.new(0, 30, 0))
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
            pcall(function()
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end)
            RemoteAttack(hrp)
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE POSIÇÃO ROTATIVA (Pos)
-- ════════════════════════════════════════════════════════════════════════════

local Type = 1
local PosY = _G.Config.PosY
local Pos = CFrame.new(0, PosY, -30)

spawn(function()
    while task.wait(0) do
        if Type == 1 then Pos = CFrame.new(0, PosY, -30)
        elseif Type == 2 then Pos = CFrame.new(30, PosY, 0)
        elseif Type == 3 then Pos = CFrame.new(0, PosY, 30)
        elseif Type == 4 then Pos = CFrame.new(-30, PosY, 0)
        end
    end
end)

spawn(function()
    while task.wait(0) do
        Type = 1; task.wait(0)
        Type = 2; task.wait(0)
        Type = 3; task.wait(0)
        Type = 4; task.wait(0)
        Type = 5; task.wait(0)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE BRING MOBS (completo do original)
-- ════════════════════════════════════════════════════════════════════════════

local function InMyNetWork(object)
    if isnetworkowner then
        return isnetworkowner(object)
    else
        if (object.Position - GetHRP().Position).Magnitude <= _G.Config.BringMode then
            return true
        end
        return false
    end
end

-- Noclip e floor durante farm
RunService.Heartbeat:Connect(function()
    if _G.AutoFarm then
        local c = GetChar()
        if not c then return end
        if not Workspace:FindFirstChild("LOL") then
            local LOL = Instance.new("Part")
            LOL.Name = "LOL"
            LOL.Parent = Workspace
            LOL.Anchored = true
            LOL.Transparency = 1
            LOL.Size = Vector3.new(30, -0.5, 30)
        elseif Workspace:FindFirstChild("LOL") then
            Workspace["LOL"].CFrame = (GetHRP() or c.HumanoidRootPart).CFrame * CFrame.new(0, -3.6, 0)
        end
    else
        if Workspace:FindFirstChild("LOL") then
            Workspace:FindFirstChild("LOL"):Destroy()
        end
    end
end)

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoFarm then
                local hrp = GetHRP()
                if hrp and not hrp:FindFirstChild("BodyClip") then
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "BodyClip"
                    Noclip.Parent = hrp
                    Noclip.MaxForce = Vector3.new(100000, 100000, 100000)
                    Noclip.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
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

-- Haki ken ativo durante farm
spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                CommE:FireServer("Ken", true)
            end)
        end
    end
end)

-- Highlight durante farm
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoFarm then
                if not GetChar():FindFirstChild("Highlight") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.FillColor = Color3.new(0, 255, 0)
                    Highlight.OutlineColor = Color3.new(0, 255, 0)
                    Highlight.Parent = GetChar()
                end
            end
        end
    end)
end)

-- SimulationRadius infinito
task.spawn(function()
    while true do
        task.wait()
        pcall(function()
            if setscriptable then
                setscriptable(LocalPlayer, "SimulationRadius", true)
            end
            if sethiddenproperty then
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end
end)

-- Bring Mob principal
spawn(function()
    while task.wait() do
        pcall(function()
            if not _G.Config.BringMonster then return end
            local hrp = GetHRP()
            if not hrp then return end

            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                -- Bring do farm de level (Mon)
                if _G.AutoFarm and StartMagnet and v.Name == Mon
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0 then
                    
                    local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                    local isBigMob = (Mon == "Factory Staff" or Mon == "Monkey" or Mon == "Dragon Crew Warrior" or Mon == "Dragon Crew Archer")
                    local threshold = isBigMob and 220 or _G.Config.BringMode
                    
                    if dist <= (isBigMob and 250 or threshold) then
                        local sz = isBigMob and 150 or 50
                        v.HumanoidRootPart.Size = Vector3.new(sz, sz, sz)
                        v.HumanoidRootPart.CFrame = PosMon
                        v.Humanoid:ChangeState(14)
                        v.HumanoidRootPart.CanCollide = false
                        pcall(function()
                            if v:FindFirstChild("Head") then v.Head.CanCollide = false end
                        end)
                        if v.Humanoid:FindFirstChild("Animator") then
                            v.Humanoid.Animator:Destroy()
                        end
                        pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                    end
                end

                -- Bring Mastery Fruit
                if StartMasteryFruitMagnet and (v.Name == "Monkey" or v.Name == "Factory Staff" or v.Name == Mon)
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - PosMonMasteryFruit.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = PosMonMasteryFruit
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Bone
                if StartMagnetBoneMon and (v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy")
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - PosMonBone.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = PosMonBone
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Dought/Cake farm
                if MagnetDought and (v.Name == "Cookie Crafter" or v.Name == "Cake Guard" or v.Name == "Baking Staff" or v.Name == "Head Baker")
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - PosMonDoughtOpenDoor.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = PosMonDoughtOpenDoor
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Ectoplasm
                if StartEctoplasmMagnet and string.find(v.Name, "Ship")
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - EctoplasmMon.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = EctoplasmMon
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Rengoku
                if StartRengokuMagnet and (v.Name == "Snow Lurker" or v.Name == "Arctic Warrior")
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - RengokuMon.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(1500, 1500, 1500)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = RengokuMon
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Musketeer Hat
                if StartMagnetMusketeerhat and v.Name == "Forest Pirate"
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - MusketeerHatMon.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = MusketeerHatMon
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Bartilo
                if AutoBartiloBring and v.Name == "Swan Pirate"
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - PosMonBarto.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = PosMonBarto
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Evo Race
                if StartEvoMagnet and v.Name == "Zombie"
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - PosMonEvo.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = PosMonEvo
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring GayMak / Material farm geral
                if MakoriGayMag and not string.find(v.Name, "Boss")
                    and v:FindFirstChild("HumanoidRootPart")
                    and (v.HumanoidRootPart.Position - hrp.Position).Magnitude <= _G.Config.BringMode then
                    pcall(function()
                        if InMyNetWork(v.HumanoidRootPart) then
                            v.HumanoidRootPart.CFrame = PosGay
                            if v:FindFirstChild("Humanoid") then
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.Humanoid:ChangeState(11)
                                v.Humanoid:ChangeState(14)
                                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                            end
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            v.HumanoidRootPart.Transparency = 1
                            v.HumanoidRootPart.CanCollide = false
                            pcall(function() v.Head.CanCollide = false end)
                        end
                    end)
                end

                -- Bring Farmfast (Shanda)
                if StardMag and v.Name == "Shanda"
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - FastMon.Position).Magnitude <= _G.Config.BringMode then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = FastMon
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring Ancient Race farm (Cocoa/Candy)
                if FarmMag and (v.Name == "Cocoa Warrior" or v.Name == "Chocolate Bar Battler" or v.Name == "Sweet Thief" or v.Name == "Candy Rebel")
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0
                    and (v.HumanoidRootPart.Position - PosGG.Position).Magnitude <= 250 then
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.Humanoid:ChangeState(14)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.CFrame = PosGG
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end

                -- Bring AutoSwordMastery
                if AutoSwordMasteryMag and not string.find(v.Name, "Boss")
                    and v:FindFirstChild("HumanoidRootPart")
                    and (v.HumanoidRootPart.Position - hrp.Position).Magnitude <= _G.Config.BringMode then
                    pcall(function()
                        if InMyNetWork(v.HumanoidRootPart) then
                            v.HumanoidRootPart.CFrame = PosMon
                            if v:FindFirstChild("Humanoid") then
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.Humanoid:ChangeState(11)
                                v.Humanoid:ChangeState(14)
                                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                            end
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            v.HumanoidRootPart.Transparency = 1
                            v.HumanoidRootPart.CanCollide = false
                            pcall(function() v.Head.CanCollide = false end)
                        end
                    end)
                end

            end -- for enemies
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE WALK WATER
-- ════════════════════════════════════════════════════════════════════════════

_G.Config.WalkWater = true
spawn(function()
    while task.wait(1) do
        pcall(function()
            if _G.Config.WalkWater then
                Workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000)
            else
                Workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000, 80, 1000)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  INFINITE ENERGY
-- ════════════════════════════════════════════════════════════════════════════

local originalstam = 0
pcall(function() originalstam = LocalPlayer.Character.Energy.Value end)

local function infinitestam()
    pcall(function()
        LocalPlayer.Character.Energy.Changed:connect(function()
            if _G.AutoFarm then
                LocalPlayer.Character.Energy.Value = originalstam
            end
        end)
    end)
end

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.AutoFarm then
                task.wait(0.1)
                pcall(function() originalstam = LocalPlayer.Character.Energy.Value end)
                infinitestam()
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  REMOVE CAMERA SHAKE
-- ════════════════════════════════════════════════════════════════════════════

pcall(function()
    local CamShake = require(ReplicatedStorage.Util.CameraShaker)
    CamShake:Stop()
    RunService.Heartbeat:Connect(function()
        pcall(function() CamShake:Stop() end)
    end)
end)

-- Remove damage counter
spawn(function()
    while task.wait() do
        pcall(function()
            ReplicatedStorage.Assets.GUI.DamageCounter.Enabled = false
        end)
    end
end)

-- Remove death effect
spawn(function()
    RunService.Stepped:Connect(function()
        pcall(function()
            for _, v in pairs(ReplicatedStorage.Effect.Container:GetChildren()) do
                if v.Name == "Death" then v:Destroy() end
            end
        end)
    end)
end)

-- Anti-AFK
LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  HOP (SERVER HOP)
-- ════════════════════════════════════════════════════════════════════════════

local function Hop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour

    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"))
        else
            Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything))
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        local num = 0
        for _, v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then Possible = false end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end
                    end
                    num = num + 1
                end
                if Possible then
                    table.insert(AllIDs, ID)
                    task.wait()
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceID, ID, LocalPlayer)
                    end)
                    task.wait(4)
                end
            end
        end
    end

    while task.wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then TPReturner() end
        end)
    end
end

print("[DragonHUB V3] Base carregada!")

-- ════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS COMPLETO - SEA 1
-- ════════════════════════════════════════════════════════════════════════════

local QuestMap_Sea1 = {
    {minLv=1,  maxLv=9,   mon="Bandit",             quest="BanditQuest1",  questLv=1,
     qpos=CFrame.new(1059.37195,15.4495068,1550.4231),     mpos=CFrame.new(1045.962646,27.00250816,1560.8203125)},
    {minLv=10, maxLv=14,  mon="Monkey",             quest="JungleQuest",   questLv=1,
     qpos=CFrame.new(-1598.08911,35.5501175,153.377838),   mpos=CFrame.new(-1448.51806640625,67.85301208,11.46579647)},
    {minLv=15, maxLv=29,  mon="Gorilla",            quest="JungleQuest",   questLv=2,
     qpos=CFrame.new(-1598.08911,35.5501175,153.377838),   mpos=CFrame.new(-1129.8836669921875,40.46354675,-525.4237060546875)},
    {minLv=30, maxLv=39,  mon="Pirate",             quest="BuggyQuest1",   questLv=1,
     qpos=CFrame.new(-1141.07483,4.10001802,3831.5498),    mpos=CFrame.new(-1103.513427734375,13.752052307,3896.091064453125)},
    {minLv=40, maxLv=59,  mon="Brute",              quest="BuggyQuest1",   questLv=2,
     qpos=CFrame.new(-1141.07483,4.10001802,3831.5498),    mpos=CFrame.new(-1140.083740234375,14.809885025,4322.92138671875)},
    {minLv=60, maxLv=74,  mon="Desert Bandit",      quest="DesertQuest",   questLv=1,
     qpos=CFrame.new(894.488647,5.14000702,4392.43359),    mpos=CFrame.new(924.7998046875,6.44867467,4481.5859375)},
    {minLv=75, maxLv=89,  mon="Desert Officer",     quest="DesertQuest",   questLv=2,
     qpos=CFrame.new(894.488647,5.14000702,4392.43359),    mpos=CFrame.new(1608.2822265625,8.614224433,4371.00732421875)},
    {minLv=90, maxLv=99,  mon="Snow Bandit",        quest="SnowQuest",     questLv=1,
     qpos=CFrame.new(1389.74451,88.1519318,-1298.90796),   mpos=CFrame.new(1354.347900390625,87.27277374,-1393.946533203125)},
    {minLv=100,maxLv=119, mon="Snowman",            quest="SnowQuest",     questLv=2,
     qpos=CFrame.new(1389.74451,88.1519318,-1298.90796),   mpos=CFrame.new(1201.6412353515625,144.57958984,-1550.0670166015625)},
    {minLv=120,maxLv=149, mon="Chief Petty Officer",quest="MarineQuest2",  questLv=1,
     qpos=CFrame.new(-5039.58643,27.3500385,4324.68018),   mpos=CFrame.new(-4881.23095703125,22.65204429,4273.75244140625)},
    {minLv=150,maxLv=174, mon="Sky Bandit",         quest="SkyQuest",      questLv=1,
     qpos=CFrame.new(-4839.53027,716.368591,-2619.44165),  mpos=CFrame.new(-4953.20703125,295.74420166,-2899.22900390625)},
    {minLv=175,maxLv=189, mon="Dark Master",        quest="SkyQuest",      questLv=2,
     qpos=CFrame.new(-4839.53027,716.368591,-2619.44165),  mpos=CFrame.new(-5259.8447265625,391.3976745,-2229.035400390625)},
    {minLv=190,maxLv=209, mon="Prisoner",           quest="PrisonerQuest", questLv=1,
     qpos=CFrame.new(5308.93115,1.65517521,475.120514),    mpos=CFrame.new(5098.9736328125,-0.3204058,474.2373352050781)},
    {minLv=210,maxLv=249, mon="Dangerous Prisoner", quest="PrisonerQuest", questLv=2,
     qpos=CFrame.new(5308.93115,1.65517521,475.120514),    mpos=CFrame.new(5654.5634765625,15.633401870,866.2991943359375)},
    {minLv=250,maxLv=274, mon="Toga Warrior",       quest="ColosseumQuest",questLv=1,
     qpos=CFrame.new(-1580.04663,6.35000277,-2986.47534),  mpos=CFrame.new(-1820.21484375,51.68385696,-2740.6650390625)},
    {minLv=275,maxLv=299, mon="Gladiator",          quest="ColosseumQuest",questLv=2,
     qpos=CFrame.new(-1580.04663,6.35000277,-2986.47534),  mpos=CFrame.new(-1292.838134765625,56.380882,-3339.031494140625)},
    {minLv=300,maxLv=324, mon="Military Soldier",   quest="MagmaQuest",    questLv=1,
     qpos=CFrame.new(-5313.37012,10.9500084,8515.29395),   mpos=CFrame.new(-5411.16455078125,11.081554412,8454.29296875)},
    {minLv=325,maxLv=374, mon="Military Spy",       quest="MagmaQuest",    questLv=2,
     qpos=CFrame.new(-5313.37012,10.9500084,8515.29395),   mpos=CFrame.new(-5802.8681640625,86.26241302,8828.859375)},
    {minLv=375,maxLv=399, mon="Fishman Warrior",    quest="FishmanQuest",  questLv=1,
     entrance=Vector3.new(61163.8515625,11.6796875,1819.7841796875),
     qpos=CFrame.new(61122.65234375,18.497442245483,1569.3997802734),
     mpos=CFrame.new(60878.30078125,18.482830047607,1543.7574462890625)},
    {minLv=400,maxLv=449, mon="Fishman Commando",   quest="FishmanQuest",  questLv=2,
     entrance=Vector3.new(61163.8515625,11.6796875,1819.7841796875),
     qpos=CFrame.new(61122.65234375,18.497442245483,1569.3997802734),
     mpos=CFrame.new(61922.6328125,18.482830047607,1493.934326171875)},
    {minLv=450,maxLv=474, mon="God's Guard",        quest="SkyExp1Quest",  questLv=1,
     entrance=Vector3.new(-4607.82275,872.54248,-1667.55688),
     qpos=CFrame.new(-4721.88867,843.874695,-1949.96643),
     mpos=CFrame.new(-4710.04296875,845.2769775,-1927.3079833984375)},
    {minLv=475,maxLv=524, mon="Shanda",             quest="SkyExp1Quest",  questLv=2,
     entrance=Vector3.new(-7894.6176757813,5547.1416015625,-380.29119873047),
     qpos=CFrame.new(-7859.09814,5544.19043,-381.476196),
     mpos=CFrame.new(-7678.48974609375,5566.40380859375,-497.2156066894531)},
    {minLv=525,maxLv=549, mon="Royal Squad",        quest="SkyExp2Quest",  questLv=1,
     qpos=CFrame.new(-7906.81592,5634.6626,-1411.99194),   mpos=CFrame.new(-7624.25244140625,5658.13330078125,-1467.354248046875)},
    {minLv=550,maxLv=624, mon="Royal Soldier",      quest="SkyExp2Quest",  questLv=2,
     qpos=CFrame.new(-7906.81592,5634.6626,-1411.99194),   mpos=CFrame.new(-7836.75341796875,5645.6640625,-1790.6236572265625)},
    {minLv=625,maxLv=649, mon="Galley Pirate",      quest="FountainQuest", questLv=1,
     qpos=CFrame.new(5259.81982,37.3500175,4050.0293),     mpos=CFrame.new(5551.02197265625,78.90135192,3930.412841796875)},
    {minLv=650,maxLv=700, mon="Galley Captain",     quest="FountainQuest", questLv=2,
     qpos=CFrame.new(5259.81982,37.3500175,4050.0293),     mpos=CFrame.new(5441.95166015625,42.50205993,4950.09375)},
}

-- ════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS COMPLETO - SEA 2
-- ════════════════════════════════════════════════════════════════════════════

local QuestMap_Sea2 = {
    {minLv=700, maxLv=724, mon="Raider",           quest="Area1Quest",         questLv=1,
     qpos=CFrame.new(-429.543518,71.7699966,1836.18188),   mpos=CFrame.new(-728.3267211914062,52.779319763,2345.7705078125)},
    {minLv=725, maxLv=774, mon="Mercenary",        quest="Area1Quest",         questLv=2,
     qpos=CFrame.new(-429.543518,71.7699966,1836.18188),   mpos=CFrame.new(-1004.3244018554688,80.15886688,1424.619384765625)},
    {minLv=775, maxLv=799, mon="Swan Pirate",      quest="Area2Quest",         questLv=1,
     qpos=CFrame.new(638.43811,71.769989,918.282898),      mpos=CFrame.new(1068.664306640625,137.61428833,1322.1060791015625)},
    {minLv=800, maxLv=874, mon="Factory Staff",    quest="Area2Quest",         questLv=2,
     qpos=CFrame.new(632.698608,73.1055908,918.666321),    mpos=CFrame.new(73.07867431640625,81.86344146,−27.470672607421875)},
    {minLv=875, maxLv=899, mon="Marine Lieutenant",quest="MarineQuest3",       questLv=1,
     qpos=CFrame.new(-2440.79639,71.7140732,-3216.06812),  mpos=CFrame.new(-2821.372314453125,75.89727783,-3070.089111328125)},
    {minLv=900, maxLv=949, mon="Marine Captain",   quest="MarineQuest3",       questLv=2,
     qpos=CFrame.new(-2440.79639,71.7140732,-3216.06812),  mpos=CFrame.new(-1861.2310791015625,80.17658233,-3254.697509765625)},
    {minLv=950, maxLv=974, mon="Zombie",           quest="ZombieQuest",        questLv=1,
     qpos=CFrame.new(-5497.06152,47.5923004,-795.237061),  mpos=CFrame.new(-5657.77685546875,78.96973419,-928.68701171875)},
    {minLv=975, maxLv=999, mon="Vampire",          quest="ZombieQuest",        questLv=2,
     qpos=CFrame.new(-5497.06152,47.5923004,-795.237061),  mpos=CFrame.new(-6037.66796875,32.18463897,-1340.6597900390625)},
    {minLv=1000,maxLv=1049,mon="Snow Trooper",     quest="SnowMountainQuest",  questLv=1,
     qpos=CFrame.new(609.858826,400.119904,-5372.25928),   mpos=CFrame.new(549.1473388671875,427.3870544,-5563.69873046875)},
    {minLv=1050,maxLv=1099,mon="Winter Warrior",   quest="SnowMountainQuest",  questLv=2,
     qpos=CFrame.new(609.858826,400.119904,-5372.25928),   mpos=CFrame.new(1142.7451171875,475.6398010,-5199.41650390625)},
    {minLv=1100,maxLv=1124,mon="Lab Subordinate",  quest="IceSideQuest",       questLv=1,
     qpos=CFrame.new(-6064.06885,15.2422857,-4902.97852),  mpos=CFrame.new(-5707.4716796875,15.95170974,-4513.39208984375)},
    {minLv=1125,maxLv=1174,mon="Horned Warrior",   quest="IceSideQuest",       questLv=2,
     qpos=CFrame.new(-6064.06885,15.2422857,-4902.97852),  mpos=CFrame.new(-6341.36669921875,15.9517707,-5723.162109375)},
    {minLv=1175,maxLv=1199,mon="Magma Ninja",      quest="FireSideQuest",      questLv=1,
     qpos=CFrame.new(-5428.03174,15.0622921,-5299.43457),  mpos=CFrame.new(-5449.6728515625,76.65874481,-5808.20068359375)},
    {minLv=1200,maxLv=1249,mon="Lava Pirate",      quest="FireSideQuest",      questLv=2,
     qpos=CFrame.new(-5428.03174,15.0622921,-5299.43457),  mpos=CFrame.new(-5213.33154296875,49.73788070,-4701.451171875)},
    {minLv=1250,maxLv=1274,mon="Ship Deckhand",    quest="ShipQuest1",         questLv=1,
     entrance=Vector3.new(923.21252441406,126.9760055542,32852.83203125),
     qpos=CFrame.new(1037.80127,125.092171,32911.6016),    mpos=CFrame.new(1212.0111083984375,150.79205322,33059.24609375)},
    {minLv=1275,maxLv=1299,mon="Ship Engineer",    quest="ShipQuest1",         questLv=2,
     entrance=Vector3.new(923.21252441406,126.9760055542,32852.83203125),
     qpos=CFrame.new(1037.80127,125.092171,32911.6016),    mpos=CFrame.new(919.4786376953125,43.54401397,32779.96875)},
    {minLv=1300,maxLv=1324,mon="Ship Steward",     quest="ShipQuest2",         questLv=1,
     entrance=Vector3.new(923.21252441406,126.9760055542,32852.83203125),
     qpos=CFrame.new(968.80957,125.092171,33244.125),      mpos=CFrame.new(919.4385375976562,129.55599975,33436.03515625)},
    {minLv=1325,maxLv=1349,mon="Ship Officer",     quest="ShipQuest2",         questLv=2,
     entrance=Vector3.new(923.21252441406,126.9760055542,32852.83203125),
     qpos=CFrame.new(968.80957,125.092171,33244.125),      mpos=CFrame.new(1036.0179443359375,181.4390411,33315.7265625)},
    {minLv=1350,maxLv=1374,mon="Arctic Warrior",   quest="FrostQuest",         questLv=1,
     entrance=Vector3.new(-6508.5581054688,5000.034996032715,-132.83953857422),
     qpos=CFrame.new(5667.6582,26.7997818,-6486.08984),    mpos=CFrame.new(5966.24609375,62.97002029,-6179.3828125)},
    {minLv=1375,maxLv=1424,mon="Snow Lurker",      quest="FrostQuest",         questLv=2,
     entrance=Vector3.new(-6508.5581054688,5000.034996032715,-132.83953857422),
     qpos=CFrame.new(5667.6582,26.7997818,-6486.08984),    mpos=CFrame.new(5407.07373046875,69.19437408,-6880.88037109375)},
    {minLv=1425,maxLv=1449,mon="Sea Soldier",      quest="ForgottenQuest",     questLv=1,
     qpos=CFrame.new(-3054.44458,235.544281,-10142.8193),  mpos=CFrame.new(-3028.2236328125,64.67451477,-9775.4267578125)},
    {minLv=1450,maxLv=9999,mon="Water Fighter",    quest="ForgottenQuest",     questLv=2,
     qpos=CFrame.new(-3054.44458,235.544281,-10142.8193),  mpos=CFrame.new(-3352.9013671875,285.01556396,-10534.841796875)},
}

-- ════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS COMPLETO - SEA 3
-- ════════════════════════════════════════════════════════════════════════════

local QuestMap_Sea3 = {
    {minLv=1500,maxLv=1524,mon="Pirate Millionaire",      quest="PiratePortQuest",  questLv=1,
     qpos=CFrame.new(-290.074677,42.9034653,5581.58984),  mpos=CFrame.new(-245.9963836669922,47.30615234,5584.1005859375)},
    {minLv=1525,maxLv=1574,mon="Pistol Billionaire",      quest="PiratePortQuest",  questLv=2,
     qpos=CFrame.new(-290.074677,42.9034653,5581.58984),  mpos=CFrame.new(-187.3301544189453,86.23987579,6013.513671875)},
    {minLv=1575,maxLv=1599,mon="Dragon Crew Warrior",     quest="AmazonQuest",      questLv=1,
     qpos=CFrame.new(5832.83594,51.6806107,-1101.51563),  mpos=CFrame.new(6141.140625,51.35136413,-1340.738525390625)},
    {minLv=1600,maxLv=1624,mon="Dragon Crew Archer",      quest="AmazonQuest",      questLv=2,
     qpos=CFrame.new(5833.1147460938,51.60498046875,-1103.0693359375),
     mpos=CFrame.new(6616.41748046875,441.7670593261719,446.0469970703125)},
    {minLv=1625,maxLv=1649,mon="Female Islander",         quest="AmazonQuest2",     questLv=1,
     entrance=Vector3.new(5446.8793945313,601.62945556641,749.45672607422),
     qpos=CFrame.new(5446.8793945313,601.62945556641,749.45672607422),
     mpos=CFrame.new(4685.25830078125,735.8078002929688,815.3425903320312)},
    {minLv=1650,maxLv=1699,mon="Giant Islander",          quest="AmazonQuest2",     questLv=2,
     entrance=Vector3.new(5446.8793945313,601.62945556641,749.45672607422),
     qpos=CFrame.new(5446.8793945313,601.62945556641,749.45672607422),
     mpos=CFrame.new(4729.09423828125,590.436767578125,-36.97627639770508)},
    {minLv=1700,maxLv=1724,mon="Marine Commodore",        quest="MarineTreeIsland", questLv=1,
     qpos=CFrame.new(2180.54126,27.8156815,-6741.5498),   mpos=CFrame.new(2286.0078125,73.13391876,-7159.80908203125)},
    {minLv=1725,maxLv=1774,mon="Marine Rear Admiral",     quest="MarineTreeIsland", questLv=2,
     qpos=CFrame.new(2179.98828125,28.731239318848,-6740.0551757813),
     mpos=CFrame.new(3656.773681640625,160.52406311,-7001.5986328125)},
    {minLv=1775,maxLv=1799,mon="Fishman Raider",          quest="DeepForestIsland3",questLv=1,
     qpos=CFrame.new(-10581.6563,330.872955,-8761.18652), mpos=CFrame.new(-10407.5263671875,331.76263427,-8368.5166015625)},
    {minLv=1800,maxLv=1824,mon="Fishman Captain",         quest="DeepForestIsland3",questLv=2,
     qpos=CFrame.new(-10581.6563,330.872955,-8761.18652), mpos=CFrame.new(-10994.701171875,352.38140869,-9002.1103515625)},
    {minLv=1825,maxLv=1849,mon="Forest Pirate",           quest="DeepForestIsland", questLv=1,
     entrance=Vector3.new(-12471.169921875,374.94024658203,-7551.677734375),
     qpos=CFrame.new(-13234.04,331.488495,-7625.40137),   mpos=CFrame.new(-13274.478515625,332.3781433,-7769.58056640625)},
    {minLv=1850,maxLv=1899,mon="Mythological Pirate",     quest="DeepForestIsland", questLv=2,
     entrance=Vector3.new(-12471.169921875,374.94024658203,-7551.677734375),
     qpos=CFrame.new(-13234.04,331.488495,-7625.40137),   mpos=CFrame.new(-13680.607421875,501.08154296,-6991.189453125)},
    {minLv=1900,maxLv=1924,mon="Jungle Pirate",           quest="DeepForestIsland2",questLv=1,
     entrance=Vector3.new(-12471.169921875,374.94024658203,-7551.677734375),
     qpos=CFrame.new(-12680.3818,389.971039,-9902.01953), mpos=CFrame.new(-12256.16015625,331.73828125,-10485.8369140625)},
    {minLv=1925,maxLv=1974,mon="Musketeer Pirate",        quest="DeepForestIsland2",questLv=2,
     entrance=Vector3.new(-12471.169921875,374.94024658203,-7551.677734375),
     qpos=CFrame.new(-12680.3818,389.971039,-9902.01953), mpos=CFrame.new(-13457.904296875,391.545654296875,-9859.177734375)},
    {minLv=1975,maxLv=1999,mon="Reborn Skeleton",         quest="HauntedQuest1",    questLv=1,
     qpos=CFrame.new(-9479.2168,141.215088,5566.09277),   mpos=CFrame.new(-8763.7236328125,165.72299194,6159.86181640625)},
    {minLv=2000,maxLv=2024,mon="Living Zombie",           quest="HauntedQuest1",    questLv=2,
     qpos=CFrame.new(-9479.2168,141.215088,5566.09277),   mpos=CFrame.new(-10144.1318359375,138.62667846,5838.0888671875)},
    {minLv=2025,maxLv=2049,mon="Demonic Soul",            quest="HauntedQuest2",    questLv=1,
     qpos=CFrame.new(-9516.99316,172.017181,6078.46533),  mpos=CFrame.new(-9505.8720703125,172.10482788,6158.9931640625)},
    {minLv=2050,maxLv=2074,mon="Posessed Mummy",          quest="HauntedQuest2",    questLv=2,
     qpos=CFrame.new(-9516.99316,172.017181,6078.46533),  mpos=CFrame.new(-9582.0224609375,6.25152730,6205.478515625)},
    {minLv=2075,maxLv=2099,mon="Peanut Scout",            quest="NutsIslandQuest",  questLv=1,
     qpos=CFrame.new(-2104.3908691406,38.104167938232,-10194.21875),
     mpos=CFrame.new(-2143.241943359375,47.72198486328125,-10029.9951171875)},
    {minLv=2100,maxLv=2124,mon="Peanut President",        quest="NutsIslandQuest",  questLv=2,
     qpos=CFrame.new(-2104.3908691406,38.104167938232,-10194.21875),
     mpos=CFrame.new(-1859.35400390625,38.10316848754883,-10422.4296875)},
    {minLv=2125,maxLv=2149,mon="Ice Cream Chef",          quest="IceCreamIslandQuest",questLv=1,
     qpos=CFrame.new(-820.64825439453,65.819526672363,-10965.795898438),
     mpos=CFrame.new(-872.24658203125,65.81957244873047,-10919.95703125)},
    {minLv=2150,maxLv=2199,mon="Ice Cream Commander",     quest="IceCreamIslandQuest",questLv=2,
     qpos=CFrame.new(-820.64825439453,65.819526672363,-10965.795898438),
     mpos=CFrame.new(-558.06103515625,112.04895782470703,-11290.7744140625)},
    {minLv=2200,maxLv=2224,mon="Cookie Crafter",          quest="CakeQuest1",       questLv=1,
     qpos=CFrame.new(-2021.32007,37.7982254,-12028.7295), mpos=CFrame.new(-2374.13671875,37.79826354980469,-12125.30859375)},
    {minLv=2225,maxLv=2249,mon="Cake Guard",              quest="CakeQuest1",       questLv=2,
     qpos=CFrame.new(-2021.32007,37.7982254,-12028.7295), mpos=CFrame.new(-1598.3070068359375,43.773197174,-12244.5810546875)},
    {minLv=2250,maxLv=2274,mon="Baking Staff",            quest="CakeQuest2",       questLv=1,
     qpos=CFrame.new(-1927.91602,37.7981339,-12842.5391), mpos=CFrame.new(-1887.8099365234375,77.6185073852539,-12998.3505859375)},
    {minLv=2275,maxLv=2299,mon="Head Baker",              quest="CakeQuest2",       questLv=2,
     qpos=CFrame.new(-1927.91602,37.7981339,-12842.5391), mpos=CFrame.new(-2216.188232421875,82.884521484375,-12869.2939453125)},
    {minLv=2300,maxLv=2324,mon="Cocoa Warrior",           quest="ChocQuest1",       questLv=1,
     qpos=CFrame.new(233.22836303710938,29.876001358032227,-12201.2333984375),
     mpos=CFrame.new(-21.55328369140625,80.57499694824219,-12352.3876953125)},
    {minLv=2325,maxLv=2349,mon="Chocolate Bar Battler",   quest="ChocQuest1",       questLv=2,
     qpos=CFrame.new(233.22836303710938,29.876001358032227,-12201.2333984375),
     mpos=CFrame.new(582.590576171875,77.18809509277344,-12463.162109375)},
    {minLv=2350,maxLv=2374,mon="Sweet Thief",             quest="ChocQuest2",       questLv=1,
     qpos=CFrame.new(150.5066375732422,30.693693161010742,-12774.5029296875),
     mpos=CFrame.new(165.1884765625,76.05885314941406,-12600.8369140625)},
    {minLv=2375,maxLv=2399,mon="Candy Rebel",             quest="ChocQuest2",       questLv=2,
     qpos=CFrame.new(150.5066375732422,30.693693161010742,-12774.5029296875),
     mpos=CFrame.new(134.86563110351562,77.2476806640625,-12876.5478515625)},
    {minLv=2400,maxLv=2424,mon="Candy Pirate",            quest="CandyQuest1",      questLv=1,
     qpos=CFrame.new(-1150.0400390625,20.378934860229492,-14446.3349609375),
     mpos=CFrame.new(-1310.5003662109375,26.016523361206055,-14562.404296875)},
    {minLv=2425,maxLv=2449,mon="Snow Demon",              quest="CandyQuest1",      questLv=2,
     qpos=CFrame.new(-1150.0400390625,20.378934860229492,-14446.3349609375),
     mpos=CFrame.new(-880.2006225585938,71.24776458740234,-14538.609375)},
    {minLv=2450,maxLv=2474,mon="Isle Outlaw",             quest="TikiQuest1",       questLv=1,
     qpos=CFrame.new(-16547.748046875,61.13533401489258,-173.41360473632812),
     mpos=CFrame.new(-16442.814453125,116.13899993896484,-264.4637756347656)},
    {minLv=2475,maxLv=2499,mon="Island Boy",              quest="TikiQuest1",       questLv=2,
     qpos=CFrame.new(-16547.748046875,61.13533401489258,-173.41360473632812),
     mpos=CFrame.new(-16901.26171875,84.06756591796875,-192.88906860351562)},
    {minLv=2500,maxLv=2524,mon="Sun-kissed Warrior",      quest="TikiQuest2",       questLv=1,
     qpos=CFrame.new(-16539.078125,55.68632888793945,1051.5738525390625),
     mpos=CFrame.new(-16349.8779296875,92.0808334350586,1123.4169921875)},
    {minLv=2525,maxLv=9999,mon="Isle Champion",           quest="TikiQuest2",       questLv=2,
     qpos=CFrame.new(-16539.078125,55.68632888793945,1051.5738525390625),
     mpos=CFrame.new(-16347.4150390625,92.09503936767578,1122.335205078125)},
}

-- ════════════════════════════════════════════════════════════════════════════
--  FUNÇÃO CHECK QUEST
-- ════════════════════════════════════════════════════════════════════════════

local function CheckQuest()
    MyLevel = LocalPlayer.Data.Level.Value
    local map = World1 and QuestMap_Sea1 or World2 and QuestMap_Sea2 or QuestMap_Sea3
    for _, data in ipairs(map) do
        if MyLevel >= data.minLv and MyLevel <= data.maxLv then
            CurrentQuestData = data
            Mon      = data.mon
            NameMon  = data.mon
            NameQuest= data.quest
            LevelQuest = data.questLv
            CFrameQuest = data.qpos
            CFrameMon   = data.mpos
            return
        end
    end
end

print("[DragonHUB V3] Mapas de quest carregados!")

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM LEVEL PRINCIPAL (com prioridade)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if not _G.AutoFarm then return end
            if _G.PrioridadeAtiva then return end  -- Cede prioridade

            local hrp = GetHRP()
            if not hrp then return end
            local hum = GetHumanoid()
            if not hum or hum.Health <= 0 then
                task.wait(5)
                return
            end

            CheckQuest()
            if not CurrentQuestData then return end
            MyLevel = LocalPlayer.Data.Level.Value

            -- Entrada para locais especiais (ilhas fechadas)
            if CurrentQuestData.entrance then
                local ent = CurrentQuestData.entrance
                local distEnt = (CFrameQuest.Position - hrp.Position).Magnitude
                if distEnt > 10000 then
                    CommF_:InvokeServer("requestEntrance", ent)
                    task.wait(2)
                end
            end

            local questVisible = false
            pcall(function()
                questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible
            end)

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

            -- Pegar a quest
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
                        task.wait(0.1); t = t + 0.1
                        hrp = GetHRP()
                        if not hrp then break end
                        if _G.PrioridadeAtiva then return end
                    until (CFrameQuest.Position - hrp.Position).Magnitude <= 5 or t >= 12
                end

                if _G.UpdateStatus then
                    _G.UpdateStatus("Pegando quest: " .. tostring(NameQuest), Color3.fromRGB(0, 200, 255))
                end
                CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                task.wait(0.5)
                StartMagnet = true
            end

            -- Atacar os mobs
            pcall(function() questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible end)
            if questVisible then
                StartMagnet = true
                CheckQuest()

                if Workspace.Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid")
                            and v.Humanoid.Health > 0 and v.Name == Mon then

                            local ok, title = pcall(function()
                                return LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                            end)

                            if ok and title and string.find(title, NameMon or "") then
                                if _G.UpdateStatus then
                                    _G.UpdateStatus("Atacando: " .. tostring(Mon), Color3.fromRGB(255, 80, 80))
                                end

                                repeat
                                    task.wait()
                                    if _G.PrioridadeAtiva then break end
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    AutoHaki()
                                    PosMon = v.HumanoidRootPart.CFrame
                                    TP1(v.HumanoidRootPart.CFrame * Pos)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                    StartMagnet = true
                                    RemoteAttack(v.HumanoidRootPart)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent
                                    or not LocalPlayer.PlayerGui.Main.Quest.Visible
                                    or _G.PrioridadeAtiva
                            else
                                StartMagnet = false
                                CommF_:InvokeServer("AbandonQuest")
                            end
                        end
                    end
                else
                    -- Mob não encontrado
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Procurando: " .. tostring(Mon), Color3.fromRGB(180, 180, 255))
                    end
                    StartMagnet = false
                    TP1(CFrameMon)
                    -- Tentar via ReplicatedStorage
                    local mobRS = ReplicatedStorage:FindFirstChild(Mon)
                    if mobRS and mobRS:FindFirstChild("HumanoidRootPart") then
                        TP1(mobRS.HumanoidRootPart.CFrame * CFrame.new(15, 10, 2))
                    end
                    task.wait(0.5)
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM MASTERY FRUIT (com skills)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.AutoFarmFruitMastery and not _G.PrioridadeAtiva then
            pcall(function()
                local QuestTitle = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                if not string.find(QuestTitle, NameMon or "") then
                    StartMasteryFruitMagnet = false
                    UseSkill = false
                    CommF_:InvokeServer("AbandonQuest")
                end
                local questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible
                if not questVisible then
                    StartMasteryFruitMagnet = false
                    UseSkill = false
                    CheckQuest()
                    repeat task.wait() TP1(CFrameQuest) until (CFrameQuest.Position - GetHRP().Position).Magnitude <= 3 or not _G.AutoFarmFruitMastery
                    if (CFrameQuest.Position - GetHRP().Position).Magnitude <= 5 then
                        task.wait(0.1)
                        CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                        task.wait(0.1)
                    end
                elseif questVisible then
                    CheckQuest()
                    if Workspace.Enemies:FindFirstChild(Mon) then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid")
                                and v.Humanoid.Health > 0 and v.Name == Mon then
                                if string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon or "") then
                                    local HealthMs = v.Humanoid.MaxHealth * _G.Config.KillAt / 100
                                    repeat task.wait()
                                        if _G.PrioridadeAtiva then break end
                                        if v.Humanoid.Health <= HealthMs then
                                            AutoHaki()
                                            EquipWeapon(LocalPlayer.Data.DevilFruit.Value)
                                            TP1(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                            v.HumanoidRootPart.CanCollide = false
                                            PosMonMasteryFruit = v.HumanoidRootPart.CFrame
                                            v.Humanoid.WalkSpeed = 0
                                            v.Head.CanCollide = false
                                            UseSkill = true
                                        else
                                            UseSkill = false
                                            AutoHaki()
                                            EquipWeapon(_G.Config.SelectWeapon)
                                            TP1(v.HumanoidRootPart.CFrame * Pos)
                                            v.HumanoidRootPart.CanCollide = false
                                            v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                            PosMonMasteryFruit = v.HumanoidRootPart.CFrame
                                            v.Humanoid.WalkSpeed = 0
                                            v.Head.CanCollide = false
                                        end
                                        StartMasteryFruitMagnet = true
                                        VirtualUser:CaptureController()
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    until not _G.AutoFarmFruitMastery or v.Humanoid.Health <= 0 or not v.Parent
                                        or not LocalPlayer.PlayerGui.Main.Quest.Visible or _G.PrioridadeAtiva
                                else
                                    UseSkill = false
                                    StartMasteryFruitMagnet = false
                                    CommF_:InvokeServer("AbandonQuest")
                                end
                            end
                        end
                    else
                        TP1(CFrameMon)
                        UnEquipWeapon(_G.Config.SelectWeapon)
                        StartMasteryFruitMagnet = false
                        UseSkill = false
                        local Mob = ReplicatedStorage:FindFirstChild(Mon)
                        if Mob then TP1(Mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)) end
                    end
                end
            end)
        end
    end
end)

-- Usar skills de fruit durante mastery
spawn(function()
    while task.wait() do
        if UseSkill or UseSkillKub then
            pcall(function()
                local fruitName = LocalPlayer.Data.DevilFruit.Value
                if fruitName == "" then return end
                local target = UseSkill and PosMonMasteryFruit or PosMonBone
                if GetChar() and GetChar():FindFirstChild(fruitName) then
                    GetChar()[fruitName].RemoteEvent:FireServer(target.Position)
                end
                if _G.Config.SkillZ then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Z", false, game)
                end
                if _G.Config.SkillX then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "X", false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "X", false, game)
                end
                if _G.Config.SkillC then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "C", false, game)
                end
                if _G.Config.SkillV then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "V", false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "V", false, game)
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM MASTERY SWORD
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoSwordMastery and not _G.PrioridadeAtiva then
                local QuestTitle = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                if not string.find(QuestTitle, NameMon or "") then
                    AutoSwordMasteryMag = false
                    CommF_:InvokeServer("AbandonQuest")
                end
                local questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible
                if not questVisible then
                    AutoSwordMasteryMag = false
                    CheckQuest()
                    TP1(CFrameQuest)
                    if (CFrameQuest.Position - GetHRP().Position).Magnitude <= 10 then
                        task.wait(0.1)
                        CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                    end
                elseif questVisible then
                    CheckQuest()
                    if Workspace.Enemies:FindFirstChild(Mon) then
                        pcall(function()
                            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                                if v.Name == Mon then
                                    repeat task.wait()
                                        if _G.PrioridadeAtiva then break end
                                        if string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon or "") then
                                            local HealthMin = v.Humanoid.MaxHealth * _G.Config.KillAt / 100
                                            if v.Humanoid.Health <= HealthMin then
                                                EquipWeaponSword()
                                                TP1(v.HumanoidRootPart.CFrame * Pos)
                                                v.Humanoid.WalkSpeed = 0
                                                v.HumanoidRootPart.CanCollide = false
                                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                                VirtualUser:CaptureController()
                                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                                v.Head.CanCollide = false
                                            else
                                                AutoHaki()
                                                EquipWeapon(_G.Config.SelectWeapon)
                                                v.Humanoid.WalkSpeed = 0
                                                v.HumanoidRootPart.CanCollide = false
                                                v.Head.CanCollide = false
                                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                                TP1(v.HumanoidRootPart.CFrame * Pos)
                                                VirtualUser:CaptureController()
                                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                            end
                                            AutoSwordMasteryMag = true
                                            PosMon = v.HumanoidRootPart.CFrame
                                        else
                                            AutoSwordMasteryMag = false
                                            CommF_:InvokeServer("AbandonQuest")
                                        end
                                    until v.Humanoid.Health <= 0 or not _G.AutoSwordMastery or not LocalPlayer.PlayerGui.Main.Quest.Visible or _G.PrioridadeAtiva
                                    AutoSwordMasteryMag = false
                                end
                            end
                        end)
                    else
                        TP1(CFrameMon)
                        UnEquipWeapon(_G.Config.SelectWeapon)
                        AutoSwordMasteryMag = false
                        local Mob = ReplicatedStorage:FindFirstChild(Mon)
                        if Mob then TP1(Mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)) end
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM GUN MASTERY
-- ════════════════════════════════════════════════════════════════════════════

local StartMasteryGunMagnet = false
local PosMonMasteryGun = CFrame.new(0, 30, 0)

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoFarmGunMastery and not _G.PrioridadeAtiva then
                local QuestTitle = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                if not string.find(QuestTitle, NameMon or "") then
                    StartMasteryGunMagnet = false
                    CommF_:InvokeServer("AbandonQuest")
                end
                local questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible
                if not questVisible then
                    StartMasteryGunMagnet = false
                    CheckQuest()
                    TP1(CFrameQuest)
                    if (CFrameQuest.Position - GetHRP().Position).Magnitude <= 10 then
                        task.wait(0.1)
                        CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                    end
                elseif questVisible then
                    CheckQuest()
                    if Workspace.Enemies:FindFirstChild(Mon) then
                        pcall(function()
                            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                                if v.Name == Mon then
                                    repeat task.wait()
                                        if _G.PrioridadeAtiva then break end
                                        if string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon or "") then
                                            local HealthMin = v.Humanoid.MaxHealth * _G.Config.KillAt / 100
                                            if v.Humanoid.Health <= HealthMin then
                                                EquipWeapon(SelectWeaponGun)
                                                TP1(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                                v.Humanoid.WalkSpeed = 0
                                                v.HumanoidRootPart.CanCollide = false
                                                v.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                                                v.Head.CanCollide = false
                                                if SelectWeaponGun ~= "" and GetChar():FindFirstChild(SelectWeaponGun) then
                                                    local args = {v.HumanoidRootPart.Position, v.HumanoidRootPart}
                                                    GetChar()[SelectWeaponGun].RemoteFunctionShoot:InvokeServer(unpack(args))
                                                end
                                            else
                                                AutoHaki()
                                                EquipWeapon(_G.Config.SelectWeapon)
                                                v.Humanoid.WalkSpeed = 0
                                                v.HumanoidRootPart.CanCollide = false
                                                v.Head.CanCollide = false
                                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                                TP1(v.HumanoidRootPart.CFrame * Pos)
                                                VirtualUser:CaptureController()
                                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                            end
                                            StartMasteryGunMagnet = true
                                            PosMonMasteryGun = v.HumanoidRootPart.CFrame
                                        else
                                            StartMasteryGunMagnet = false
                                            CommF_:InvokeServer("AbandonQuest")
                                        end
                                    until v.Humanoid.Health <= 0 or not _G.AutoFarmGunMastery or not LocalPlayer.PlayerGui.Main.Quest.Visible or _G.PrioridadeAtiva
                                    StartMasteryGunMagnet = false
                                end
                            end
                        end)
                    else
                        TP1(CFrameMon)
                        UnEquipWeapon(_G.Config.SelectWeapon)
                        local Mob = ReplicatedStorage:FindFirstChild(Mon)
                        if Mob then TP1(Mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)) end
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO STATS (correto - igual ao original)
-- ════════════════════════════════════════════════════════════════════════════

local PointStats = 1
spawn(function()
    while task.wait(2) do
        pcall(function()
            if not _G.Config.AutoStats then return end
            local points = LocalPlayer.Data.Points.Value
            if points < PointStats then return end
            local stat = _G.Config.StatPriority
            -- Mapeamento correto igual ao original
            local statMap = {
                Melee = "Melee", Defense = "Defense",
                Sword = "Sword", Gun = "Gun", Fruit = "Demon Fruit"
            }
            local statName = statMap[stat] or "Melee"
            CommF_:InvokeServer("AddPoint", statName, PointStats)
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO SEGUNDA MAR (corrigido)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(2) do
        if _G.AutoSecondSea and not _G.PrioridadeAtiva then
            pcall(function()
                MyLevel = LocalPlayer.Data.Level.Value
                if MyLevel < 700 or not World1 then return end
                _G.AutoFarm = false

                local Door = pcall(function() return Workspace.Map.Ice.Door end)
                local doorOpen = pcall(function()
                    return Workspace.Map.Ice.Door.CanCollide == false and Workspace.Map.Ice.Door.Transparency == 1
                end)

                if doorOpen then
                    -- Porta aberta, precisa matar Ice Admiral
                    if Workspace.Enemies:FindFirstChild("Ice Admiral") then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Ice Admiral" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                local OldCFrame = v.HumanoidRootPart.CFrame
                                repeat task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.CFrame = OldCFrame
                                    v.Humanoid.WalkSpeed = 0
                                    v.Head.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                until not _G.AutoSecondSea or not v.Parent or v.Humanoid.Health <= 0
                                -- Viajar
                                CommF_:InvokeServer("TravelDressrosa")
                                if _G.UpdateStatus then
                                    _G.UpdateStatus("Viajando para Second Sea!", Color3.fromRGB(0, 255, 100))
                                end
                            end
                        end
                    else
                        if ReplicatedStorage:FindFirstChild("Ice Admiral") then
                            topos(ReplicatedStorage:FindFirstChild("Ice Admiral").HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                        end
                    end
                else
                    -- Porta fechada - pegar chave
                    local KeyPos = CFrame.new(4849.29883, 5.65138149, 719.611877)
                    repeat topos(KeyPos); task.wait() until (KeyPos.Position - GetHRP().Position).Magnitude <= 3 or not _G.AutoSecondSea
                    task.wait(1.1)
                    CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
                    task.wait(0.5)
                    EquipWeapon("Key")
                    repeat topos(CFrame.new(1347.7124, 37.3751602, -1325.6488)); task.wait()
                    until (Vector3.new(1347.7124, 37.3751602, -1325.6488) - GetHRP().Position).Magnitude <= 3 or not _G.AutoSecondSea
                    task.wait(0.5)
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO TERCEIRA MAR (corrigido)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(2) do
        if _G.AutoThirdSea and not _G.PrioridadeAtiva then
            pcall(function()
                MyLevel = LocalPlayer.Data.Level.Value
                if MyLevel < 1500 or not World2 then return end
                _G.AutoFarm = false

                if CommF_:InvokeServer("ZQuestProgress", "General") == 0 then
                    topos(CFrame.new(-1926.3221435547, 12.819851875305, 1738.3092041016))
                    if (CFrame.new(-1926.3221435547, 12.819851875305, 1738.3092041016).Position - GetHRP().Position).Magnitude <= 10 then
                        task.wait(1.5)
                        CommF_:InvokeServer("ZQuestProgress", "Begin")
                    end
                    task.wait(1.8)
                    if Workspace.Enemies:FindFirstChild("rip_indra") then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "rip_indra" then
                                local OldCFrame = v.HumanoidRootPart.CFrame
                                repeat task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    v.HumanoidRootPart.CFrame = OldCFrame
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    CommF_:InvokeServer("TravelZou")
                                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                until not _G.AutoThirdSea or v.Humanoid.Health <= 0 or not v.Parent
                            end
                        end
                    else
                        local ripPos = CFrame.new(-26880.93359375, 22.848554611206, 473.18951416016)
                        if (ripPos.Position - GetHRP().Position).Magnitude <= 1000 then
                            topos(ripPos)
                        end
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM BONE (Sea 3) - No Quest e Quest
-- ════════════════════════════════════════════════════════════════════════════

local BonePos = CFrame.new(-9506.234375, 172.130615234375, 6117.0771484375)
local BoneQuestPos = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)

spawn(function()
    while task.wait() do
        if _G.Auto_Bone and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                local BoneMonsters = {"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}
                local BoneFMode = _G.BoneFMode or "No Quest"

                if BoneFMode == "No Quest" then
                    local found = false
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        for _, bn in ipairs(BoneMonsters) do
                            if v.Name == bn and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                found = true
                                repeat task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Head.CanCollide = false
                                    StartMagnetBoneMon = true
                                    PosMonBone = v.HumanoidRootPart.CFrame
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                until not _G.Auto_Bone or not v.Parent or v.Humanoid.Health <= 0 or _G.PrioridadeAtiva
                                break
                            end
                        end
                        if found then break end
                    end
                    if not found then
                        if _G.Config.BypassTP and (BonePos.Position - GetHRP().Position).Magnitude > 1500 then
                            BTP(BonePos)
                        else
                            topos(BonePos)
                        end
                        UnEquipWeapon(_G.Config.SelectWeapon)
                        StartMagnetBoneMon = false
                        for _, v in pairs(ReplicatedStorage:GetChildren()) do
                            for _, bn in ipairs(BoneMonsters) do
                                if v.Name == bn and v:FindFirstChild("HumanoidRootPart") then
                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                                end
                            end
                        end
                    end

                elseif BoneFMode == "Quest" then
                    local QuestTitle = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    if not string.find(QuestTitle, "Demonic Soul") then
                        StartMagnetBoneMon = false
                        CommF_:InvokeServer("AbandonQuest")
                    end
                    if not LocalPlayer.PlayerGui.Main.Quest.Visible then
                        StartMagnetBoneMon = false
                        if _G.Config.BypassTP and (BoneQuestPos.Position - GetHRP().Position).Magnitude > 1500 then
                            BTP(BoneQuestPos)
                        else
                            topos(BoneQuestPos)
                        end
                        if (BoneQuestPos.Position - GetHRP().Position).Magnitude <= 3 then
                            CommF_:InvokeServer("StartQuest", "HauntedQuest2", 1)
                        end
                    elseif LocalPlayer.PlayerGui.Main.Quest.Visible then
                        local found = false
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            for _, bn in ipairs(BoneMonsters) do
                                if v.Name == bn and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    found = true
                                    if string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Demonic Soul") then
                                        repeat task.wait()
                                            EquipWeapon(_G.Config.SelectWeapon)
                                            AutoHaki()
                                            PosMonBone = v.HumanoidRootPart.CFrame
                                            topos(v.HumanoidRootPart.CFrame * Pos)
                                            v.HumanoidRootPart.CanCollide = false
                                            v.Humanoid.WalkSpeed = 0
                                            v.Head.CanCollide = false
                                            v.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                            StartMagnetBoneMon = true
                                            VirtualUser:CaptureController()
                                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        until not _G.Auto_Bone or v.Humanoid.Health <= 0 or not v.Parent
                                            or not LocalPlayer.PlayerGui.Main.Quest.Visible or _G.PrioridadeAtiva
                                    else
                                        StartMagnetBoneMon = false
                                        CommF_:InvokeServer("AbandonQuest")
                                    end
                                    break
                                end
                            end
                            if found then break end
                        end
                        if not found then
                            StartMagnetBoneMon = false
                            local mRS = ReplicatedStorage:FindFirstChild("Demonic Soul [Lv. 2025]")
                            if mRS then topos(mRS.HumanoidRootPart.CFrame * CFrame.new(15, 10, 2)) end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Random Bone
spawn(function()
    pcall(function()
        while task.wait(0) do
            if _G.Auto_Random_Bone then
                CommF_:InvokeServer("Bones", "Buy", 1, 1)
            end
        end
    end)
end)

-- Auto Pray / Try Luck
spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.Pray then
                TP1(CFrame.new(-8652.99707, 143.450119, 6170.50879, -0.983064115, -2.48005533e-10, 0.18326205, -1.78910387e-09, 1, -8.24392288e-09, -0.18326205, -8.43218029e-09, -0.983064115))
                task.wait()
                CommF_:InvokeServer("gravestoneEvent", 1)
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.Trylux then
                TP1(CFrame.new(-8652.99707, 143.450119, 6170.50879, -0.983064115, -2.48005533e-10, 0.18326205, -1.78910387e-09, 1, -8.24392288e-09, -0.18326205, -8.43218029e-09, -0.983064115))
                task.wait()
                CommF_:InvokeServer("gravestoneEvent", 2)
            end
        end
    end)
end)

print("[DragonHUB V3] Farm principal carregado!")

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM CAKE PRINCE / DOUGH KING (Sea 3) - com Quest e No Quest
-- ════════════════════════════════════════════════════════════════════════════

local CakePos = CFrame.new(-2091.911865234375, 70.00884246826172, -12142.8359375)
local CakeQuestPos = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)

-- Contador de kills para abrir porta
local KillMob = 0
spawn(function()
    while task.wait(2) do
        pcall(function()
            local len = string.len(CommF_:InvokeServer("CakePrinceSpawner"))
            if len == 88 then KillMob = tonumber(string.sub(CommF_:InvokeServer("CakePrinceSpawner"), 39, 41)) - 500
            elseif len == 87 then KillMob = tonumber(string.sub(CommF_:InvokeServer("CakePrinceSpawner"), 40, 41)) - 500
            elseif len == 86 then KillMob = tonumber(string.sub(CommF_:InvokeServer("CakePrinceSpawner"), 41, 41)) - 500
            end
        end)
    end
end)

spawn(function()
    while task.wait() do
        if _G.AutoDoughtBoss and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                local CakeFMode = _G.CakeFMode or "No Quest"
                local CakeBosses = {"Cake Prince", "Dough King"}
                local PreBosses = {"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"}

                -- Verificar se o boss está spawnado
                for _, bname in ipairs(CakeBosses) do
                    if Workspace.Enemies:FindFirstChild(bname) then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == bname and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                until not _G.AutoDoughtBoss or not v.Parent or v.Humanoid.Health <= 0
                                return
                            end
                        end
                    end
                end

                -- Boss não spawnado - farmar pré-bosses para abrir porta
                if CakeFMode ~= "Quest" then
                    local preFound = false
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        for _, pbn in ipairs(PreBosses) do
                            if v.Name == pbn and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                preFound = true
                                repeat task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Head.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    MagnetDought = true
                                    PosMonDoughtOpenDoor = v.HumanoidRootPart.CFrame
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                until not _G.AutoDoughtBoss or not v.Parent or v.Humanoid.Health <= 0 or _G.PrioridadeAtiva
                                break
                            end
                        end
                        if preFound then break end
                    end
                    if not preFound then
                        MagnetDought = false
                        if _G.Config.BypassTP and (CakePos.Position - GetHRP().Position).Magnitude > 1500 then
                            BTP(CakePos)
                        else
                            topos(CakePos)
                        end
                        for _, pbn in ipairs(PreBosses) do
                            local mRS = ReplicatedStorage:FindFirstChild(pbn)
                            if mRS and mRS:FindFirstChild("HumanoidRootPart") then
                                topos(mRS.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                                break
                            end
                        end
                    end
                elseif CakeFMode == "Quest" then
                    local QuestTitle = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    if not string.find(QuestTitle, "Cookie Crafter") then
                        MagnetDought = false
                        CommF_:InvokeServer("AbandonQuest")
                    end
                    if not LocalPlayer.PlayerGui.Main.Quest.Visible then
                        MagnetDought = false
                        if _G.Config.BypassTP and (CakeQuestPos.Position - GetHRP().Position).Magnitude > 1500 then
                            BTP(CakeQuestPos)
                        else
                            topos(CakeQuestPos)
                        end
                        if (CakeQuestPos.Position - GetHRP().Position).Magnitude <= 3 then
                            CommF_:InvokeServer("StartQuest", "CakeQuest1", 1)
                        end
                    elseif LocalPlayer.PlayerGui.Main.Quest.Visible then
                        local found = false
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            for _, pbn in ipairs(PreBosses) do
                                if v.Name == pbn and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    found = true
                                    if string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Cookie Crafter") then
                                        repeat task.wait()
                                            EquipWeapon(_G.Config.SelectWeapon)
                                            AutoHaki()
                                            PosMonDoughtOpenDoor = v.HumanoidRootPart.CFrame
                                            topos(v.HumanoidRootPart.CFrame * Pos)
                                            v.HumanoidRootPart.CanCollide = false
                                            v.Humanoid.WalkSpeed = 0
                                            v.Head.CanCollide = false
                                            v.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                            MagnetDought = true
                                            VirtualUser:CaptureController()
                                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        until not _G.AutoDoughtBoss or not v.Parent
                                            or not LocalPlayer.PlayerGui.Main.Quest.Visible
                                            or v.Humanoid.Health <= 0 or _G.PrioridadeAtiva
                                    else
                                        MagnetDought = false
                                        CommF_:InvokeServer("AbandonQuest")
                                    end
                                    break
                                end
                            end
                            if found then break end
                        end
                        if not found then
                            MagnetDought = false
                            local mRS = ReplicatedStorage:FindFirstChild("Cookie Crafter")
                            if mRS then topos(mRS.HumanoidRootPart.CFrame * CFrame.new(15, 10, 2)) end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Dough King específico
spawn(function()
    while task.wait() do
        if _G.Autodoughking and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Dough King") then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == "Dough King" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                AutoHaki()
                                EquipWeapon(_G.Config.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                            until not _G.Autodoughking or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                else
                    UnEquipWeapon(_G.Config.SelectWeapon)
                    topos(CFrame.new(-2662.818603515625, 1062.3480224609375, -11853.6953125))
                    if ReplicatedStorage:FindFirstChild("Dough King") then
                        topos(ReplicatedStorage:FindFirstChild("Dough King").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO ECTOPLASM FARM (Sea 2)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoEctoplasm and not _G.PrioridadeAtiva then
                local ShipMobs = {"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"}
                local found = false
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    for _, sn in ipairs(ShipMobs) do
                        if v.Name == sn and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            found = true
                            repeat task.wait()
                                EquipWeapon(_G.Config.SelectWeapon)
                                AutoHaki()
                                if string.find(v.Name, "Ship") then
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Head.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    EctoplasmMon = v.HumanoidRootPart.CFrame
                                    StartEctoplasmMagnet = true
                                else
                                    StartEctoplasmMagnet = false
                                    topos(CFrame.new(911.35827636719, 125.95812988281, 33159.5390625))
                                end
                            until not _G.AutoEctoplasm or not v.Parent or v.Humanoid.Health <= 0
                            break
                        end
                    end
                    if found then break end
                end
                if not found then
                    StartEctoplasmMagnet = false
                    local dist = (Vector3.new(911.35827636719, 125.95812988281, 33159.5390625) - GetHRP().Position).Magnitude
                    if dist > 18000 then
                        CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                    end
                    topos(CFrame.new(911.35827636719, 125.95812988281, 33159.5390625))
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO RENGOKU (Sea 2)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoRengoku and not _G.PrioridadeAtiva then
                if HasWeapon("Hidden Key") or (GetChar() and GetChar():FindFirstChild("Hidden Key")) then
                    EquipWeapon("Hidden Key")
                    topos(CFrame.new(6571.1201171875, 299.23028564453, -6967.841796875))
                elseif Workspace.Enemies:FindFirstChild("Snow Lurker") or Workspace.Enemies:FindFirstChild("Arctic Warrior") then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if (v.Name == "Snow Lurker" or v.Name == "Arctic Warrior") and v.Humanoid and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                EquipWeapon(_G.Config.SelectWeapon)
                                AutoHaki()
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                RengokuMon = v.HumanoidRootPart.CFrame
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                StartRengokuMagnet = true
                            until HasWeapon("Hidden Key") or not _G.AutoRengoku or not v.Parent or v.Humanoid.Health <= 0
                            StartRengokuMagnet = false
                        end
                    end
                else
                    StartRengokuMagnet = false
                    topos(CFrame.new(5439.716796875, 84.420944213867, -6715.1635742188))
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO ELITE HUNTER (Sea 3)
-- ════════════════════════════════════════════════════════════════════════════

local ElitePos = CFrame.new(-5418.892578125, 313.74130249023, -2826.2260742188)

spawn(function()
    while task.wait() do
        if _G.AutoElitehunter and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                local QuestTitle = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                local questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible

                if not questVisible then
                    if _G.Config.BypassTP and (ElitePos.Position - GetHRP().Position).Magnitude > 1500 then
                        BTP(ElitePos)
                    else
                        topos(ElitePos)
                    end
                    if (Vector3.new(-5418.892578125, 313.74130249023, -2826.2260742188) - GetHRP().Position).Magnitude <= 3 then
                        CommF_:InvokeServer("EliteHunter")
                    end
                elseif questVisible then
                    local EliteBosses = {"Diablo","Deandre","Urban"}
                    if string.find(QuestTitle, "Diablo") or string.find(QuestTitle, "Deandre") or string.find(QuestTitle, "Urban") then
                        local found = false
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            for _, en in ipairs(EliteBosses) do
                                if v.Name == en and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    found = true
                                    repeat task.wait()
                                        AutoHaki()
                                        EquipWeapon(_G.Config.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        topos(v.HumanoidRootPart.CFrame * Pos)
                                        VirtualUser:CaptureController()
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                    until not _G.AutoElitehunter or v.Humanoid.Health <= 0 or not v.Parent
                                    break
                                end
                            end
                            if found then break end
                        end
                        if not found then
                            for _, en in ipairs(EliteBosses) do
                                local b = ReplicatedStorage:FindFirstChild(en)
                                if b and b:FindFirstChild("HumanoidRootPart") then
                                    topos(b.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                                    break
                                end
                            end
                            if not ReplicatedStorage:FindFirstChild("Diablo") and not ReplicatedStorage:FindFirstChild("Deandre") and not ReplicatedStorage:FindFirstChild("Urban") then
                                topos(ElitePos)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO MUSKETEER HAT / OBSERVATION HAKI V2 (Sea 3)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.AutoMusketeerHat and not _G.PrioridadeAtiva then
                local lv = LocalPlayer.Data.Level.Value
                if lv < 1800 then continue end

                local progress = CommF_:InvokeServer("CitizenQuestProgress")
                if progress and progress.KilledBandits == false then
                    -- Quest 1: matar 50 Forest Pirates
                    local qt = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    if string.find(qt, "Forest Pirate") and string.find(qt, "50") and LocalPlayer.PlayerGui.Main.Quest.Visible then
                        local found = false
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Forest Pirate" then
                                found = true
                                repeat task.wait()
                                    pcall(function()
                                        EquipWeapon(_G.Config.SelectWeapon)
                                        AutoHaki()
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        topos(v.HumanoidRootPart.CFrame * Pos)
                                        v.HumanoidRootPart.CanCollide = false
                                        VirtualUser:CaptureController()
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        MusketeerHatMon = v.HumanoidRootPart.CFrame
                                        StartMagnetMusketeerhat = true
                                    end)
                                until not _G.AutoMusketeerHat or not v.Parent or v.Humanoid.Health <= 0 or not LocalPlayer.PlayerGui.Main.Quest.Visible
                                StartMagnetMusketeerhat = false
                                break
                            end
                        end
                        if not found then
                            StartMagnetMusketeerhat = false
                            topos(CFrame.new(-13206.452148438, 425.89199829102, -7964.5537109375))
                        end
                    else
                        topos(CFrame.new(-12443.8671875, 332.40396118164, -7675.4892578125))
                        if (Vector3.new(-12443.8671875, 332.40396118164, -7675.4892578125) - GetHRP().Position).Magnitude <= 30 then
                            task.wait(1.5)
                            CommF_:InvokeServer("StartQuest", "CitizenQuest", 1)
                        end
                    end
                elseif progress and progress.KilledBoss == false then
                    -- Quest 2: matar Captain Elephant
                    local qt = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    if LocalPlayer.PlayerGui.Main.Quest.Visible and string.find(qt, "Captain Elephant") then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Captain Elephant" then
                                local OldCFrame = v.HumanoidRootPart.CFrame
                                repeat task.wait()
                                    pcall(function()
                                        EquipWeapon(_G.Config.SelectWeapon)
                                        AutoHaki()
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        topos(v.HumanoidRootPart.CFrame * Pos)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.CFrame = OldCFrame
                                        VirtualUser:CaptureController()
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                    end)
                                until not _G.AutoMusketeerHat or v.Humanoid.Health <= 0 or not v.Parent or not LocalPlayer.PlayerGui.Main.Quest.Visible
                                break
                            end
                        end
                    else
                        topos(CFrame.new(-12443.8671875, 332.40396118164, -7675.4892578125))
                        if (CFrame.new(-12443.8671875, 332.40396118164, -7675.4892578125).Position - GetHRP().Position).Magnitude <= 4 then
                            task.wait(1.5)
                            CommF_:InvokeServer("CitizenQuestProgress", "Citizen")
                        end
                    end
                elseif progress and CommF_:InvokeServer("CitizenQuestProgress", "Citizen") == 2 then
                    topos(CFrame.new(-12512.138671875, 340.39279174805, -9872.8203125))
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO EVO RACE V2 (Sea 2)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.Auto_EvoRace and not _G.PrioridadeAtiva then
                if not (GetChar() and GetChar():FindFirstChild("Evolved")) then
                    local alchResult = CommF_:InvokeServer("Alchemist", "1")
                    if alchResult == 0 then
                        topos(CFrame.new(-2779.83521, 72.9661407, -3574.02002, -0.730484903, 6.39014104e-08, -0.68292886, 3.59963224e-08, 1, 5.50667032e-08, 0.68292886, 1.56424669e-08, -0.730484903))
                        if (Vector3.new(-2779.83521, 72.9661407, -3574.02002) - GetHRP().Position).Magnitude <= 4 then
                            task.wait(1.3)
                            CommF_:InvokeServer("Alchemist", "2")
                        end
                    elseif alchResult == 1 then
                        pcall(function()
                            if not HasWeapon("Flower 1") and not (GetChar() and GetChar():FindFirstChild("Flower 1")) then
                                topos(Workspace.Flower1.CFrame)
                            elseif not HasWeapon("Flower 2") and not (GetChar() and GetChar():FindFirstChild("Flower 2")) then
                                topos(Workspace.Flower2.CFrame)
                            elseif not HasWeapon("Flower 3") and not (GetChar() and GetChar():FindFirstChild("Flower 3")) then
                                if Workspace.Enemies:FindFirstChild("Zombie") then
                                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                                        if v.Name == "Zombie" then
                                            repeat task.wait()
                                                AutoHaki()
                                                EquipWeapon(_G.Config.SelectWeapon)
                                                topos(v.HumanoidRootPart.CFrame * Pos)
                                                v.HumanoidRootPart.CanCollide = false
                                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                                VirtualUser:CaptureController()
                                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                                PosMonEvo = v.HumanoidRootPart.CFrame
                                                StartEvoMagnet = true
                                            until HasWeapon("Flower 3") or not v.Parent or v.Humanoid.Health <= 0 or not _G.Auto_EvoRace
                                            StartEvoMagnet = false
                                            break
                                        end
                                    end
                                else
                                    StartEvoMagnet = false
                                    topos(CFrame.new(-5685.9233398438, 48.480125427246, -853.23724365234))
                                end
                            end
                        end)
                    elseif alchResult == 2 then
                        CommF_:InvokeServer("Alchemist", "3")
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO BARTILO QUEST (Sea 2)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.AutoBartilo and not _G.PrioridadeAtiva then
                local lv = LocalPlayer.Data.Level.Value
                if lv < 800 then continue end

                local bProgress = CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
                if bProgress == 0 then
                    local qt = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    if string.find(qt, "Swan Pirates") and string.find(qt, "50") and LocalPlayer.PlayerGui.Main.Quest.Visible then
                        local found = false
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Swan Pirate" then
                                found = true
                                pcall(function()
                                    repeat task.wait()
                                        pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                        EquipWeapon(_G.Config.SelectWeapon)
                                        AutoHaki()
                                        v.HumanoidRootPart.Transparency = 1
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        topos(v.HumanoidRootPart.CFrame * Pos)
                                        PosMonBarto = v.HumanoidRootPart.CFrame
                                        VirtualUser:CaptureController()
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        AutoBartiloBring = true
                                    until not v.Parent or v.Humanoid.Health <= 0 or not _G.AutoBartilo or not LocalPlayer.PlayerGui.Main.Quest.Visible
                                    AutoBartiloBring = false
                                end)
                                break
                            end
                        end
                        if not found then
                            repeat topos(CFrame.new(932.624451, 156.106079, 1180.27466)) task.wait()
                            until not _G.AutoBartilo or (GetHRP().Position - Vector3.new(932.624451, 156.106079, 1180.27466)).Magnitude <= 10
                        end
                    else
                        repeat topos(CFrame.new(-456.28952, 73.0200958, 299.895966)) task.wait()
                        until not _G.AutoBartilo or (GetHRP().Position - Vector3.new(-456.28952, 73.0200958, 299.895966)).Magnitude <= 10
                        task.wait(1.1)
                        CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
                    end
                elseif bProgress == 1 then
                    if Workspace.Enemies:FindFirstChild("Jeremy") then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v.Name == "Jeremy" then
                                local OldCFrame = v.HumanoidRootPart.CFrame
                                repeat task.wait()
                                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    AutoHaki()
                                    v.HumanoidRootPart.Transparency = 1
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    v.HumanoidRootPart.CFrame = OldCFrame
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                until not v.Parent or v.Humanoid.Health <= 0 or not _G.AutoBartilo
                                break
                            end
                        end
                    else
                        repeat topos(CFrame.new(-456.28952, 73.0200958, 299.895966)) task.wait()
                        until not _G.AutoBartilo or (GetHRP().Position - Vector3.new(-456.28952, 73.0200958, 299.895966)).Magnitude <= 10
                        task.wait(1.1)
                        CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
                        task.wait(1)
                        repeat topos(CFrame.new(2099.88159, 448.931, 648.997375)) task.wait()
                        until not _G.AutoBartilo or (GetHRP().Position - Vector3.new(2099.88159, 448.931, 648.997375)).Magnitude <= 10
                        task.wait(2)
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO RAINBOW HAKI (Sea 3)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.Auto_Rainbow_Haki and not _G.PrioridadeAtiva then
                local qt = ""
                local questVisible = false
                pcall(function()
                    qt = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    questVisible = LocalPlayer.PlayerGui.Main.Quest.Visible
                end)

                local BossSequence = {
                    {name="Stone", pos=CFrame.new(-1086.11621, 38.8425903, 6768.71436)},
                    {name="Island Empress", pos=CFrame.new(5713.98877, 601.922974, 202.751251)},
                    {name="Kilo Admiral", pos=CFrame.new(2877.61743, 423.558685, -7207.31006)},
                    {name="Captain Elephant", pos=CFrame.new(-13485.0283, 331.709259, -8012.4873)},
                    {name="Beautiful Pirate", pos=CFrame.new(5312.3598632813, 20.141201019287, -10.158538818359)},
                }

                local npcHornedMan = CFrame.new(-11892.0703125, 930.57672119141, -8760.1591796875)

                if not questVisible then
                    topos(npcHornedMan)
                    if (npcHornedMan.Position - GetHRP().Position).Magnitude <= 30 then
                        task.wait(1.5)
                        CommF_:InvokeServer("HornedMan", "Bet")
                    end
                else
                    local handled = false
                    for _, boss in ipairs(BossSequence) do
                        if string.find(qt, boss.name) then
                            handled = true
                            if Workspace.Enemies:FindFirstChild(boss.name) then
                                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                                    if v.Name == boss.name then
                                        local OldCFrame = v.HumanoidRootPart.CFrame
                                        repeat task.wait()
                                            EquipWeapon(_G.Config.SelectWeapon)
                                            topos(v.HumanoidRootPart.CFrame * Pos)
                                            v.HumanoidRootPart.CanCollide = false
                                            v.HumanoidRootPart.CFrame = OldCFrame
                                            v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                            VirtualUser:CaptureController()
                                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                                            pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                        until not _G.Auto_Rainbow_Haki or v.Humanoid.Health <= 0 or not v.Parent or not questVisible
                                        break
                                    end
                                end
                            else
                                topos(boss.pos)
                            end
                            break
                        end
                    end
                    if not handled then
                        topos(npcHornedMan)
                        if (npcHornedMan.Position - GetHRP().Position).Magnitude <= 30 then
                            task.wait(1.5)
                            CommF_:InvokeServer("HornedMan", "Bet")
                        end
                    end
                end
            end
        end
    end)
end)

print("[DragonHUB V3] Farm especial carregado!")

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM MATERIAIS COMPLETO
-- ════════════════════════════════════════════════════════════════════════════

-- Função genérica para farmar material de um mob específico
local function FarmMaterial(config)
    -- config: { mobName, pos, world, bringTag }
    local found = false
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == config.mobName and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            found = true
            repeat task.wait()
                AutoHaki()
                EquipWeapon(_G.Config.SelectWeapon)
                v.HumanoidRootPart.CanCollide = false
                v.Humanoid.WalkSpeed = 0
                v.Head.CanCollide = false
                MakoriGayMag = true
                PosGay = v.HumanoidRootPart.CFrame
                topos(v.HumanoidRootPart.CFrame * Pos)
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
            until not config.flag() or not v.Parent or v.Humanoid.Health <= 0
            MakoriGayMag = false
            break
        end
    end
    if not found then
        if _G.Config.BypassTP and (config.pos.Position - GetHRP().Position).Magnitude > 1500 then
            BTP(config.pos)
        else
            topos(config.pos)
        end
        UnEquipWeapon(_G.Config.SelectWeapon)
        MakoriGayMag = false
        local mRS = ReplicatedStorage:FindFirstChild(config.mobName)
        if mRS and mRS:FindFirstChild("HumanoidRootPart") then
            topos(mRS.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
        end
    end
end

-- Radioactive (Factory Staff - Sea 2)
spawn(function()
    while task.wait() do
        if Radioactive and World2 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Factory Staff",
                    pos = CFrame.new(-507.7895202636719, 72.99479675292969, -126.45632934570312),
                    flag = function() return Radioactive end
                })
            end)
        end
    end
end)

-- Mystic Droplet (Water Fighter - Sea 2)
spawn(function()
    while task.wait() do
        if _G.Makori_gay and World2 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Water Fighter",
                    pos = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875),
                    flag = function() return _G.Makori_gay end
                })
            end)
        end
    end
end)

-- Magma Ore (Military Spy - Sea 1)
spawn(function()
    while task.wait() do
        if _G.Umm and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Military Spy",
                    pos = CFrame.new(-5850.2802734375, 77.28675079345703, 8848.6748046875),
                    flag = function() return _G.Umm end
                })
            end)
        end
    end
end)

-- Magma Ore (Lava Pirate - Sea 2)
spawn(function()
    while task.wait() do
        if _G.Umm and World2 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Lava Pirate",
                    pos = CFrame.new(-5234.60595703125, 51.953372955322266, -4732.27880859375),
                    flag = function() return _G.Umm end
                })
            end)
        end
    end
end)

-- Angel Wing (Royal Soldier - Sea 1)
spawn(function()
    while task.wait() do
        if _G.Auto_Wing and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Royal Soldier",
                    pos = CFrame.new(-7827.15625, 5606.912109375, -1705.5833740234375),
                    flag = function() return _G.Auto_Wing end
                })
            end)
        end
    end
end)

-- Leather (Pirate - Sea 1)
spawn(function()
    while task.wait() do
        if _G.Leather and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Pirate",
                    pos = CFrame.new(-1211.8792724609375, 4.787090301513672, 3916.83056640625),
                    flag = function() return _G.Leather end
                })
            end)
        end
    end
end)

-- Leather (Marine Captain - Sea 2)
spawn(function()
    while task.wait() do
        if _G.Leather and World2 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Marine Captain",
                    pos = CFrame.new(-2010.5059814453125, 73.00115966796875, -3326.620849609375),
                    flag = function() return _G.Leather end
                })
            end)
        end
    end
end)

-- Leather (Jungle Pirate - Sea 3)
spawn(function()
    while task.wait() do
        if _G.Leather and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Jungle Pirate",
                    pos = CFrame.new(-11975.78515625, 331.7734069824219, -10620.0302734375),
                    flag = function() return _G.Leather end
                })
            end)
        end
    end
end)

-- Scrap Metal (Brute - Sea 1)
spawn(function()
    while task.wait() do
        if Scrap and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Brute",
                    pos = CFrame.new(-1132.4202880859375, 14.844913482666016, 4293.30517578125),
                    flag = function() return Scrap end
                })
            end)
        end
    end
end)

-- Scrap Metal (Mercenary - Sea 2)
spawn(function()
    while task.wait() do
        if Scrap and World2 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Mercenary",
                    pos = CFrame.new(-972.307373046875, 73.04473876953125, 1419.2901611328125),
                    flag = function() return Scrap end
                })
            end)
        end
    end
end)

-- Scrap Metal (Pirate Millionaire - Sea 3)
spawn(function()
    while task.wait() do
        if Scrap and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Pirate Millionaire",
                    pos = CFrame.new(-289.6311950683594, 43.8282470703125, 5583.66357421875),
                    flag = function() return Scrap end
                })
            end)
        end
    end
end)

-- Conjured Cocoa (Chocolate Bar Battler - Sea 3)
spawn(function()
    while task.wait() do
        if Cocoafarm and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Chocolate Bar Battler",
                    pos = CFrame.new(744.7930908203125, 24.76934242248535, -12637.7255859375),
                    flag = function() return Cocoafarm end
                })
            end)
        end
    end
end)

-- Dragon Scale (Dragon Crew Warrior - Sea 3)
spawn(function()
    while task.wait() do
        if Dragon_Scale and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Dragon Crew Warrior",
                    pos = CFrame.new(5824.06982421875, 51.38640213012695, -1106.694580078125),
                    flag = function() return Dragon_Scale end
                })
            end)
        end
    end
end)

-- Gunpowder (Pistol Billionaire - Sea 3)
spawn(function()
    while task.wait() do
        if Gunpowder and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Pistol Billionaire",
                    pos = CFrame.new(-379.6134338378906, 73.84449768066406, 5928.5263671875),
                    flag = function() return Gunpowder end
                })
            end)
        end
    end
end)

-- Fish Tail (Fishman Captain - Sea 3)
spawn(function()
    while task.wait() do
        if Fish and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Fishman Captain",
                    pos = CFrame.new(-10961.0126953125, 331.7977600097656, -8914.29296875),
                    flag = function() return Fish end
                })
            end)
        end
    end
end)

-- Mini Tusk (Mythological Pirate - Sea 3)
spawn(function()
    while task.wait() do
        if MiniHee and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmMaterial({
                    mobName = "Mythological Pirate",
                    pos = CFrame.new(-13516.0458984375, 469.8182373046875, -6899.16064453125),
                    flag = function() return MiniHee end
                })
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM BOSSES ESPECÍFICOS
-- ════════════════════════════════════════════════════════════════════════════

-- Função genérica para farmar boss
local function FarmBoss(config)
    -- config: { bossName, pos, flagFn, hopFlagFn }
    if Workspace.Enemies:FindFirstChild(config.bossName) then
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v.Name == config.bossName and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                repeat task.wait()
                    AutoHaki()
                    EquipWeapon(_G.Config.SelectWeapon)
                    v.HumanoidRootPart.CanCollide = false
                    v.Humanoid.WalkSpeed = 0
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    topos(v.HumanoidRootPart.CFrame * Pos)
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                until not config.flagFn() or not v.Parent or v.Humanoid.Health <= 0
                break
            end
        end
    else
        if _G.Config.BypassTP and (config.pos.Position - GetHRP().Position).Magnitude > 1500 then
            BTP(config.pos)
        else
            topos(config.pos)
        end
        UnEquipWeapon(_G.Config.SelectWeapon)
        local bRS = ReplicatedStorage:FindFirstChild(config.bossName)
        if bRS and bRS:FindFirstChild("HumanoidRootPart") then
            topos(bRS.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
        else
            if config.hopFlagFn and config.hopFlagFn() then
                Hop()
            end
        end
    end
end

-- Greybeard (Sea 1)
local GayMakPos = CFrame.new(-5023.38330078125, 28.65203285217285, 4332.3818359375)
spawn(function()
    while task.wait() do
        if _G.Autogay and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Greybeard", pos=GayMakPos,
                    flagFn=function() return _G.Autogay end,
                    hopFlagFn=function() return _G.Autogayhop end
                })
            end)
        end
    end
end)

-- Don Swan (Swan Glasses - Sea 2)
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoFarmSwanGlasses and not _G.PrioridadeAtiva then
                if Workspace.Enemies:FindFirstChild("Don Swan") then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == "Don Swan" and v.Humanoid and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                pcall(function()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 670))
                                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                end)
                            until not _G.AutoFarmSwanGlasses or v.Humanoid.Health <= 0
                        end
                    end
                else
                    repeat task.wait()
                        CommF_:InvokeServer("requestEntrance", Vector3.new(2284.912109375, 15.537666320801, 905.48291015625))
                    until (CFrame.new(2284.912109375, 15.537666320801, 905.48291015625).Position - GetHRP().Position).Magnitude <= 4 or not _G.AutoFarmSwanGlasses
                end
            end
        end
    end)
end)

-- Rip_Indra (Dark Dagger - Sea 2/3)
local AdminPos = CFrame.new(-5344.822265625, 423.98541259766, -2725.0930175781)
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoDarkDagger and not _G.PrioridadeAtiva then
                if Workspace.Enemies:FindFirstChild("rip_indra True Form") or Workspace.Enemies:FindFirstChild("rip_indra") then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if (v.Name == "rip_indra True Form" or v.Name == "rip_indra") and v.Humanoid and v.Humanoid.Health > 0 and v:IsA("Model") then
                            repeat task.wait()
                                pcall(function()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 670), Workspace.CurrentCamera.CFrame)
                                end)
                            until not _G.AutoDarkDagger or v.Humanoid.Health <= 0
                        end
                    end
                else
                    if _G.Config.BypassTP and (AdminPos.Position - GetHRP().Position).Magnitude > 1500 then
                        BTP(AdminPos)
                    else
                        topos(AdminPos)
                    end
                    UnEquipWeapon(_G.Config.SelectWeapon)
                    topos(AdminPos)
                end
            end
        end
    end)
end)

-- Longma (Tushita - Sea 3)
local TushitaPos = CFrame.new(-10238.875976563, 389.7912902832, -9549.7939453125)
spawn(function()
    while task.wait() do
        if _G.Autotushita and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Longma", pos=TushitaPos,
                    flagFn=function() return _G.Autotushita end,
                    hopFlagFn=function() return _G.Autotushitahop end
                })
            end)
        end
    end
end)

-- Beautiful Pirate (Cavender - Sea 3)
local CavandisPos = CFrame.new(5311.07421875, 426.0243835449219, 165.12762451171875)
spawn(function()
    while task.wait() do
        if _G.AutoCarvender and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Beautiful Pirate", pos=CavandisPos,
                    flagFn=function() return _G.AutoCarvender end,
                    hopFlagFn=function() return _G.AutoCavanderhop end
                })
            end)
        end
    end
end)

-- Captain Elephant (Twin Hook - Sea 3)
local ElephantPos = CFrame.new(-13348.0654296875, 405.8904113769531, -8570.62890625)
spawn(function()
    while task.wait() do
        if _G.AutoTwinHook and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Captain Elephant", pos=ElephantPos,
                    flagFn=function() return _G.AutoTwinHook end,
                    hopFlagFn=function() return _G.AutoTwinHook_Hop end
                })
            end)
        end
    end
end)

-- Tide Keeper (Dragon Trident - Sea 2)
local TridentPos = CFrame.new(-3914.830322265625, 123.29389190673828, -11516.8642578125)
spawn(function()
    while task.wait() do
        if _G.Auto_Dragon_Trident and World2 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Tide Keeper", pos=TridentPos,
                    flagFn=function() return _G.Auto_Dragon_Trident end,
                    hopFlagFn=function() return _G.Auto_Dragon_Trident_Hop end
                })
            end)
        end
    end
end)

-- Chief Warden (Waden - Sea 1)
local NamfonPos = CFrame.new(5186.14697265625, 24.86684226989746, 832.1885375976562)
spawn(function()
    while task.wait() do
        if _G.Autowaden and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Chief Warden", pos=NamfonPos,
                    flagFn=function() return _G.Autowaden end,
                    hopFlagFn=function() return _G.Autowadenhop end
                })
            end)
        end
    end
end)

-- Thunder God (Pole - Sea 1)
local PolePos = CFrame.new(-7748.0185546875, 5606.80615234375, -2305.898681640625)
spawn(function()
    while task.wait() do
        if _G.Autopole and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Thunder God", pos=PolePos,
                    flagFn=function() return _G.Autopole end,
                    hopFlagFn=function() return _G.Autopolehop end
                })
            end)
        end
    end
end)

-- The Saw (Shark Saw - Sea 1)
local SharkSawPos = CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094)
spawn(function()
    while task.wait() do
        if _G.Autosaw and World1 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="The Saw", pos=SharkSawPos,
                    flagFn=function() return _G.Autosaw end,
                    hopFlagFn=function() return _G.Autosawhop end
                })
            end)
        end
    end
end)

-- Cake Queen (Buddy Sword - Sea 3)
local BigMomPos = CFrame.new(-731.2034301757812, 381.5658874511719, -11198.4951171875)
spawn(function()
    while task.wait() do
        if _G.AutoBudySword and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Cake Queen", pos=BigMomPos,
                    flagFn=function() return _G.AutoBudySword end,
                    hopFlagFn=function() return _G.AutoBudySwordHop end
                })
            end)
        end
    end
end)

-- Law Raid (Boss Order - Sea 2)
spawn(function()
    while task.wait() do
        if _G.autoLawRaid and not _G.PrioridadeAtiva then
            pcall(function()
                FarmBoss({ bossName="Order", pos=CFrame.new(-1926.3221435547, 12.819851875305, 1738.3092041016),
                    flagFn=function() return _G.autoLawRaid end,
                    hopFlagFn=function() return _G.autoLawRaidHop end
                })
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO KILL SHARKS / PIRANHAS (eventos de mar)
-- ════════════════════════════════════════════════════════════════════════════

local function FarmSeaEnemy(enemyName, flagFn)
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == enemyName and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local PosNara = v.HumanoidRootPart.CFrame
            repeat task.wait()
                AutoHaki()
                EquipWeapon(_G.Config.SelectWeapon)
                v.HumanoidRootPart.CanCollide = false
                v.Humanoid.WalkSpeed = 0
                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                PosNara = v.HumanoidRootPart.CFrame
                topos(v.HumanoidRootPart.CFrame * Pos)
                MakoriGayMag = true
                PosGay = PosNara
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
            until not flagFn() or not v.Parent or v.Humanoid.Health <= 0
            MakoriGayMag = false
            return true
        end
    end
    return false
end

spawn(function()
    while task.wait() do
        if _G.AutoTerrorshark and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                if not FarmSeaEnemy("Terrorshark", function() return _G.AutoTerrorshark end) then
                    local b = ReplicatedStorage:FindFirstChild("Terrorshark")
                    if b and b:FindFirstChild("HumanoidRootPart") then
                        topos(b.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if FarmShark and World3 and not _G.PrioridadeAtiva then
            pcall(function() FarmSeaEnemy("Shark", function() return FarmShark end) end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if _G.farmpiranya and World3 and not _G.PrioridadeAtiva then
            pcall(function() FarmSeaEnemy("Piranha", function() return _G.farmpiranya end) end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if _G.Fish_Crew_Member and World3 and not _G.PrioridadeAtiva then
            pcall(function() FarmSeaEnemy("Fish Crew Member", function() return _G.Fish_Crew_Member end) end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO SUPERHUMAN -> GODHUMAN EVOLUTION COMPLETA
-- ════════════════════════════════════════════════════════════════════════════

local FightingStyles = {
    "Godhuman","Dragon Talon","Electric Claw","Sharkman Karate",
    "Death Step","Superhuman","Dragon Claw","Fishman Karate",
    "Electro","Black Leg","Combat"
}

local function GetBestFightingStyle()
    for _, name in ipairs(FightingStyles) do
        if HasWeapon(name) then return name end
    end
    return "Combat"
end

spawn(function()
    while task.wait(5) do
        pcall(function()
            local beli  = LocalPlayer.Data.Beli.Value
            local frags = LocalPlayer.Data.Fragments.Value

            local function WeaponLevel(name)
                local w = HasWeapon(name)
                if w and w:FindFirstChild("Level") then return w.Level.Value end
                return 0
            end

            -- Combat -> Black Leg
            if HasWeapon("Combat") and beli >= 150000 and not HasWeapon("Black Leg") then
                UnEquipWeapon("Combat"); task.wait(0.2)
                CommF_:InvokeServer("BuyBlackLeg")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Black Leg!", Color3.fromRGB(0,255,100)) end
            end

            -- Black Leg -> Electro
            if HasWeapon("Black Leg") and WeaponLevel("Black Leg") >= 300 and beli >= 300000 and not HasWeapon("Electro") then
                UnEquipWeapon("Black Leg"); task.wait(0.2)
                CommF_:InvokeServer("BuyElectro")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Electro!", Color3.fromRGB(0,255,100)) end
            end

            -- Electro -> Fishman Karate
            if HasWeapon("Electro") and WeaponLevel("Electro") >= 300 and beli >= 750000 and not HasWeapon("Fishman Karate") then
                UnEquipWeapon("Electro"); task.wait(0.2)
                CommF_:InvokeServer("BuyFishmanKarate")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Fishman Karate!", Color3.fromRGB(0,255,100)) end
            end

            -- Fishman Karate -> Dragon Claw
            if HasWeapon("Fishman Karate") and WeaponLevel("Fishman Karate") >= 300 and frags >= 1500 and not HasWeapon("Dragon Claw") then
                UnEquipWeapon("Fishman Karate"); task.wait(0.2)
                CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
                CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Dragon Claw!", Color3.fromRGB(0,255,100)) end
            end

            -- Dragon Claw -> Superhuman
            if HasWeapon("Dragon Claw") and WeaponLevel("Dragon Claw") >= 300 and beli >= 3000000 and not HasWeapon("Superhuman") then
                UnEquipWeapon("Dragon Claw"); task.wait(0.2)
                CommF_:InvokeServer("BuySuperhuman")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Superhuman!", Color3.fromRGB(0,255,100)) end
            end

            -- Superhuman -> Death Step (Sea 3)
            if World3 and HasWeapon("Superhuman") and WeaponLevel("Superhuman") >= 400 and not HasWeapon("Death Step") then
                CommF_:InvokeServer("BuyDeathStep")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Death Step!", Color3.fromRGB(0,255,100)) end
            end

            -- Death Step -> Sharkman Karate (Sea 3)
            if World3 and HasWeapon("Death Step") and WeaponLevel("Death Step") >= 400 and not HasWeapon("Sharkman Karate") then
                CommF_:InvokeServer("BuySharkmanKarate")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Sharkman Karate!", Color3.fromRGB(0,255,100)) end
            end

            -- Sharkman -> Electric Claw (Sea 3)
            if World3 and HasWeapon("Sharkman Karate") and WeaponLevel("Sharkman Karate") >= 400 and not HasWeapon("Electric Claw") then
                CommF_:InvokeServer("BuyElectricClaw")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Electric Claw!", Color3.fromRGB(0,255,100)) end
            end

            -- Electric Claw -> Dragon Talon (Sea 3)
            if World3 and HasWeapon("Electric Claw") and WeaponLevel("Electric Claw") >= 400 and not HasWeapon("Dragon Talon") then
                CommF_:InvokeServer("BuyDragonTalon")
                if _G.UpdateStatus then _G.UpdateStatus("Comprou Dragon Talon!", Color3.fromRGB(0,255,100)) end
            end

            -- Dragon Talon -> Godhuman (Sea 3)
            if World3 and HasWeapon("Dragon Talon") and WeaponLevel("Dragon Talon") >= 400 and not HasWeapon("Godhuman") then
                CommF_:InvokeServer("BuyGodhuman")
                if _G.UpdateStatus then _G.UpdateStatus("Godhuman desbloqueado!", Color3.fromRGB(0,255,100)) end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO BUY HAKI ABILITIES
-- ════════════════════════════════════════════════════════════════════════════

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

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO REDEEM CODES
-- ════════════════════════════════════════════════════════════════════════════

local x2Codes = {
    "Sub2Fer999","Sub2OfficialNoobie","Sub2Daigrock","Enyu_yt","Starcodeheo",
    "Sub2Noobmaster123","Sub2GamerRobot","fudd10_v2","JCWK","Sub2UncleKizaru",
    "BYrantis","chandler","StrawHatMaine","sub2liveevil","Axiore","TantaiGaming",
    "fudd10","Sub2Brawlexe","Bluxxy","Magicbus","kittgaming"
}

spawn(function()
    task.wait(5)
    while task.wait(120) do
        pcall(function()
            if MyLevel < 10 then return end
            for _, code in ipairs(x2Codes) do
                CommF_:InvokeServer("Redeem", code)
                task.wait(0.1)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  PROTEÇÃO ANTI-MORTE
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(1) do
        pcall(function()
            if not _G.AutoFarm then return end
            local hum = GetHumanoid()
            local char = GetChar()
            if hum and hum.Health <= 0 then
                if _G.UpdateStatus then
                    _G.UpdateStatus("Morreu! Aguardando respawn...", Color3.fromRGB(255, 50, 50))
                end
                _G.AutoFarm = false
                StartMagnet = false
                MakoriGayMag = false
                local deadChar = char
                repeat task.wait(0.5) until GetChar() ~= deadChar
                task.wait(5)
                _G.AutoFarm = true
                if _G.UpdateStatus then
                    _G.UpdateStatus("Farm retomado!", Color3.fromRGB(100, 255, 100))
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  VERIFICADOR AUTOMÁTICO DE PROGRESSO (Sea transitions)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(15) do
        pcall(function()
            if not _G.AutoFarm then return end
            MyLevel = LocalPlayer.Data.Level.Value

            if World1 and MyLevel >= 700 and not _G.SeaTransitionDone then
                _G.AutoSecondSea = true
            elseif World2 and MyLevel >= 1500 and not _G.SeaTransitionDone then
                _G.AutoThirdSea = true
            end
        end)
    end
end)

print("[DragonHUB V3] Bosses e materiais carregados!")

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO DUNGEON / RAID SYSTEM (corrigido para Sea 2 e Sea 3)
-- ════════════════════════════════════════════════════════════════════════════

-- Auto buy chip
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoBuyChip then
                local hasMicro = HasWeapon("Special Microchip")
                if not hasMicro then
                    local island1 = Workspace._WorldOrigin.Locations:FindFirstChild("Island 1")
                    if not island1 then
                        CommF_:InvokeServer("RaidsNpc", "Select", _G.SelectChip or "Flame")
                    end
                end
            end
        end
    end)
end)

-- Auto start raid (CORRIGIDO - diferente por Sea)
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.Auto_StartRaid then
                if not LocalPlayer.PlayerGui.Main.Timer.Visible then
                    local island1 = Workspace._WorldOrigin.Locations:FindFirstChild("Island 1")
                    if not island1 and HasWeapon("Special Microchip") then
                        if World2 then
                            -- Sea 2: CircleIsland RaidSummon2
                            pcall(function()
                                fireclickdetector(Workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                            end)
                        elseif World3 then
                            -- Sea 3: Boat Castle RaidSummon2
                            pcall(function()
                                fireclickdetector(Workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto comprar chip específico (teleporte ao Lab corrigido)
spawn(function()
    while task.wait() do
        if _G.AutoBuyChip and _G.SelectChip then
            pcall(function()
                -- Verificar distância do Lab
                if World2 then
                    local labPos = CFrame.new(-6438.73535, 250.645355, -4501.50684)
                    if (labPos.Position - GetHRP().Position).Magnitude > 100 then
                        -- Está longe do lab, teleportar se necessário
                        if not HasWeapon("Special Microchip") and not Workspace._WorldOrigin.Locations:FindFirstChild("Island 1") then
                            topos(labPos)
                        end
                    end
                elseif World3 then
                    local labPos = CFrame.new(-5017.40869, 314.844055, -2823.0127)
                    if (labPos.Position - GetHRP().Position).Magnitude > 100 then
                        if not HasWeapon("Special Microchip") and not Workspace._WorldOrigin.Locations:FindFirstChild("Island 1") then
                            topos(labPos)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto selecionar chip baseado na fruta equipada
spawn(function()
    while task.wait() do
        if _G.AutoSelectDungeon then
            pcall(function()
                local fruitName = LocalPlayer.Data.DevilFruit.Value
                local chipMap = {
                    ["Flame-Flame"] = "Flame",
                    ["Ice-Ice"] = "Ice",
                    ["Quake-Quake"] = "Quake",
                    ["Light-Light"] = "Light",
                    ["Dark-Dark"] = "Dark",
                    ["String-String"] = "String",
                    ["Rumble-Rumble"] = "Rumble",
                    ["Magma-Magma"] = "Magma",
                    ["Sand-Sand"] = "Sand",
                    ["Bird-Bird: Phoenix"] = "Bird: Phoenix",
                    ["Dough-Dough"] = "Dough",
                    ["Human-Human: Buddha"] = "Human: Buddha",
                }
                if chipMap[fruitName] then
                    _G.SelectChip = chipMap[fruitName]
                else
                    _G.SelectChip = "Flame"
                end
            end)
        end
    end
end)

-- Auto next island durante raid
local RaidPos = CFrame.new(0, 25, 0)
local RaidType = 1

spawn(function()
    while task.wait(0.1) do
        if RaidType == 1 then RaidPos = CFrame.new(0,25,0)
        elseif RaidType == 2 then RaidPos = CFrame.new(0,25,-40)
        elseif RaidType == 3 then RaidPos = CFrame.new(40,25,0)
        elseif RaidType == 4 then RaidPos = CFrame.new(0,25,40)
        elseif RaidType == 5 then RaidPos = CFrame.new(-40,25,0)
        end
    end
end)

spawn(function()
    while task.wait(0.1) do
        RaidType = 1; task.wait(0.9)
        RaidType = 2; task.wait(0.9)
        RaidType = 3; task.wait(0.9)
        RaidType = 4; task.wait(0.9)
        RaidType = 5; task.wait(0.9)
    end
end)

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.Auto_Dungeon and not _G.PrioridadeAtiva then
                if LocalPlayer.PlayerGui.Main.Timer.Visible then
                    local locs = Workspace._WorldOrigin.Locations
                    for i = 5, 1, -1 do
                        local island = locs:FindFirstChild("Island " .. i)
                        if island then
                            topos(island.CFrame * RaidPos)
                            break
                        end
                    end
                end
            end
        end
    end)
end)

-- Kill Aura dentro da raid
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.Kill_Aura then
                if LocalPlayer.PlayerGui.Main.Timer.Visible then
                    for _, v in pairs(Workspace.Enemies:GetDescendants()) do
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            pcall(function()
                                repeat task.wait()
                                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                                    v.Humanoid.Health = 0
                                    v.HumanoidRootPart.CanCollide = false
                                until not _G.Kill_Aura or not v.Parent or v.Humanoid.Health <= 0
                            end)
                        end
                    end
                end
            end
        end
    end)
end)

-- Auto Law Raid (teleporta ao summon correto - Sea 2)
spawn(function()
    while task.wait() do
        if _G.AutoLawRaid and World2 and not _G.PrioridadeAtiva then
            pcall(function()
                if not LocalPlayer.Backpack:FindFirstChild("Law Microchip") then
                    CommF_:InvokeServer("BlackbeardReward", "Microchip", "2")
                end
                pcall(function()
                    fireclickdetector(Workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
                end)
            end)
        end
    end
end)

-- Auto awakening
spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.Auto_Awakener then
                CommF_:InvokeServer("Awakener", "Check")
                CommF_:InvokeServer("Awakener", "Awaken")
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO MIRAGE ISLAND
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoMysticIsland and not _G.PrioridadeAtiva then
                if Workspace.Map:FindFirstChild("MysticIsland") then
                    local center = Workspace.Map.MysticIsland.Center
                    topos(CFrame.new(center.Position.X, 500, center.Position.Z))
                end
            end
        end
    end)
end)

-- Auto teleportar ao Advanced Fruit Dealer
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.Miragenpc then
                if Workspace.NPCs:FindFirstChild("Advanced Fruit Dealer") then
                    topos(CFrame.new(Workspace.NPCs["Advanced Fruit Dealer"].HumanoidRootPart.Position))
                end
            end
        end
    end)
end)

-- Auto Gear Azul (Mirage Island)
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.TweenMGear and not _G.PrioridadeAtiva then
                if Workspace.Map:FindFirstChild("MysticIsland") then
                    for _, v in pairs(Workspace.Map.MysticIsland:GetChildren()) do
                        if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                            topos(v.CFrame)
                        end
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM CHEST (Mirage Island)
-- ════════════════════════════════════════════════════════════════════════════

_G.MagnitudeAdd = 0
spawn(function()
    while task.wait() do
        if _G.AutoChestMirage and not _G.PrioridadeAtiva then
            for _, v in pairs(Workspace:GetChildren()) do
                if v.Name:find("FragChest") and v:IsA("BasePart") then
                    if (v.Position - GetHRP().Position).Magnitude <= 5000 + _G.MagnitudeAdd then
                        repeat task.wait()
                            if Workspace:FindFirstChild(v.Name) then
                                topos(v.CFrame)
                            end
                        until not _G.AutoChestMirage or not v.Parent
                        _G.MagnitudeAdd = _G.MagnitudeAdd + 1500
                        break
                    end
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM CANDY (Sea 3)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.AutoFarmCandy and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                local candyMobs = {"Ice Cream Chef", "Ice Cream Commander"}
                local found = false
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    for _, cn in ipairs(candyMobs) do
                        if v.Name == cn and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            found = true
                            repeat task.wait()
                                AutoHaki()
                                EquipWeapon(_G.Config.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.Head.CanCollide = false
                                StartCandyMagnet = true
                                CandyMon = v.HumanoidRootPart.CFrame
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                            until not _G.AutoFarmCandy or not v.Parent or v.Humanoid.Health <= 0
                            StartCandyMagnet = false
                            break
                        end
                    end
                    if found then break end
                end
                if not found then
                    StartCandyMagnet = false
                    local candyPos = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438)
                    topos(candyPos)
                    for _, cn in ipairs(candyMobs) do
                        local mRS = ReplicatedStorage:FindFirstChild(cn)
                        if mRS and mRS:FindFirstChild("HumanoidRootPart") then
                            topos(mRS.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO PIRATE RAID (Sea 2 - Área especial)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.RaidPirate and not _G.PrioridadeAtiva then
            pcall(function()
                local CFrameBoss = CFrame.new(-5496.17432, 313.768921, -2841.53027)
                local raidAreaCenter = CFrame.new(-5539.3115234375, 313.800537109375, -2972.372314453125)

                if (raidAreaCenter.Position - GetHRP().Position).Magnitude <= 500 then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (v.HumanoidRootPart.Position - GetHRP().Position).Magnitude < 2000 then
                                repeat task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Config.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                until v.Humanoid.Health <= 0 or not v.Parent or not _G.RaidPirate
                            end
                        end
                    end
                else
                    UnEquipWeapon(_G.Config.SelectWeapon)
                    if _G.Config.BypassTP and (GetHRP().Position - CFrameBoss.Position).Magnitude > 1500 then
                        BTP(CFrameBoss)
                    else
                        topos(CFrameBoss)
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO KILL GHOST SHIP / RAID SHIP
-- ════════════════════════════════════════════════════════════════════════════

-- Aimbot para ships
local Skillaimbot = false
local AimBotSkillPosition = nil
local AutoSkill = false

local gg_meta = pcall(function() return getrawmetatable(game) end)
if gg_meta then
    pcall(function()
        local gg = getrawmetatable(game)
        local old_nc = gg.__namecall
        setreadonly(gg, false)
        gg.__namecall = newcclosure(function(...)
            local method = getnamecallmethod()
            local args = {...}
            if tostring(method) == "FireServer" then
                if tostring(args[1]) == "RemoteEvent" then
                    if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                        if Skillaimbot then
                            args[2] = AimBotSkillPosition
                            return old_nc(unpack(args))
                        end
                    end
                end
            end
            return old_nc(...)
        end)
    end)
end

spawn(function()
    while task.wait() do
        pcall(function()
            if AutoSkill then
                if _G.Config.SkillZ then
                    game:service("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                    task.wait(0.1)
                    game:service("VirtualInputManager"):SendKeyEvent(false, "Z", false, game)
                end
                if _G.Config.SkillX then
                    game:service("VirtualInputManager"):SendKeyEvent(true, "X", false, game)
                    task.wait(0.1)
                    game:service("VirtualInputManager"):SendKeyEvent(false, "X", false, game)
                end
                if _G.Config.SkillC then
                    game:service("VirtualInputManager"):SendKeyEvent(true, "C", false, game)
                    task.wait(0.1)
                    game:service("VirtualInputManager"):SendKeyEvent(false, "C", false, game)
                end
                if _G.Config.SkillV then
                    game:service("VirtualInputManager"):SendKeyEvent(true, "V", false, game)
                    task.wait(0.1)
                    game:service("VirtualInputManager"):SendKeyEvent(false, "V", false, game)
                end
            end
        end)
    end
end)

local function CheckPirateBoat()
    local checkList = {"FishBoat", "PirateGrandBrigade", "PirateBrigade"}
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if table.find(checkList, v.Name) and v:FindFirstChild("Health") and v.Health.Value > 0 then
            return v
        end
    end
end

spawn(function()
    while task.wait() do
        if _G.KillGhostShip and not _G.PrioridadeAtiva then
            pcall(function()
                local boat = CheckPirateBoat()
                if boat then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, 32, false, game)
                    task.wait(0.5)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, 32, false, game)
                    repeat
                        task.wait()
                        if boat.Engine then
                            topos(boat.Engine.CFrame * CFrame.new(0, -20, 0))
                        end
                        AimBotSkillPosition = GetHRP().CFrame * CFrame.new(0, -5, 0)
                        Skillaimbot = true
                        AutoSkill = false
                    until not boat or not boat.Parent or boat.Health.Value <= 0 or not CheckPirateBoat()
                    Skillaimbot = false
                    AutoSkill = false
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO SEA BEAST
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait(1) do
        if _G.AutoSeaBest and not _G.PrioridadeAtiva then
            pcall(function()
                for _, v in pairs(Workspace.SeaBeasts:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") then
                        AutoHaki()
                        EquipWeapon(_G.Config.SelectWeapon)
                        TP1(v.HumanoidRootPart.CFrame * CFrame.new(0, 300, 0))
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  EVENTOS ESPECIAIS (Mirage Island, Frozen Dimension, Kitsune Island)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.AutoFrozenDimension and not _G.PrioridadeAtiva then
            pcall(function()
                local frozen = Workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
                if frozen then
                    topos(frozen.CFrame * CFrame.new(0, 500, -100))
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if _G.AutoFKitsune and not _G.PrioridadeAtiva then
            pcall(function()
                local kitsune = Workspace._WorldOrigin.Locations:FindFirstChild("Kitsune Island")
                if kitsune then
                    topos(kitsune.CFrame * CFrame.new(0, 100, 0))
                end
            end)
        end
    end
end)

print("[DragonHUB V3] Sistemas de dungeon/raid/eventos carregados!")

-- ════════════════════════════════════════════════════════════════════════════
--  ESP SYSTEM COMPLETO
-- ════════════════════════════════════════════════════════════════════════════

local ESP = {
    Player = false, Chest = false, Fruit = false,
    Mob = false, Island = false, SeaBeast = false,
    NPC = false, Mirage = false, AFD = false
}

-- ESP Player
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, v in pairs(Players:GetChildren()) do
                if not isnil(v.Character) then
                    if ESP.Player then
                        if not isnil(v.Character.Head) and not v.Character.Head:FindFirstChild("NameEsp"..Number) then
                            local bill = Instance.new("BillboardGui", v.Character.Head)
                            bill.Name = "NameEsp"..Number
                            bill.ExtentsOffset = Vector3.new(0,1,0)
                            bill.Size = UDim2.new(1,200,1,30)
                            bill.Adornee = v.Character.Head
                            bill.AlwaysOnTop = true
                            local name = Instance.new("TextLabel", bill)
                            name.Font = Enum.Font.GothamSemibold
                            name.FontSize = Enum.FontSize.Size14
                            name.TextWrapped = true
                            name.Size = UDim2.new(1,0,1,0)
                            name.TextYAlignment = Enum.TextYAlignment.Top
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            if v.Team == LocalPlayer.Team then
                                name.TextColor3 = Color3.new(0,255,0)
                            else
                                name.TextColor3 = Color3.new(255,0,0)
                            end
                        elseif v.Character.Head:FindFirstChild("NameEsp"..Number) then
                            local dist = round((LocalPlayer.Character.Head.Position - v.Character.Head.Position).Magnitude/3)
                            local hp = round(v.Character.Humanoid.Health*100/v.Character.Humanoid.MaxHealth)
                            v.Character.Head["NameEsp"..Number].TextLabel.Text = v.Name.." | "..dist.."m | HP: "..hp.."%"
                        end
                    else
                        if v.Character.Head:FindFirstChild("NameEsp"..Number) then
                            v.Character.Head:FindFirstChild("NameEsp"..Number):Destroy()
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
                if string.find(v.Name,"Chest") then
                    if ESP.Chest then
                        if not v:FindFirstChild("NameEsp"..Number) then
                            local bill = Instance.new("BillboardGui",v)
                            bill.Name = "NameEsp"..Number
                            bill.ExtentsOffset = Vector3.new(0,1,0)
                            bill.Size = UDim2.new(1,200,1,30)
                            bill.Adornee = v
                            bill.AlwaysOnTop = true
                            local name = Instance.new("TextLabel",bill)
                            name.Font = Enum.Font.GothamSemibold
                            name.FontSize = Enum.FontSize.Size14
                            name.TextWrapped = true
                            name.Size = UDim2.new(1,0,1,0)
                            name.TextYAlignment = Enum.TextYAlignment.Top
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            if v.Name=="Chest1" then name.TextColor3=Color3.fromRGB(109,109,109)
                            elseif v.Name=="Chest2" then name.TextColor3=Color3.fromRGB(173,158,21)
                            elseif v.Name=="Chest3" then name.TextColor3=Color3.fromRGB(85,255,255) end
                        else
                            local dist = round((LocalPlayer.Character.Head.Position-v.Position).Magnitude/3)
                            v["NameEsp"..Number].TextLabel.Text = v.Name.."  \n"..dist.."m"
                        end
                    else
                        if v:FindFirstChild("NameEsp"..Number) then v:FindFirstChild("NameEsp"..Number):Destroy() end
                    end
                end
            end
        end)
    end
end)

-- ESP Devil Fruit
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, v in pairs(Workspace:GetChildren()) do
                if string.find(v.Name,"Fruit") and v:FindFirstChild("Handle") then
                    if ESP.Fruit then
                        if not v.Handle:FindFirstChild("NameEsp"..Number) then
                            local bill = Instance.new("BillboardGui",v.Handle)
                            bill.Name = "NameEsp"..Number
                            bill.ExtentsOffset = Vector3.new(0,1,0)
                            bill.Size = UDim2.new(1,200,1,30)
                            bill.Adornee = v.Handle
                            bill.AlwaysOnTop = true
                            local name = Instance.new("TextLabel",bill)
                            name.Font = Enum.Font.GothamSemibold
                            name.FontSize = Enum.FontSize.Size14
                            name.TextWrapped = true
                            name.Size = UDim2.new(1,0,1,0)
                            name.TextYAlignment = Enum.TextYAlignment.Top
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            name.TextColor3 = Color3.fromRGB(255,255,255)
                        else
                            local dist = round((LocalPlayer.Character.Head.Position-v.Handle.Position).Magnitude/3)
                            v.Handle["NameEsp"..Number].TextLabel.Text = v.Name.."  \n"..dist.."m"
                        end
                    else
                        if v.Handle:FindFirstChild("NameEsp"..Number) then v.Handle:FindFirstChild("NameEsp"..Number):Destroy() end
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
            if Workspace:FindFirstChild("Enemies") then
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") then
                        if ESP.Mob then
                            if not v:FindFirstChild("MobEsp") then
                                local bill = Instance.new("BillboardGui",v)
                                bill.Name = "MobEsp"
                                bill.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                                bill.Active = true
                                bill.AlwaysOnTop = true
                                bill.LightInfluence = 1
                                bill.Size = UDim2.new(0,200,0,50)
                                bill.StudsOffset = Vector3.new(0,2.5,0)
                                local name = Instance.new("TextLabel",bill)
                                name.BackgroundTransparency = 1
                                name.Size = UDim2.new(0,200,0,50)
                                name.Font = Enum.Font.GothamBold
                                name.TextColor3 = Color3.fromRGB(7,236,240)
                                name.TextSize = 14
                            else
                                local dist = round((GetHRP().Position-v.HumanoidRootPart.Position).Magnitude/3)
                                v.MobEsp.TextLabel.Text = v.Name.." - "..dist.."m"
                            end
                        else
                            if v:FindFirstChild("MobEsp") then v.MobEsp:Destroy() end
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
                                local bill = Instance.new("BillboardGui",v)
                                bill.Name = "NameEsp"
                                bill.ExtentsOffset = Vector3.new(0,1,0)
                                bill.Size = UDim2.new(1,200,1,30)
                                bill.Adornee = v
                                bill.AlwaysOnTop = true
                                local name = Instance.new("TextLabel",bill)
                                name.Font = Enum.Font.GothamBold
                                name.FontSize = Enum.FontSize.Size14
                                name.TextWrapped = true
                                name.Size = UDim2.new(1,0,1,0)
                                name.TextYAlignment = Enum.TextYAlignment.Top
                                name.BackgroundTransparency = 1
                                name.TextStrokeTransparency = 0.5
                                name.TextColor3 = Color3.fromRGB(7,236,240)
                            else
                                local dist = round((LocalPlayer.Character.Head.Position-v.Position).Magnitude/3)
                                v.NameEsp.TextLabel.Text = v.Name.."  \n"..dist.."m"
                            end
                        else
                            if v:FindFirstChild("NameEsp") then v:FindFirstChild("NameEsp"):Destroy() end
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP SeaBeast
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Workspace:FindFirstChild("SeaBeasts") then
                for _, v in pairs(Workspace.SeaBeasts:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") then
                        if ESP.SeaBeast then
                            if not v:FindFirstChild("SeaespsV3") then
                                local bill = Instance.new("BillboardGui",v)
                                bill.Name = "SeaespsV3"
                                bill.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                                bill.Active = true
                                bill.AlwaysOnTop = true
                                bill.LightInfluence = 1
                                bill.Size = UDim2.new(0,200,0,50)
                                bill.StudsOffset = Vector3.new(0,2.5,0)
                                local name = Instance.new("TextLabel",bill)
                                name.BackgroundTransparency = 1
                                name.Size = UDim2.new(0,200,0,50)
                                name.Font = Enum.Font.GothamBold
                                name.TextColor3 = Color3.fromRGB(255,0,255)
                                name.TextSize = 14
                            else
                                local dist = round((GetHRP().Position-v.HumanoidRootPart.Position).Magnitude/3)
                                v.SeaespsV3.TextLabel.Text = v.Name.." - "..dist.."m"
                            end
                        else
                            if v:FindFirstChild("SeaespsV3") then v.SeaespsV3:Destroy() end
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Mirage Island
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations") then
                for _, v in pairs(Workspace._WorldOrigin.Locations:GetChildren()) do
                    if v.Name == "Mirage Island" then
                        if ESP.Mirage then
                            if not v:FindFirstChild("MirageEsp") then
                                local bill = Instance.new("BillboardGui",v)
                                bill.Name = "MirageEsp"
                                bill.ExtentsOffset = Vector3.new(0,1,0)
                                bill.Size = UDim2.new(1,200,1,30)
                                bill.Adornee = v
                                bill.AlwaysOnTop = true
                                local name = Instance.new("TextLabel",bill)
                                name.Font = "Code"
                                name.FontSize = Enum.FontSize.Size14
                                name.TextWrapped = true
                                name.Size = UDim2.new(1,0,1,0)
                                name.TextYAlignment = Enum.TextYAlignment.Top
                                name.BackgroundTransparency = 1
                                name.TextStrokeTransparency = 0.5
                                name.TextColor3 = Color3.fromRGB(80,245,245)
                            else
                                local dist = round((LocalPlayer.Character.Head.Position-v.Position).Magnitude/3)
                                v.MirageEsp.TextLabel.Text = "Mirage Island  \n"..dist.."m"
                            end
                        else
                            if v:FindFirstChild("MirageEsp") then v:FindFirstChild("MirageEsp"):Destroy() end
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Real Fruits (spawners de frutas reais)
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local spawners = {"AppleSpawner","PineappleSpawner","BananaSpawner"}
            local colors = {
                Apple=Color3.fromRGB(255,0,0),
                Pineapple=Color3.fromRGB(255,174,0),
                Banana=Color3.fromRGB(251,255,0)
            }
            if ESP.Fruit then
                for _, sName in ipairs(spawners) do
                    if Workspace:FindFirstChild(sName) then
                        for _, v in pairs(Workspace[sName]:GetChildren()) do
                            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                                if not v.Handle:FindFirstChild("RealFruitEsp"..Number) then
                                    local bill = Instance.new("BillboardGui",v.Handle)
                                    bill.Name = "RealFruitEsp"..Number
                                    bill.ExtentsOffset = Vector3.new(0,1,0)
                                    bill.Size = UDim2.new(1,200,1,30)
                                    bill.Adornee = v.Handle
                                    bill.AlwaysOnTop = true
                                    local name = Instance.new("TextLabel",bill)
                                    name.Font = Enum.Font.GothamSemibold
                                    name.FontSize = Enum.FontSize.Size14
                                    name.TextWrapped = true
                                    name.Size = UDim2.new(1,0,1,0)
                                    name.TextYAlignment = Enum.TextYAlignment.Top
                                    name.BackgroundTransparency = 1
                                    name.TextStrokeTransparency = 0.5
                                    local prefix = sName:gsub("Spawner","")
                                    name.TextColor3 = colors[prefix] or Color3.fromRGB(255,255,255)
                                    name.Text = v.Name.." \n"..round((LocalPlayer.Character.Head.Position-v.Handle.Position).Magnitude/3).."m"
                                else
                                    local dist = round((LocalPlayer.Character.Head.Position-v.Handle.Position).Magnitude/3)
                                    v.Handle["RealFruitEsp"..Number].TextLabel.Text = v.Name.." "..dist.."m"
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Ativar ESP automaticamente após 15s
task.spawn(function()
    task.wait(15)
    ESP.Player  = true
    ESP.Chest   = true
    ESP.Fruit   = true
    ESP.Mob     = true
    ESP.Island  = true
    ESP.SeaBeast= true
    ESP.Mirage  = true
    if _G.UpdateStatus then
        _G.UpdateStatus("ESP Ativado!", Color3.fromRGB(0,255,100))
    end
end)

print("[DragonHUB V3] ESP carregado!")

-- ════════════════════════════════════════════════════════════════════════════
--  INTERFACE GRÁFICA (GUI) - LOADER + CONTROLES + STATUS
-- ════════════════════════════════════════════════════════════════════════════

if CoreGui:FindFirstChild("DragonHubV3Auto") then
    CoreGui.DragonHubV3Auto:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DragonHubV3Auto"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer.PlayerGui
end

local MainColor = Color3.fromRGB(200, 0, 0)
local DarkBg    = Color3.fromRGB(12, 12, 12)
local GrayText  = Color3.fromRGB(160, 160, 160)

-- ── LOADER ──────────────────────────────────────────────────────────────────

local LoaderFrame = Instance.new("Frame", ScreenGui)
LoaderFrame.Size = UDim2.new(0, 370, 0, 220)
LoaderFrame.Position = UDim2.new(0.5, -185, 0.5, -110)
LoaderFrame.BackgroundColor3 = DarkBg
LoaderFrame.BorderSizePixel = 0
LoaderFrame.ClipsDescendants = true
Instance.new("UICorner", LoaderFrame).CornerRadius = UDim.new(0, 12)
local UIStrokeL = Instance.new("UIStroke", LoaderFrame)
UIStrokeL.Color = MainColor
UIStrokeL.Thickness = 2

local TitleLbl = Instance.new("TextLabel", LoaderFrame)
TitleLbl.Size = UDim2.new(1, 0, 0, 50)
TitleLbl.Position = UDim2.new(0, 0, 0, 18)
TitleLbl.Text = "DragonHUB V3"
TitleLbl.TextColor3 = MainColor
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 36
TitleLbl.BackgroundTransparency = 1

local SubLbl = Instance.new("TextLabel", LoaderFrame)
SubLbl.Size = UDim2.new(1, 0, 0, 20)
SubLbl.Position = UDim2.new(0, 0, 0, 58)
SubLbl.Text = "Versão Automática Completa"
SubLbl.TextColor3 = GrayText
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextSize = 13
SubLbl.BackgroundTransparency = 1

local SeaLbl = Instance.new("TextLabel", LoaderFrame)
SeaLbl.Size = UDim2.new(1, 0, 0, 16)
SeaLbl.Position = UDim2.new(0, 0, 0, 78)
SeaLbl.Text = "Detectado: " .. SeaName
SeaLbl.TextColor3 = Color3.fromRGB(0, 200, 255)
SeaLbl.Font = Enum.Font.Code
SeaLbl.TextSize = 12
SeaLbl.BackgroundTransparency = 1

local BarBg = Instance.new("Frame", LoaderFrame)
BarBg.Size = UDim2.new(0, 300, 0, 4)
BarBg.Position = UDim2.new(0.5, -150, 0, 148)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = MainColor
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local ActionText = Instance.new("TextLabel", LoaderFrame)
ActionText.Size = UDim2.new(1, 0, 0, 20)
ActionText.Position = UDim2.new(0, 0, 0, 162)
ActionText.Text = "Iniciando sistema..."
ActionText.TextColor3 = Color3.fromRGB(100, 100, 100)
ActionText.Font = Enum.Font.Code
ActionText.TextSize = 12
ActionText.BackgroundTransparency = 1

local VerLbl = Instance.new("TextLabel", LoaderFrame)
VerLbl.Size = UDim2.new(1, 0, 0, 14)
VerLbl.Position = UDim2.new(0, 0, 0, 196)
VerLbl.Text = "v3.0 | Sem V4 | Prioridade ativa"
VerLbl.TextColor3 = Color3.fromRGB(60, 60, 60)
VerLbl.Font = Enum.Font.Code
VerLbl.TextSize = 11
VerLbl.BackgroundTransparency = 1

-- ── STATUS BAR ──────────────────────────────────────────────────────────────

local TrackerFrame = Instance.new("Frame", ScreenGui)
TrackerFrame.Name = "Tracker"
TrackerFrame.Size = UDim2.new(0, 380, 0, 28)
TrackerFrame.Position = UDim2.new(0.5, -190, 0, 12)
TrackerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TrackerFrame.BackgroundTransparency = 0.3
TrackerFrame.BorderSizePixel = 1
TrackerFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
TrackerFrame.Visible = false
Instance.new("UICorner", TrackerFrame).CornerRadius = UDim.new(0, 5)

local StatusLabel = Instance.new("TextLabel", TrackerFrame)
StatusLabel.Size = UDim2.new(1, -20, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Aguardando START..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Função global de status
_G.UpdateStatus = function(msg, color)
    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = "● " .. tostring(msg)
        StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        task.spawn(function()
            StatusLabel.TextTransparency = 0.5
            task.wait(0.05)
            StatusLabel.TextTransparency = 0
        end)
    end
end

-- ── INFO PANEL ──────────────────────────────────────────────────────────────

local InfoFrame = Instance.new("Frame", ScreenGui)
InfoFrame.Name = "InfoPanel"
InfoFrame.Size = UDim2.new(0, 200, 0, 80)
InfoFrame.Position = UDim2.new(0.5, -100, 0, 48)
InfoFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
InfoFrame.BackgroundTransparency = 0.4
InfoFrame.BorderSizePixel = 1
InfoFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
InfoFrame.Visible = false
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 5)

local InfoList = Instance.new("UIListLayout", InfoFrame)
InfoList.FillDirection = Enum.FillDirection.Vertical
InfoList.Padding = UDim.new(0, 1)

local function MakeInfoLine(parent, text, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -10, 0, 17)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "  " .. text
    return lbl
end

local LvLine    = MakeInfoLine(InfoFrame, "Level: ...", Color3.fromRGB(0, 200, 255))
local MonLine   = MakeInfoLine(InfoFrame, "Mob: ...", Color3.fromRGB(255, 200, 0))
local PrioLine  = MakeInfoLine(InfoFrame, "Prioridade: Nenhuma", Color3.fromRGB(180, 180, 180))
local SeaLine2  = MakeInfoLine(InfoFrame, "Mar: " .. SeaName, Color3.fromRGB(100, 255, 100))

-- Atualizar info panel
task.spawn(function()
    while task.wait(2) do
        if _G.FecharTudo then break end
        if not InfoFrame.Visible then continue end
        pcall(function()
            local lv = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 0
            LvLine.Text = "  Level: " .. lv
            MonLine.Text = "  Mob: " .. tostring(Mon or "---")
            if _G.PrioridadeAtiva and _G.AlvoPrioridade then
                PrioLine.Text = "  ⚡ PRIO: " .. tostring(_G.AlvoPrioridade.Name)
                PrioLine.TextColor3 = Color3.fromRGB(255, 100, 0)
            else
                PrioLine.Text = "  Prioridade: Nenhuma"
                PrioLine.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end)
    end
end)

-- ── PAINEL DE CONTROLES ─────────────────────────────────────────────────────

local ControlFrame = Instance.new("Frame", ScreenGui)
ControlFrame.Size = UDim2.new(0, 260, 0, 32)
ControlFrame.Position = UDim2.new(0.5, -130, 0, 136)
ControlFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ControlFrame.BackgroundTransparency = 0.15
ControlFrame.Visible = false
ControlFrame.Active = true
Instance.new("UICorner", ControlFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ControlFrame).Color = Color3.fromRGB(50, 50, 50)

local BtnLayout = Instance.new("UIListLayout", ControlFrame)
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
BtnLayout.Padding = UDim.new(0, 6)

local function CriarBotao(nome, cor, w, callback)
    local btn = Instance.new("TextButton", ControlFrame)
    btn.Size = UDim2.new(0, w or 55, 0, 22)
    btn.BackgroundColor3 = cor
    btn.Text = nome
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local StartBtn = CriarBotao("▶ START", Color3.fromRGB(35, 145, 35), 75, function()
    if not _G.ScriptRodando then
        _G.ScriptRodando = true
        _G.AutoFarm = true
        _G.Config.FastAttack = true
        _G.Config.BringMonster = true
        StartBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
        _G.UpdateStatus("Farm ATIVO!", Color3.fromRGB(100, 255, 100))
    end
end)

local StopBtn = CriarBotao("■ STOP", Color3.fromRGB(145, 35, 35), 70, function()
    _G.ScriptRodando = false
    _G.AutoFarm = false
    _G.PrioridadeAtiva = false
    StartMagnet = false
    MakoriGayMag = false
    StartBtn.BackgroundColor3 = Color3.fromRGB(35, 145, 35)
    _G.UpdateStatus("Farm pausado", Color3.fromRGB(255, 80, 80))
end)

local HopBtn = CriarBotao("↗ HOP", Color3.fromRGB(50, 100, 180), 60, function()
    _G.AutoFarm = false
    _G.ScriptRodando = false
    task.spawn(Hop)
end)

local InfoBtn = CriarBotao("ℹ", Color3.fromRGB(60, 60, 60), 28, function()
    InfoFrame.Visible = not InfoFrame.Visible
end)

local CloseBtn = CriarBotao("✕", Color3.fromRGB(80, 30, 30), 28, function()
    _G.ScriptRodando = false
    _G.AutoFarm = false
    _G.FecharTudo = true
    ScreenGui:Destroy()
end)

-- Arrastar o painel de controle
do
    local dragging = false
    local dragStart, startPos
    ControlFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = ControlFrame.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            ControlFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Monitor em tempo real no status
task.spawn(function()
    while task.wait(3) do
        if _G.FecharTudo then break end
        if not TrackerFrame.Visible then continue end
        if not _G.ScriptRodando then continue end
        pcall(function()
            local lv = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 0
            local mobAtual = tostring(Mon or "Detectando...")
            if _G.PrioridadeAtiva and _G.AlvoPrioridade then
                _G.UpdateStatus("⚡ PRIO: "..tostring(_G.AlvoPrioridade.Name).." | Lv "..lv, Color3.fromRGB(255,100,0))
            else
                _G.UpdateStatus(string.format("[%s] Lv %d | %s", SeaName, lv, mobAtual), Color3.fromRGB(200,200,200))
            end
        end)
    end
end)

-- ── ANIMAÇÃO DO LOADER ──────────────────────────────────────────────────────

task.spawn(function()
    local etapas = {
        {0.15, "Carregando proteção anti-detecção..."},
        {0.30, "Inicializando Fast Attack (Caclo)..."},
        {0.45, "Carregando mapas de quests (3 mares)..."},
        {0.60, "Sistema de prioridade de bosses..."},
        {0.75, "Carregando ESP completo..."},
        {0.88, "Sistemas de raid/dungeon..."},
        {1.00, "DragonHUB V3 Pronto!"},
    }

    for _, etapa in ipairs(etapas) do
        TweenService:Create(
            BarFill,
            TweenInfo.new(0.9, Enum.EasingStyle.Quart),
            {Size = UDim2.new(etapa[1], 0, 1, 0)}
        ):Play()
        ActionText.Text = etapa[2]
        task.wait(1.1)
    end

    task.wait(0.3)
    TweenService:Create(LoaderFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {BackgroundTransparency=1}):Play()
    task.wait(0.4)
    LoaderFrame:Destroy()

    TrackerFrame.Visible = true
    ControlFrame.Visible = true
    _G.UpdateStatus("Pronto! Clique START para iniciar.", Color3.fromRGB(180,180,180))
end)

print("[DragonHUB V3] Interface carregada!")

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM NEAREST (farm qualquer mob perto)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.AutoFarmNearest and not _G.PrioridadeAtiva then
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if v.Humanoid.Health > 0 then
                        repeat task.wait()
                            EquipWeapon(_G.Config.SelectWeapon)
                            AutoHaki()
                            topos(v.HumanoidRootPart.CFrame * Pos)
                            v.HumanoidRootPart.CanCollide = false
                            Fastattack = true
                            v.HumanoidRootPart.Size = Vector3.new(60,60,60)
                            AutoFarmNearestMagnet = true
                            PosMon = v.HumanoidRootPart.CFrame
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(1280,672))
                        until not _G.AutoFarmNearest or not v.Parent or v.Humanoid.Health <= 0 or _G.PrioridadeAtiva
                        AutoFarmNearestMagnet = false
                        Fastattack = false
                    end
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM MOB SELECIONADO
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.AutoFarmMob and not _G.PrioridadeAtiva then
            pcall(function()
                if Workspace.Enemies:FindFirstChild(_G.SelectMob) then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == _G.SelectMob and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                AutoHaki()
                                EquipWeapon(_G.Config.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                SelectMag = true
                                PosMon = v.HumanoidRootPart.CFrame
                                v.HumanoidRootPart.Size = Vector3.new(80,80,80)
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280,672))
                            until not _G.AutoFarmMob or not v.Parent or v.Humanoid.Health <= 0 or _G.PrioridadeAtiva
                            SelectMag = false
                        end
                    end
                else
                    SelectMag = false
                    local mRS = ReplicatedStorage:FindFirstChild(_G.SelectMob or "")
                    if mRS and mRS:FindFirstChild("HumanoidRootPart") then
                        topos(mRS.HumanoidRootPart.CFrame * CFrame.new(5,10,2))
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM BOSS SELECIONADO
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.AutoFarmBoss and not _G.PrioridadeAtiva then
            pcall(function()
                if Workspace.Enemies:FindFirstChild(_G.SelectBoss) then
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == _G.SelectBoss and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                AutoHaki()
                                EquipWeapon(_G.Config.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(80,80,80)
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280,672))
                                pcall(function() sethiddenproperty(LocalPlayer,"SimulationRadius",math.huge) end)
                            until not _G.AutoFarmBoss or not v.Parent or v.Humanoid.Health <= 0 or _G.PrioridadeAtiva
                        end
                    end
                else
                    local bRS = ReplicatedStorage:FindFirstChild(_G.SelectBoss or "")
                    if bRS and bRS:FindFirstChild("HumanoidRootPart") then
                        local dist = (bRS.HumanoidRootPart.CFrame.Position - GetHRP().Position).Magnitude
                        if dist <= 1500 then
                            topos(bRS.HumanoidRootPart.CFrame)
                        else
                            BTP(bRS.HumanoidRootPart.CFrame)
                        end
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FARM TODOS OS BOSSES
-- ════════════════════════════════════════════════════════════════════════════

local AllBossNames = {
    "The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral",
    "Warden","Chief Warden","Swan","Saber Expert","Magma Admiral","Fishman Lord",
    "Wysper","Thunder God","Cyborg","Greybeard","Diamond","Jeremy","Fajita",
    "Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Order",
    "Darkbeard","Cursed Captain","Stone","Island Empress","Kilo Admiral",
    "Captain Elephant","Beautiful Pirate","Longma","Cake Queen","Soul Reaper",
    "Cake Prince","Dough King","rip_indra True Form"
}

spawn(function()
    while task.wait() do
        if _G.AutoAllBoss and not _G.PrioridadeAtiva then
            pcall(function()
                for _, bossName in ipairs(AllBossNames) do
                    local b = ReplicatedStorage:FindFirstChild(bossName)
                    if b and b:FindFirstChild("HumanoidRootPart") then
                        local dist = (b.HumanoidRootPart.Position - GetHRP().Position).Magnitude
                        if dist < 17000 then
                            repeat task.wait()
                                AutoHaki()
                                EquipWeapon(_G.Config.SelectWeapon)
                                if b:FindFirstChild("Humanoid") then
                                    b.Humanoid.WalkSpeed = 0
                                end
                                b.HumanoidRootPart.CanCollide = false
                                b.HumanoidRootPart.Size = Vector3.new(80,80,80)
                                topos(b.HumanoidRootPart.CFrame * Pos)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280,672))
                                pcall(function() sethiddenproperty(LocalPlayer,"SimulationRadius",math.huge) end)
                            until not _G.AutoAllBoss or not b.Parent
                                or (b:FindFirstChild("Humanoid") and b.Humanoid.Health <= 0)
                        end
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO OBSERVATION HAKI
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoObservation then
                local visionLevel = LocalPlayer.VisionRadius.Value
                if visionLevel >= 3000 then
                    if _G.UpdateStatus then
                        _G.UpdateStatus("Observation Haki no máximo!", Color3.fromRGB(0,255,100))
                    end
                else
                    repeat task.wait()
                        if not LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel") then
                            VirtualUser:CaptureController()
                            VirtualUser:SetKeyDown("0x65")
                            task.wait(2)
                            VirtualUser:SetKeyUp("0x65")
                        end
                    until LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel") or not _G.AutoObservation

                    -- Perseguir mob
                    local targetMob = nil
                    if World2 then targetMob = "Lava Pirate"
                    elseif World1 then targetMob = "Galley Captain"
                    elseif World3 then targetMob = "Giant Islander" end

                    if targetMob and Workspace.Enemies:FindFirstChild(targetMob) then
                        local v = Workspace.Enemies:FindFirstChild(targetMob)
                        if LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel") then
                            repeat task.wait()
                                GetHRP().CFrame = v.HumanoidRootPart.CFrame * CFrame.new(3,0,0)
                            until not _G.AutoObservation or not LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel")
                        else
                            repeat task.wait()
                                GetHRP().CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,50,0)
                                task.wait(1)
                            until _G.AutoObservation == false or LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel")
                        end
                    else
                        -- Teleportar para posição de spawn do mob
                        if World2 then topos(CFrame.new(-5478.39209,15.9775667,-5246.9126))
                        elseif World1 then topos(CFrame.new(5533.29785,88.1079102,4852.3916))
                        elseif World3 then topos(CFrame.new(4530.3540039063,656.75695800781,-131.60952758789)) end
                    end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO ANCIENT ONE QUEST / AUTO RACE (Sea 3 - sem V4)
-- ════════════════════════════════════════════════════════════════════════════

local StardFarm = false
local StardFarmFarmMag = false

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoRace and not _G.PrioridadeAtiva then
                -- Verificar se está transformado
                if GetChar() and GetChar():FindFirstChild("RaceTransformed") and GetChar().RaceTransformed.Value == true then
                    StardFarm = false
                    topos(CFrame.new(216.211181640625, 126.9352035522461, -12599.0732421875))
                end
                -- Apertar Y para transformar
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "Y", false, game)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "Y", false, game)
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoRace and not _G.PrioridadeAtiva then
                if GetChar() and GetChar():FindFirstChild("RaceTransformed") and GetChar().RaceTransformed.Value == false then
                    StardFarm = true
                end
            end
        end
    end)
end)

spawn(function()
    while task.wait() do
        if StardFarm and World3 and not _G.PrioridadeAtiva then
            pcall(function()
                local farmMobs = {"Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel"}
                local found = false
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    for _, fn in ipairs(farmMobs) do
                        if v.Name == fn and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            found = true
                            repeat task.wait()
                                AutoHaki()
                                EquipWeapon(_G.Config.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.Head.CanCollide = false
                                FarmMag = true
                                PosGG = v.HumanoidRootPart.CFrame
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280,672))
                            until not StardFarm or not v.Parent or v.Humanoid.Health <= 0 or _G.PrioridadeAtiva
                            FarmMag = false
                            break
                        end
                    end
                    if found then break end
                end
                if not found then
                    FarmMag = false
                    topos(CFrame.new(216.211181640625,126.9352035522461,-12599.0732421875))
                    for _, fn in ipairs(farmMobs) do
                        local mRS = ReplicatedStorage:FindFirstChild(fn)
                        if mRS and mRS:FindFirstChild("HumanoidRootPart") then
                            topos(mRS.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO KILL PLAYER QUEST (PVP Hunter)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    RunService.Heartbeat:connect(function()
        pcall(function()
            if _G.AutoPlayerHunter then
                if GetHumanoid() then
                    GetHumanoid():ChangeState(11)
                end
            end
        end)
    end)
end)

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.AutoPlayerHunter then
                if LocalPlayer.PlayerGui.Main.PvpDisabled.Visible then
                    CommF_:InvokeServer("EnablePvp")
                end
            end
        end
    end)
end)

local UseskillPly = false
spawn(function()
    while task.wait() do
        if _G.AutoPlayerHunter then
            if not LocalPlayer.PlayerGui.Main.Quest.Visible then
                task.wait(0.5)
                CommF_:InvokeServer("PlayerHunter")
            else
                for _, v in pairs(Workspace.Characters:GetChildren()) do
                    if string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, v.Name) then
                        repeat task.wait()
                            AutoHaki()
                            EquipWeapon(_G.Config.SelectWeapon)
                            UseskillPly = true
                            topos(v.HumanoidRootPart.CFrame * CFrame.new(1,7,3))
                            v.HumanoidRootPart.Size = Vector3.new(60,60,60)
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(1280,672))
                        until not _G.AutoPlayerHunter or (v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0)
                        UseskillPly = false
                        CommF_:InvokeServer("AbandonQuest")
                    end
                end
            end
        end
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            if UseskillPly then
                game:GetService("VirtualInputManager"):SendKeyEvent(true,"Z",false,game); task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false,"Z",false,game); task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(true,"X",false,game); task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false,"X",false,game); task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(true,"C",false,game); task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false,"C",false,game); task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(true,"V",false,game); task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false,"V",false,game)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO FRUTAS (sniper, eat, drop, store)
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.AutoBuyFruitSniper and _G.SelectFruit and _G.SelectFruit ~= "" then
                CommF_:InvokeServer("GetFruits")
                CommF_:InvokeServer("PurchaseRawFruit", _G.SelectFruit, false)
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.AutoEatFruit and _G.SelectFruitEat and _G.SelectFruitEat ~= "" then
                local f = GetChar() and GetChar():FindFirstChild(_G.SelectFruitEat)
                if f and f:FindFirstChild("EatRemote") then
                    f.EatRemote:InvokeServer()
                end
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if _G.Random_Auto then
                CommF_:InvokeServer("Cousin", "Buy")
            end
        end
    end)
end)

-- Notificação de fruta no chão
spawn(function()
    while task.wait(0.1) do
        if _G.FruitCheck then
            for _, v in pairs(Workspace:GetChildren()) do
                if string.find(v.Name,"Fruit") then
                    pcall(function()
                        require(ReplicatedStorage.Notification).new("🍎 Fruta Spawnou: "..v.Name):Display()
                    end)
                end
            end
        end
    end
end)

-- Ir até fruta automaticamente
spawn(function()
    while task.wait(0.1) do
        if _G.Grabfruit then
            for _, v in pairs(Workspace:GetChildren()) do
                if string.find(v.Name,"Fruit") and v:FindFirstChild("Handle") then
                    GetHRP().CFrame = v.Handle.CFrame
                end
            end
        end
    end
end)

-- Store frutas automaticamente
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.AutoStoreSsFruit then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA("Tool") and string.find(v.Name,"Fruit") then
                        CommF_:InvokeServer("StoreFruit", v:GetAttribute("OriginalName"), v)
                    end
                end
                for _, v in pairs(GetChar():GetChildren()) do
                    if v:IsA("Tool") and string.find(v.Name,"Fruit") then
                        CommF_:InvokeServer("StoreFruit", v:GetAttribute("OriginalName"), v)
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO STATS (AddPoint correto)
-- ════════════════════════════════════════════════════════════════════════════

-- Flags individuais
local _melee, _defense, _sword, _gun, _demonfruit = false,false,false,false,false

spawn(function()
    while task.wait() do
        if LocalPlayer.Data.Points.Value >= PointStats then
            if _melee then CommF_:InvokeServer("AddPoint","Melee",PointStats) end
            if _defense then CommF_:InvokeServer("AddPoint","Defense",PointStats) end
            if _sword then CommF_:InvokeServer("AddPoint","Sword",PointStats) end
            if _gun then CommF_:InvokeServer("AddPoint","Gun",PointStats) end
            if _demonfruit then CommF_:InvokeServer("AddPoint","Demon Fruit",PointStats) end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  REMOVE NOTIFICATION DE SKILL LOCKED (durante mastery)
-- ════════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    pcall(function()
        if UseSkill or UseSkillKub then
            for _, v in pairs(LocalPlayer.PlayerGui.Notifications:GetChildren()) do
                if v.Name == "NotificationTemplate" then
                    if string.find(tostring(v.Text), "Skill locked!") then
                        v:Destroy()
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO REJOIN / ANTI-CRASH
-- ════════════════════════════════════════════════════════════════════════════

spawn(function()
    while task.wait() do
        if _G.AutoRejoin then
            pcall(function()
                CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                    if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
                        TeleportService:Teleport(game.PlaceId)
                    end
                end)
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MENSAGEM FINAL NO CONSOLE
-- ════════════════════════════════════════════════════════════════════════════

print("═══════════════════════════════════════════════════════════")
print("[DragonHUB V3] SISTEMA COMPLETO CARREGADO! (" .. SeaName .. ")")
print("[DragonHUB V3] Funcionalidades ativas:")
print("  ✔ Auto Farm Level com quest (Sea 1, 2 e 3 completo)")
print("  ✔ Sistema de PRIORIDADE (interrompe farm p/ boss/spawn raro)")
print("  ✔ Fast Attack (Caclo + RemoteAttack - método do original)")
print("  ✔ Auto Farm Mastery (Fruit, Sword, Gun)")
print("  ✔ Auto Stats (Melee/Defense/Sword/Gun/Fruit)")
print("  ✔ Auto Segunda Mar (Lv 700+)")
print("  ✔ Auto Terceira Mar (Lv 1500+)")
print("  ✔ Auto Superhuman → Godhuman evolution completa")
print("  ✔ Auto Farm Bone / Auto Pray / Auto Try Luck (Sea 3)")
print("  ✔ Auto Farm Cake Prince / Dough King (Sea 3)")
print("  ✔ Auto Ectoplasm (Sea 2 - Barco Fantasma)")
print("  ✔ Auto Rengoku (Sea 2)")
print("  ✔ Auto Elite Hunter (Sea 3)")
print("  ✔ Auto Musketeer Hat / Obs V2 (Sea 3)")
print("  ✔ Auto Rainbow Haki (Sea 3)")
print("  ✔ Auto Evo Race V2 (Sea 2)")
print("  ✔ Auto Bartilo Quest (Sea 2)")
print("  ✔ Auto Farm Materiais (16 tipos, todos os mares)")
print("  ✔ Bosses: Greybeard, Don Swan, Rip_Indra, Longma, Cavender, etc.")
print("  ✔ Auto Dungeon / Raid (Sea 2 e Sea 3 - chips corretos)")
print("  ✔ Auto Law Raid (Sea 2)")
print("  ✔ Auto Farm Sharks / Piranha / Fish Crew (Sea 3)")
print("  ✔ Auto Ghost Ship / Kill Raid Ship")
print("  ✔ Auto Sea Beast")
print("  ✔ Auto Mirage Island / Auto Gear Azul")
print("  ✔ Auto Frozen Dimension / Kitsune Island")
print("  ✔ Auto Ancient One Quest / Auto Race (Sea 3)")
print("  ✔ Auto Player Hunter (PVP)")
print("  ✔ ESP: Player, Chest, Fruit, Mob, Island, SeaBeast, Mirage")
print("  ✔ Bring Mobs (completo - 15+ casos)")
print("  ✔ Walk Water, Anti-AFK, Infinite Energy")
print("  ✔ Remove Camera Shake, Damage Counter, Death Effect")
print("  ✔ Auto Redeem Codes, Auto Buy Haki Abilities")
print("  ✔ Auto Frutas: Sniper, Eat, Store, Random, Grab")
print("  ✔ Auto Rejoin / Anti-Crash")
print("  ✗ V4 Race (requer múltiplos jogadores - não incluído)")
print("═══════════════════════════════════════════════════════════")
print("[DragonHUB V3] Clique START na interface para iniciar!")
print("═══════════════════════════════════════════════════════════")
