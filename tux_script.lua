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
    FlySpeed = 60,
    PunchEnabled = false,
    PunchMode = "Combined" -- Options: "Impulser", "Spin", "Direct", "Combined"
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
MainFrame.Size = UDim2.new(0, 280, 0, 380)
MainFrame.Position = UDim2.new(0.5, -140, 0.35, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 46) -- Dark Slate Navy
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
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

-- Scroll Container Layout
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "Container"
ScrollFrame.Size = UDim2.new(1, -20, 1, -55)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(249, 226, 175)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

---------------------------------------------------------
-- BUTTON CREATOR HELPER
---------------------------------------------------------
local function createToggleButton(name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(0.95, 0, 0, 42)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(166, 227, 161) or Color3.fromRGB(45, 45, 65)
    btn.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    btn.TextColor3 = defaultState and Color3.fromRGB(17, 17, 27) or Color3.fromRGB(205, 214, 244)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = ScrollFrame

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

-- 3. UPRIGHT CFrame Fly
local flyConn
createToggleButton("Fly 🕊️", false, function(enabled)
    State.Fly = enabled
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if enabled then
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.RenderStepped:Connect(function(dt)
            if not State.Fly or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if flyConn then flyConn:Disconnect() end
                return
            end

            local curChar = LocalPlayer.Character
            local curHrp = curChar:FindFirstChild("HumanoidRootPart")
            local curHum = curChar:FindFirstChildOfClass("Humanoid")

            if curHum then
                curHum.PlatformStand = false
            end

            if curHrp then
                curHrp.AssemblyLinearVelocity = Vector3.zero
                curHrp.AssemblyAngularVelocity = Vector3.zero

                local moveDir = Vector3.zero
                local camCF = Camera.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                -- Mobile Joystick Support
                if curHum and curHum.MoveDirection.Magnitude > 0 and moveDir == Vector3.zero then
                    moveDir = (camCF:VectorToWorldSpace(curHum.MoveDirection)).Unit
                end

                if moveDir.Magnitude > 0 then
                    local yawCFrame = CFrame.Angles(0, math.atan2(-camCF.LookVector.X, -camCF.LookVector.Z), 0)
                    local nextPos = curHrp.Position + (moveDir.Unit * State.FlySpeed * dt)
                    curHrp.CFrame = CFrame.new(nextPos) * yawCFrame
                end
            end
        end)
    else
        if flyConn then flyConn:Disconnect() end
    end
end)

---------------------------------------------------------
-- 4. PUNCH BUTTON WITH MODE DROPDOWN & FLOATING TOGGLE
---------------------------------------------------------
local PunchScreenGui = Instance.new("ScreenGui")
PunchScreenGui.Name = "TuxPunchGui"
PunchScreenGui.ResetOnSpawn = false
PunchScreenGui.Enabled = false -- Hidden by default until activated in menu
PunchScreenGui.Parent = guiParent

local PunchBtn = Instance.new("TextButton")
PunchBtn.Name = "PunchActionButton"
PunchBtn.Size = UDim2.new(0, 75, 0, 75)
PunchBtn.Position = UDim2.new(0.85, -37, 0.75, -37)
PunchBtn.BackgroundColor3 = Color3.fromRGB(249, 226, 175)
PunchBtn.Text = "PUNCH\n🥊"
PunchBtn.TextColor3 = Color3.fromRGB(17, 17, 27)
PunchBtn.Font = Enum.Font.GothamBold
PunchBtn.TextSize = 14
PunchBtn.Parent = PunchScreenGui

local PunchCorner = Instance.new("UICorner")
PunchCorner.CornerRadius = UDim.new(1, 0)
PunchCorner.Parent = PunchBtn

local PunchStroke = Instance.new("UIStroke")
PunchStroke.Color = Color3.fromRGB(255, 255, 255)
PunchStroke.Thickness = 3
PunchStroke.Parent = PunchBtn

-- Draggable Floating Punch Action Button
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

-- Create Combined Punch Container in Menu (Toggle Button + Arrow Settings Dropdown)
local PunchMenuFrame = Instance.new("Frame")
PunchMenuFrame.Name = "PunchMenuFrame"
PunchMenuFrame.Size = UDim2.new(0.95, 0, 0, 42)
PunchMenuFrame.BackgroundTransparency = 1
PunchMenuFrame.Parent = ScrollFrame

local MainPunchToggle = Instance.new("TextButton")
MainPunchToggle.Name = "MainPunchToggle"
MainPunchToggle.Size = UDim2.new(0.78, 0, 0, 42)
MainPunchToggle.Position = UDim2.new(0, 0, 0, 0)
MainPunchToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
MainPunchToggle.Text = "Punch Button 🥊: OFF"
MainPunchToggle.TextColor3 = Color3.fromRGB(205, 214, 244)
MainPunchToggle.Font = Enum.Font.GothamMedium
MainPunchToggle.TextSize = 13
MainPunchToggle.Parent = PunchMenuFrame

local MainPunchCorner = Instance.new("UICorner")
MainPunchCorner.CornerRadius = UDim.new(0, 8)
MainPunchCorner.Parent = MainPunchToggle

local SettingsArrowBtn = Instance.new("TextButton")
SettingsArrowBtn.Name = "SettingsArrowBtn"
SettingsArrowBtn.Size = UDim2.new(0.18, 0, 0, 42)
SettingsArrowBtn.Position = UDim2.new(0.82, 0, 0, 0)
SettingsArrowBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 85)
SettingsArrowBtn.Text = "▶"
SettingsArrowBtn.TextColor3 = Color3.fromRGB(249, 226, 175)
SettingsArrowBtn.Font = Enum.Font.GothamBold
SettingsArrowBtn.TextSize = 14
SettingsArrowBtn.Parent = PunchMenuFrame

