local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local NewIslands = {
    -- Tiki Outpost continuação
    { LevelMin = 2550, LevelMax = 2574, Mon = "Serpent Hunter",       NameQuest = "TikiQuest3",       LevelQuest = 1 },
    { LevelMin = 2575, LevelMax = 2599, Mon = "Skull Slayer",         NameQuest = "TikiQuest3",       LevelQuest = 2 },
    -- Submerged Island
    { LevelMin = 2600, LevelMax = 2624, Mon = "Reef Bandit",          NameQuest = "SubmergedQuest1",  LevelQuest = 1 },
    { LevelMin = 2625, LevelMax = 2649, Mon = "Coral Pirate",         NameQuest = "SubmergedQuest1",  LevelQuest = 2 },
    { LevelMin = 2650, LevelMax = 2674, Mon = "Sea Chanter",          NameQuest = "SubmergedQuest2",  LevelQuest = 1 },
    { LevelMin = 2675, LevelMax = 2699, Mon = "Ocean Prophet",        NameQuest = "SubmergedQuest2",  LevelQuest = 2 },
    { LevelMin = 2700, LevelMax = 2724, Mon = "High Disciple",        NameQuest = "SubmergedQuest3",  LevelQuest = 1 },
    { LevelMin = 2725, LevelMax = 2799, Mon = "Grand Devotee",        NameQuest = "SubmergedQuest3",  LevelQuest = 2 },
    { LevelMin = 2800, LevelMax = 2800, Mon = "???",                  NameQuest = "???",              LevelQuest = 1 },
}

local CapturedCoords = {}
-- Formato de cada entrada:
-- { Mon, NameQuest, LevelQuest, LevelMin, LevelMax,
--   QuestNPC_CFrame, Mon_CFrame, Timestamp }

local DebugUI    = nil
local StatusLabel = nil
local LogLines   = {}

local function Log(msg)
    print("[EZZ-COORD] " .. tostring(msg))
    table.insert(LogLines, 1, msg)
    if #LogLines > 6 then table.remove(LogLines) end
    if StatusLabel then
        StatusLabel.Text = table.concat(LogLines, "\n")
    end
end

-- ═══════════════════════════════════════════════════════════
-- DETECTA QUAL ENTRADA DA LISTA É A ATUAL PELO NÍVEL
-- ═══════════════════════════════════════════════════════════
local function GetCurrentIslandEntry()
    local myLevel = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 0
    for _, entry in pairs(NewIslands) do
        if myLevel >= entry.LevelMin and myLevel <= entry.LevelMax then
            return entry
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════
-- BUSCA QUEST NPC MAIS PRÓXIMO
-- ═══════════════════════════════════════════════════════════
local function FindNearestQuestNPC()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    local best, bestDist = nil, math.huge

    -- Vasculha NPCs no workspace
    local function CheckModel(model)
        if not model:FindFirstChild("HumanoidRootPart") then return end
        -- Quest NPCs geralmente têm BillboardGui ou têm "Quest" no nome pai ou têm ProximityPrompt
        local hasQuest = false
        for _, d in pairs(model:GetDescendants()) do
            if d:IsA("BillboardGui") or d:IsA("ProximityPrompt") or
               (d:IsA("StringValue") and d.Name:lower():find("quest")) then
                hasQuest = true
                break
            end
        end
        -- Também aceita qualquer NPC com diálogo/interação (mais abrangente)
        if not hasQuest then
            for _, d in pairs(model:GetDescendants()) do
                if d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then
                    hasQuest = true
                    break
                end
            end
        end
        if hasQuest then
            local dist = (model.HumanoidRootPart.Position - myPos).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = model
            end
        end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            pcall(CheckModel, obj)
        end
    end

    return best, bestDist
end

