repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Existing = PlayerGui:FindFirstChild("DragonHUBInterfaceTest")
if Existing then
    Existing:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "DragonHUBInterfaceTest"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(430, 280)
Main.BackgroundColor3 = Color3.fromRGB(17, 17, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(125, 75, 255)
MainStroke.Thickness = 2
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(27, 24, 43)
Header.BorderSizePixel = 0
Header.Active = true
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderCover = Instance.new("Frame")
HeaderCover.Position = UDim2.new(0, 0, 1, -12)
HeaderCover.Size = UDim2.new(1, 0, 0, 12)
HeaderCover.BackgroundColor3 = Header.BackgroundColor3
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Position = UDim2.fromOffset(16, 0)
Title.Size = UDim2.new(1, -110, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "DragonHUB"
Title.TextColor3 = Color3.fromRGB(245, 240, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Position = UDim2.new(1, -78, 0, 9)
Minimize.Size = UDim2.fromOffset(28, 28)
Minimize.BackgroundColor3 = Color3.fromRGB(55, 49, 78)
Minimize.BorderSizePixel = 0
Minimize.Text = "−"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 18
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 7)
MinimizeCorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Position = UDim2.new(1, -42, 0, 9)
Close.Size = UDim2.fromOffset(28, 28)
Close.BackgroundColor3 = Color3.fromRGB(190, 50, 70)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = Close

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(20, 70)
Status.Size = UDim2.new(1, -40, 0, 52)
Status.BackgroundColor3 = Color3.fromRGB(31, 29, 46)
Status.BorderSizePixel = 0
Status.Text = "Interface funcionando corretamente"
Status.TextColor3 = Color3.fromRGB(110, 235, 145)
Status.TextSize = 15
Status.Font = Enum.Font.GothamBold
Status.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = Status

local TestButton = Instance.new("TextButton")
TestButton.Position = UDim2.fromOffset(20, 140)
TestButton.Size = UDim2.new(1, -40, 0, 44)
TestButton.BackgroundColor3 = Color3.fromRGB(108, 79, 255)
TestButton.BorderSizePixel = 0
TestButton.Text = "Testar botão"
TestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TestButton.TextSize = 14
TestButton.Font = Enum.Font.GothamBold
TestButton.Parent = Main

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = TestButton

local Info = Instance.new("TextLabel")
Info.Position = UDim2.fromOffset(20, 200)
Info.Size = UDim2.new(1, -40, 0, 48)
Info.BackgroundTransparency = 1
Info.Text = "Arraste pelo cabeçalho • RightShift mostra ou esconde"
Info.TextColor3 = Color3.fromRGB(155, 150, 180)
Info.TextSize = 12
Info.Font = Enum.Font.Gotham
Info.TextWrapped = true
Info.Parent = Main

local Minimized = false
local Dragging = false
local DragStart
local StartPosition

TestButton.MouseButton1Click:Connect(function()
    Status.Text = "Botão funcionando: " .. os.date("%H:%M:%S")
    Status.TextColor3 = Color3.fromRGB(255, 220, 110)
end)

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Main.Size = Minimized and UDim2.fromOffset(430, 48) or UDim2.fromOffset(430, 280)
    Minimize.Text = Minimized and "+" or "−"
end)

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = Input.Position - DragStart
        Main.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
    if not Processed and Input.KeyCode == Enum.KeyCode.RightShift then
        Gui.Enabled = not Gui.Enabled
    end
end)
