-- Tux Script 🐧 | Roblox GUI Script
-- Theme: Linux Mascot Tux (Dark Navy, Penguin Yellow, Clean White)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- State Management
local State = {
    NoClip = false,
    ESP = false,
    Fly = false,
    FlySpeed = 50
}

-- Target GUI Parent (CoreGui preferred for executors, fallback PlayerGui)
local guiParent = game:GetService("CoreGui")
pcall(function()
    if not guiParent or not pcall(function() return guiParent.Name end) then
        guiParent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Remove Existing Instance
if guiParent:FindFirstChild("TuxScriptGUI") then
    guiParent.TuxScriptGUI:Destroy()
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TuxScriptGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

---------------------------------------------------------
-- DRAGGABLE MAIN FRAME (Tux Theme)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 46) -- Dark Slate Navy
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(249, 226, 175) -- Tux Yellow Accent
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Title Bar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Tux Script 🐧"
TitleLabel.TextColor3 = Color3.fromRGB(249, 226, 175)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

-- Make Main Frame Draggable
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Container Layout
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TopPadding = Instance.new("UIPadding")
TopPadding.PaddingTop = UDim.new(0, 50)
TopPadding.Parent = MainFrame

---------------------------------------------------------
-- BUTTON CREATOR HELPER
---------------------------------------------------------
local function createToggleButton(name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(0.85, 0, 0, 42)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(166, 227, 161) or Color3.fromRGB(45, 45, 65)
    btn.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    btn.TextColor3 = defaultState and Color3.fromRGB(17, 17, 27) or Color3.fromRGB(205, 214, 244)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(166, 227, 161) or Color3.fromRGB(45, 45, 65)
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(17, 17, 27) or Color3.fromRGB(205, 214, 244)
        callback(state)
    end)
    return btn
end

---------------------------------------------------------
-- FEATURES IMPLEMENTATION
---------------------------------------------------------

-- 1. NoClip
RunService.Stepped:Connect(function()
    if State.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

createToggleButton("NoClip 👻", false, function(enabled)
    State.NoClip = enabled
end)

-- 2. ESP (Highlight)
local espHighlights = {}

local function applyESP(player)
    if player == LocalPlayer then return end
    local function highlightChar(char)
        if not char then return end
        if not espHighlights[player] then
            local hl = Instance.new("Highlight")
            hl.Name = "TuxESP"
            hl.FillColor = Color3.fromRGB(249, 226, 175)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.4
            hl.Enabled = State.ESP
            hl.Parent = char
            espHighlights[player] = hl
        else
            espHighlights[player].Parent = char
            espHighlights[player].Enabled = State.ESP
        end
    end
    if player.Character then highlightChar(player.Character) end
    player.CharacterAdded:Connect(highlightChar)
end

for _, plr in pairs(Players:GetPlayers()) do
    applyESP(plr)
end
Players.PlayerAdded:Connect(applyESP)

createToggleButton("ESP 👁️", false, function(enabled)
    State.ESP = enabled
    for _, hl in pairs(espHighlights) do
        if hl then hl.Enabled = enabled end
    end
end)

-- 3. Fly
local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    if State.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not flyBV or not flyBV.Parent then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Parent = hrp
        end
        if not flyBG or not flyBG.Parent then
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBG.P = 9e4
            flyBG.Parent = hrp
        end

        flyBG.CFrame = Camera.CFrame
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        flyBV.Velocity = moveDir * State.FlySpeed
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end
end)

createToggleButton("Fly 🕊️", false, function(enabled)
    State.Fly = enabled
end)

---------------------------------------------------------
-- 4. PUNCH BUTTON & SUPER KNOCKBACK
---------------------------------------------------------
local PunchScreenGui = Instance.new("ScreenGui")
PunchScreenGui.Name = "TuxPunchGui"
PunchScreenGui.ResetOnSpawn = false
PunchScreenGui.Parent = guiParent

local PunchBtn = Instance.new("TextButton")
PunchBtn.Name = "PunchActionButton"
PunchBtn.Size = UDim2.new(0, 70, 0, 70)
PunchBtn.Position = UDim2.new(0.85, -35, 0.75, -35)
PunchBtn.BackgroundColor3 = Color3.fromRGB(249, 226, 175)
PunchBtn.Text = "PUNCH\n🥊"
PunchBtn.TextColor3 = Color3.fromRGB(17, 17, 27)
PunchBtn.Font = Enum.Font.GothamBold
PunchBtn.TextSize = 13
PunchBtn.Parent = PunchScreenGui

local PunchCorner = Instance.new("UICorner")
PunchCorner.CornerRadius = UDim.new(1, 0)
PunchCorner.Parent = PunchBtn

local PunchStroke = Instance.new("UIStroke")
PunchStroke.Color = Color3.fromRGB(255, 255, 255)
PunchStroke.Thickness = 3
PunchStroke.Parent = PunchBtn

-- Draggable Punch Action Button
local pDragging, pDragInput, pDragStart, pStartPos
PunchBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        pDragging = true
        pDragStart = input.Position
        pStartPos = PunchBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                pDragging = false
            end
        end)
    end
end)

PunchBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        pDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == pDragInput and pDragging then
        local delta = input.Position - pDragStart
        PunchBtn.Position = UDim2.new(pStartPos.X.Scale, pStartPos.X.Offset + delta.X, pStartPos.Y.Scale, pStartPos.Y.Offset + delta.Y)
    end
end)

-- Punch Action Logic
local function performSuperPunch()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    -- Play Punch Animation
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://125750799" -- Roblox Punch Anim
    local track
    pcall(function()
        track = humanoid:LoadAnimation(anim)
        track:Play()
    end)

    -- Super Knockback Nearby Players
    local radius = 15
    local forcePower = 350

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local distance = (targetHrp.Position - hrp.Position).Magnitude
                if distance <= radius then
                    local pushDir = (targetHrp.Position - hrp.Position).Unit
                    if pushDir ~= pushDir then pushDir = hrp.CFrame.LookVector end -- NaN check

                    -- Apply Super Velocity Knockback
                    targetHrp.AssemblyLinearVelocity = (pushDir * forcePower) + Vector3.new(0, forcePower * 0.6, 0)
                end
            end
        end
    end
end

PunchBtn.MouseButton1Click:Connect(performSuperPunch)

print("Tux Script 🐧 loaded successfully!")