-- ═══════════════════════════════════════════════════════════
-- BUSCA MOB PELO NOME
-- ═══════════════════════════════════════════════════════════
local function FindNearestMob(monName)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    local best, bestDist = nil, math.huge

    -- Busca nos containers padrão do Blox Fruits
    local containers = {
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("Mobs"),
        Workspace
    }

    for _, container in pairs(containers) do
        if container then
            for _, obj in pairs(container:GetChildren()) do
                if obj:IsA("Model") then
                    -- Tenta match exato ou parcial no nome
                    local objName = obj.Name:lower()
                    local searchName = monName:lower()
                    if objName == searchName or objName:find(searchName, 1, true) then
                        local hrp = obj:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - myPos).Magnitude
                            if dist < bestDist then
                                bestDist = dist
                                best = obj
                            end
                        end
                    end
                end
            end
        end
    end

    return best, bestDist
end

-- ═══════════════════════════════════════════════════════════
-- FORMATA CFRAME PARA STRING LUAU
-- ═══════════════════════════════════════════════════════════
local function FormatCFrame(cf)
    local p = cf.Position
    return string.format("CFrame.new(%.4f, %.4f, %.4f)", p.X, p.Y, p.Z)
end

-- ═══════════════════════════════════════════════════════════
-- CAPTURA AUTOMÁTICA - ESCANEIA TUDO AO REDOR
-- ═══════════════════════════════════════════════════════════
local function AutoCapture()
    local entry = GetCurrentIslandEntry()
    if not entry then
        Log("⚠️ Nível fora do range 2550-2800")
        Log("Nível atual: " .. tostring(
            LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or "??"
        ))
        return
    end

    Log("🔍 Escaneando para: " .. entry.Mon)
    Log("Quest: " .. entry.NameQuest)

    local result = {
        Mon        = entry.Mon,
        NameQuest  = entry.NameQuest,
        LevelQuest = entry.LevelQuest,
        LevelMin   = entry.LevelMin,
        LevelMax   = entry.LevelMax,
        Timestamp  = os.time(),
    }

    -- Busca Quest NPC
    local npc, npcDist = FindNearestQuestNPC()
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        result.QuestNPC_Name  = npc.Name
        result.QuestNPC_CFrame = npc.HumanoidRootPart.CFrame
        result.QuestNPC_Dist  = math.floor(npcDist)
        Log("✅ NPC: " .. npc.Name .. " (" .. math.floor(npcDist) .. " studs)")
    else
        Log("❌ NPC não encontrado - chegue perto do NPC de quest")
    end

    -- Busca mob
    local mob, mobDist = FindNearestMob(entry.Mon)
    if mob and mob:FindFirstChild("HumanoidRootPart") then
        result.Mon_CFrame = mob.HumanoidRootPart.CFrame
        result.Mon_Dist   = math.floor(mobDist)
        Log("✅ Mob: " .. mob.Name .. " (" .. math.floor(mobDist) .. " studs)")
    else
        -- Tenta busca parcial mais abrangente
        Log("⚠️ Mob '" .. entry.Mon .. "' não achado próximo")
        Log("Tente ficar perto do spawn do mob")
    end

    -- Só salva se tiver pelo menos uma das coords
    if result.QuestNPC_CFrame or result.Mon_CFrame then
        -- Remove duplicata do mesmo Mon se já existir
        for i, c in pairs(CapturedCoords) do
            if c.Mon == result.Mon then
                table.remove(CapturedCoords, i)
                break
            end
        end
        table.insert(CapturedCoords, result)
        Log("💾 Salvo! Total: " .. #CapturedCoords .. " entradas")
    end
end

-- ═══════════════════════════════════════════════════════════
-- CAPTURA MANUAL: POSIÇÃO ATUAL DO PLAYER COMO QUEST NPC
-- ═══════════════════════════════════════════════════════════
local function ManualCaptureQuestPos()
    local entry = GetCurrentIslandEntry()
    if not entry then Log("⚠️ Nível fora do range") return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Pega ou cria entry
    local result
    for _, c in pairs(CapturedCoords) do
        if c.Mon == entry.Mon then result = c break end
    end
    if not result then
        result = { Mon = entry.Mon, NameQuest = entry.NameQuest,
                   LevelQuest = entry.LevelQuest, LevelMin = entry.LevelMin,
                   LevelMax = entry.LevelMax, Timestamp = os.time() }
        table.insert(CapturedCoords, result)
    end

    result.QuestNPC_CFrame = char.HumanoidRootPart.CFrame
    local p = char.HumanoidRootPart.Position
    Log("📍 Quest NPC pos gravada!")
    Log(string.format("X:%.1f Y:%.1f Z:%.1f", p.X, p.Y, p.Z))
end

-- ═══════════════════════════════════════════════════════════
-- CAPTURA MANUAL: POSIÇÃO ATUAL DO PLAYER COMO MOB
-- ═══════════════════════════════════════════════════════════
local function ManualCaptureMonPos()
    local entry = GetCurrentIslandEntry()
    if not entry then Log("⚠️ Nível fora do range") return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local result
    for _, c in pairs(CapturedCoords) do
        if c.Mon == entry.Mon then result = c break end
    end
    if not result then
        result = { Mon = entry.Mon, NameQuest = entry.NameQuest,
                   LevelQuest = entry.LevelQuest, LevelMin = entry.LevelMin,
                   LevelMax = entry.LevelMax, Timestamp = os.time() }
        table.insert(CapturedCoords, result)
    end

    result.Mon_CFrame = char.HumanoidRootPart.CFrame
    local p = char.HumanoidRootPart.Position
    Log("📍 Mob pos gravada!")
    Log(string.format("X:%.1f Y:%.1f Z:%.1f", p.X, p.Y, p.Z))
end

-- ═══════════════════════════════════════════════════════════
-- EXPORTAR - GERA O BLOCO LUAU PRONTO PARA COLAR NO SCRIPT
-- ═══════════════════════════════════════════════════════════
local function ExportCoords()
    if #CapturedCoords == 0 then
        Log("❌ Nenhuma coordenada capturada ainda")
        return
    end

    local lines = {}
    table.insert(lines, "-- ══ COORDENADAS MUNDO 3 - NOVAS ILHAS (EZZ v3.0) ══")
    table.insert(lines, "-- Gerado em: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(lines, "")

    -- Agrupa por Quest
    local quests = {}
    local questOrder = {}
    for _, c in pairs(CapturedCoords) do
        if not quests[c.NameQuest] then
            quests[c.NameQuest] = {}
            table.insert(questOrder, c.NameQuest)
        end
        table.insert(quests[c.NameQuest], c)
    end

    for _, qName in pairs(questOrder) do
        table.insert(lines, "-- ── Quest: " .. qName .. " ──")
        for _, c in pairs(quests[qName]) do
            table.insert(lines, "")
            if c.LevelMax == 2800 then
                table.insert(lines, string.format("-- Nível: %d+ | Monstro: %s", c.LevelMin, c.Mon))
            else
                table.insert(lines, string.format("-- Nível: %d ~ %d | Monstro: %s", c.LevelMin, c.LevelMax, c.Mon))
            end

            -- Bloco elseif no estilo do Nagax
            table.insert(lines, string.format('        elseif MyLevel == %d or MyLevel <= %d then', c.LevelMin, c.LevelMax))
            table.insert(lines, string.format('            Mon = "%s"', c.Mon))
            table.insert(lines, string.format('            LevelQuest = %d', c.LevelQuest))
            table.insert(lines, string.format('            NameQuest = "%s"', c.NameQuest))
            table.insert(lines, string.format('            NameMon = "%s"', c.Mon))

            if c.QuestNPC_CFrame then
                table.insert(lines, string.format('            CFrameQuest = %s', FormatCFrame(c.QuestNPC_CFrame)))
            else
                table.insert(lines, '            CFrameQuest = -- ⚠️ NÃO CAPTURADO')
            end

            if c.Mon_CFrame then
                table.insert(lines, string.format('            CFrameMon   = %s', FormatCFrame(c.Mon_CFrame)))
            else
                table.insert(lines, '            CFrameMon   = -- ⚠️ NÃO CAPTURADO')
            end
        end
        table.insert(lines, "")
    end

    local output = table.concat(lines, "\n")

    print("\n" .. string.rep("=", 70))
    print("EZZ v3.0 - COORDENADAS EXPORTADAS")
    print(string.rep("=", 70))
    print(output)
    print(string.rep("=", 70))
    print("Total: " .. #CapturedCoords .. " monstros capturados")

    if setclipboard then
        setclipboard(output)
        Log("✅ COPIADO para clipboard!")
    else
        Log("📋 Veja o output no console (F9)")
    end

    return output
end

-- ═══════════════════════════════════════════════════════════
-- INTERFACE GRÁFICA
-- ═══════════════════════════════════════════════════════════
local function CreateUI()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end

    if gui:FindFirstChild("EZZ_CoordCapture") then
        gui.EZZ_CoordCapture:Destroy()
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "EZZ_CoordCapture"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 999999
    screen.Parent = gui

    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 340)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screen
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundTransparency = 1
    title.Text = "🌊 EZZ v3.0 - COORD CAPTURE"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.Parent = frame

    -- Info do nível atual
    local levelInfo = Instance.new("TextLabel")
    levelInfo.Name = "LevelInfo"
    levelInfo.Size = UDim2.new(0.95, 0, 0, 20)
    levelInfo.Position = UDim2.new(0.025, 0, 0, 34)
    levelInfo.BackgroundTransparency = 1
    levelInfo.Text = "Nível: ?? | Ilha: ??"
    levelInfo.TextColor3 = Color3.fromRGB(255, 220, 0)
    levelInfo.Font = Enum.Font.GothamBold
    levelInfo.TextSize = 10
    levelInfo.TextXAlignment = Enum.TextXAlignment.Left
    levelInfo.Parent = frame

    -- Log de status
    local logBox = Instance.new("TextLabel")
    logBox.Name = "LogBox"
    logBox.Size = UDim2.new(0.95, 0, 0, 90)
    logBox.Position = UDim2.new(0.025, 0, 0, 56)
    logBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    logBox.BorderSizePixel = 0
    logBox.Text = "Aguardando captura..."
    logBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    logBox.Font = Enum.Font.Code
    logBox.TextSize = 9
    logBox.TextXAlignment = Enum.TextXAlignment.Left
    logBox.TextYAlignment = Enum.TextYAlignment.Top
    logBox.TextWrapped = true
    logBox.Parent = frame
    Instance.new("UICorner", logBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", logBox).PaddingLeft = UDim.new(0, 4)
    StatusLabel = logBox

    -- Botões
    local function MakeBtn(text, color, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.93, 0, 0, 30)
        btn.Position = UDim2.new(0.035, 0, 0, yPos)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        return btn
    end

    -- 🔍 AUTO SCAN
    MakeBtn("🔍 AUTO SCAN (NPC + Mob)", Color3.fromRGB(0, 200, 100), 155, function()
        AutoCapture()
    end)

    -- 📍 Botão Quest NPC manual
    MakeBtn("📍 GRAVAR POSIÇÃO - QUEST NPC", Color3.fromRGB(100, 180, 255), 193, function()
        ManualCaptureQuestPos()
    end)

    -- 📍 Botão Mob manual
    MakeBtn("📍 GRAVAR POSIÇÃO - MOB SPAWN", Color3.fromRGB(255, 180, 80), 231, function()
        ManualCaptureMonPos()
    end)

    -- 📋 Exportar
    MakeBtn("📋 EXPORTAR COORDS (COPIAR)", Color3.fromRGB(0, 255, 180), 269, function()
        ExportCoords()
    end)

    -- 🗑️ Limpar
    MakeBtn("🗑️ LIMPAR TUDO", Color3.fromRGB(255, 80, 80), 307, function()
        CapturedCoords = {}
        LogLines = {}
        Log("🗑️ Dados limpos.")
    end)

    -- Loop info de nível
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                local myLevel = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 0
                local entry = GetCurrentIslandEntry()
                local islandName = entry and entry.Mon or "Fora do range"
                levelInfo.Text = string.format("Nível: %d | Mob esperado: %s", myLevel, islandName)
            end)
        end
    end)

    DebugUI = frame
    Log("✅ EZZ v3.0 pronto! Vá até o NPC/Mob e capture.")
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════
print("[EZZ v3.0] Iniciando capturador de coordenadas...")
CreateUI()
print("[EZZ v3.0] ✅ Pronto! Use a interface para capturar coords das novas ilhas.")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "EZZ v3.0 - Coord Capture",
        Text = "Pronto! Vá até NPC/Mob e use os botões.",
        Duration = 5
    })
end)