local ArrowCorner = Instance.new("UICorner")
ArrowCorner.CornerRadius = UDim.new(0, 8)
ArrowCorner.Parent = SettingsArrowBtn

-- Punch Settings Sub-panel
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Name = "SettingsPanel"
SettingsPanel.Size = UDim2.new(0.95, 0, 0, 0)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(24, 24, 37)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.ClipsDescendants = true
SettingsPanel.Parent = ScrollFrame

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 8)
SettingsCorner.Parent = SettingsPanel

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Parent = SettingsPanel
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Padding = UDim.new(0, 5)
SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SettingsPadding = Instance.new("UIPadding")
SettingsPadding.PaddingTop = UDim.new(0, 8)
SettingsPadding.PaddingBottom = UDim.new(0, 8)
SettingsPadding.Parent = SettingsPanel

-- Mode Buttons in Settings Panel
local modesList = {
    {id = "Combined", label = "Mode: 3-in-1 Combined 🔥"},
    {id = "Impulser", label = "Mode 1: Block Impulse 📦"},
    {id = "Spin", label = "Mode 2: Ghost Proxy Spin 🌀"},
    {id = "Direct", label = "Mode 3: Touch Impulse Surge ⚡"}
}

local modeButtons = {}
for _, modeData in ipairs(modesList) do
    local mBtn = Instance.new("TextButton")
    mBtn.Name = "Mode_" .. modeData.id
    mBtn.Size = UDim2.new(0.9, 0, 0, 32)
    mBtn.BackgroundColor3 = (State.PunchMode == modeData.id) and Color3.fromRGB(249, 226, 175) or Color3.fromRGB(45, 45, 65)
    mBtn.Text = modeData.label
    mBtn.TextColor3 = (State.PunchMode == modeData.id) and Color3.fromRGB(17, 17, 27) or Color3.fromRGB(205, 214, 244)
    mBtn.Font = Enum.Font.GothamMedium
    mBtn.TextSize = 12
    mBtn.Parent = SettingsPanel

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 6)
    mCorner.Parent = mBtn

    mBtn.MouseButton1Click:Connect(function()
        State.PunchMode = modeData.id
        for id, b in pairs(modeButtons) do
            local isSel = (id == modeData.id)
            b.BackgroundColor3 = isSel and Color3.fromRGB(249, 226, 175) or Color3.fromRGB(45, 45, 65)
            b.TextColor3 = isSel and Color3.fromRGB(17, 17, 27) or Color3.fromRGB(205, 214, 244)
        end
    end)
    modeButtons[modeData.id] = mBtn
end

-- Toggle Punch Button Visibility
MainPunchToggle.MouseButton1Click:Connect(function()
    State.PunchEnabled = not State.PunchEnabled
    PunchScreenGui.Enabled = State.PunchEnabled
    MainPunchToggle.BackgroundColor3 = State.PunchEnabled and Color3.fromRGB(166, 227, 161) or Color3.fromRGB(45, 45, 65)
    MainPunchToggle.Text = "Punch Button 🥊: " .. (State.PunchEnabled and "ON" or "OFF")
    MainPunchToggle.TextColor3 = State.PunchEnabled and Color3.fromRGB(17, 17, 27) or Color3.fromRGB(205, 214, 244)
end)

-- Toggle Settings Dropdown Panel
local isSettingsOpen = false
SettingsArrowBtn.MouseButton1Click:Connect(function()
    isSettingsOpen = not isSettingsOpen
    SettingsArrowBtn.Text = isSettingsOpen and "▼" or "▶"
    SettingsPanel.Visible = isSettingsOpen
    SettingsPanel.Size = isSettingsOpen and UDim2.new(0.95, 0, 0, 160) or UDim2.new(0.95, 0, 0, 0)
end)

---------------------------------------------------------
-- SAFE TARGET-ONLY FLING EXECUTION (LocalPlayer Stays Safe!)
---------------------------------------------------------
local isPunching = false
local function performSuperPunch()
    if isPunching then return end
    isPunching = true

    local char = LocalPlayer.Character
    if not char then isPunching = false; return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then isPunching = false; return end

    -- 1. Visual Punch Swing (Local Player Arm Rotation Only)
    task.spawn(function()
        pcall(function()
            local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
            local anim = Instance.new("Animation")
            anim.AnimationId = char:FindFirstChild("UpperTorso") and "rbxassetid://507770453" or "rbxassetid://125750799"
            local track = animator:LoadAnimation(anim)
            track:Play(0.05, 1, 2.5)
        end)

        local shoulder = char:FindFirstChild("Right Shoulder", true) or char:FindFirstChild("RightShoulder", true)
        if shoulder then
            local origC0 = shoulder.C0
            shoulder.C0 = origC0 * CFrame.Angles(math.rad(110), math.rad(-30), 0)
            task.wait(0.25)
            shoulder.C0 = origC0
        end
    end)

    -- 2. Detect Closest Target Player
    local targetHrp = nil
    local closestDist = 50

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local dist = (tHrp.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    targetHrp = tHrp
                end
            end
        end
    end

    -- 3. Execute Fling directly ON TARGET (LocalPlayer stays completely untouched!)
    if targetHrp then
        local pushDir = (targetHrp.Position - hrp.Position).Unit
        if pushDir ~= pushDir then pushDir = hrp.CFrame.LookVector end
        local mode = State.PunchMode

        -- MODE 1: Heavy Impulser Block (Proxy Physics Part)
        if mode == "Impulser" or mode == "Combined" then
            task.spawn(function()
                local b = Instance.new("Part")
                b.Size = Vector3.new(7, 7, 7)
                b.Transparency = 1
                b.CanCollide = true
                b.CustomPhysicalProperties = PhysicalProperties.new(100, 100, 100, 100, 100)
                b.CFrame = targetHrp.CFrame
                b.Parent = Workspace

                local bav = Instance.new("BodyAngularVelocity")
                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bav.AngularVelocity = Vector3.new(99999, 99999, 99999)
                bav.Parent = b

                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = (pushDir * 8000) + Vector3.new(0, 3500, 0)
                bv.Parent = b

                task.wait(0.22)
                b:Destroy()
            end)
        end

        -- MODE 2: Ghost Proxy Spin (Proxy Block Orbiting Target)
        if mode == "Spin" or mode == "Combined" then
            task.spawn(function()
                local ghostPart = Instance.new("Part")
                ghostPart.Size = Vector3.new(6, 6, 6)
                ghostPart.Transparency = 1
                ghostPart.CanCollide = true
                ghostPart.CustomPhysicalProperties = PhysicalProperties.new(100, 100, 100, 100, 100)
                ghostPart.Parent = Workspace

                local bav = Instance.new("BodyAngularVelocity")
                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bav.AngularVelocity = Vector3.new(0, 999999, 0)
                bav.Parent = ghostPart

                local startTime = tick()
                local stepAngle = 0
                while tick() - startTime < 0.22 do
                    stepAngle = stepAngle + 120
                    if targetHrp and targetHrp.Parent then
                        ghostPart.CFrame = targetHrp.CFrame * CFrame.Angles(0, math.rad(stepAngle), 0)
                        ghostPart.AssemblyLinearVelocity = (pushDir * 7000) + Vector3.new(0, 3000, 0)
                    end
                    RunService.Heartbeat:Wait()
                end
                ghostPart:Destroy()
            end)
        end

        -- MODE 3: Touch Impulse Surge
        if mode == "Direct" or mode == "Combined" then
            task.spawn(function()
                local touchPart = Instance.new("Part")
                touchPart.Size = Vector3.new(8, 8, 8)
                touchPart.Transparency = 1
                touchPart.CanCollide = true
                touchPart.CFrame = targetHrp.CFrame
                touchPart.Parent = Workspace

                pcall(function()
                    if firetouchinterest then
                        firetouchinterest(touchPart, targetHrp, 0)
                        firetouchinterest(touchPart, targetHrp, 1)
                    end
                    targetHrp.AssemblyLinearVelocity = (pushDir * 8000) + Vector3.new(0, 3500, 0)
                    targetHrp.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
                end)
                task.wait(0.2)
                touchPart:Destroy()
            end)
        end
    end

    task.wait(0.15)
    isPunching = false
end

PunchBtn.MouseButton1Click:Connect(performSuperPunch)

print("Tux Script 🐧 loaded successfully!")
