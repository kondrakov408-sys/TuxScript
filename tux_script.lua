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

-- 3. Fly (PlatformStand + Camera Vector)
local flyConn
createToggleButton("Fly 🕊️", false, function(enabled)
    State.Fly = enabled
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if enabled then
        if humanoid then humanoid.PlatformStand = true end

        local bv = hrp:FindFirstChild("TuxFlyBV") or Instance.new("BodyVelocity")
        bv.Name = "TuxFlyBV"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        local bg = hrp:FindFirstChild("TuxFlyBG") or Instance.new("BodyGyro")
        bg.Name = "TuxFlyBG"
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 9e4
        bg.CFrame = Camera.CFrame
        bg.Parent = hrp

        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.RenderStepped:Connect(function()
            if not State.Fly or not hrp or not hrp.Parent then
                if flyConn then flyConn:Disconnect() end
                return
            end
            if humanoid then humanoid.PlatformStand = true end
            bg.CFrame = Camera.CFrame

            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            -- Mobile joystick support
            if humanoid and humanoid.MoveDirection.Magnitude > 0 and moveDir == Vector3.zero then
                moveDir = (Camera.CFrame:VectorToWorldSpace(humanoid.MoveDirection)).Unit
            end

            bv.Velocity = moveDir * State.FlySpeed
        end)
    else
        if humanoid then humanoid.PlatformStand = false end
        if hrp then
            if hrp:FindFirstChild("TuxFlyBV") then hrp.TuxFlyBV:Destroy() end
            if hrp:FindFirstChild("TuxFlyBG") then hrp.TuxFlyBG:Destroy() end
        end
        if flyConn then flyConn:Disconnect() end
    end
end)

---------------------------------------------------------
-- 4. PUNCH BUTTON & DASH-FLING KNOCKBACK
---------------------------------------------------------
local PunchScreenGui = Instance.new("ScreenGui")
PunchScreenGui.Name = "TuxPunchGui"
PunchScreenGui.ResetOnSpawn = false
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

-- Procedural Arm Swing + Fling Logic
local isPunching = false
local function performSuperPunch()
    if isPunching then return end
    isPunching = true

    local char = LocalPlayer.Character
    if not char then isPunching = false; return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then isPunching = false; return end

    -- 1. Arm Swing Animation (Procedural + Track Fallback)
    task.spawn(function()
        -- Try playing R6 / R15 Punch Animation Track
        pcall(function()
            local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid
            local anim = Instance.new("Animation")
            anim.AnimationId = char:FindFirstChild("UpperTorso") and "rbxassetid://567480700" or "rbxassetid://125750799"
            local track = animator:LoadAnimation(anim)
            track:Play()
        end)

        -- Procedural Arm Swing (Guaranteed Visual Feedback)
        local rightArmMotor = char:FindFirstChild("Right Shoulder", true) or char:FindFirstChild("RightShoulder", true)
        if rightArmMotor then
            local origC0 = rightArmMotor.C0
            rightArmMotor.C0 = origC0 * CFrame.Angles(math.rad(90), 0, math.rad(20))
            task.wait(0.25)
            rightArmMotor.C0 = origC0
        end
    end)

    -- 2. Find Closest Target Player
    local closestTarget = nil
    local closestDist = 35 -- Radius 35 studs

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local dist = (targetHrp.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = targetHrp
                end
            end
        end
    end

    -- 3. Dash & Super Fling Attack into Target
    if closestTarget then
        local targetPos = closestTarget.Position
        local attackDirection = (targetPos - hrp.Position).Unit
        if attackDirection ~= attackDirection then attackDirection = hrp.CFrame.LookVector end

        -- Teleport directly into target & apply extreme physics velocity/rotational collision
        local bav = Instance.new("BodyAngularVelocity")
        bav.Name = "TuxFlingBAV"
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 99999, 0)
        bav.Parent = hrp

        local bv = Instance.new("BodyVelocity")
        bv.Name = "TuxFlingBV"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = (attackDirection * 2000) + Vector3.new(0, 800, 0)
        bv.Parent = hrp

        -- Dash into target for 0.18s
        local startTime = tick()
        while tick() - startTime < 0.18 do
            hrp.CFrame = closestTarget.CFrame * CFrame.new(0, 0, 0.5)
            RunService.Heartbeat:Wait()
        end

        -- Clean up fling forces
        bav:Destroy()
        bv:Destroy()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end

    task.wait(0.1)
    isPunching = false
end

PunchBtn.MouseButton1Click:Connect(performSuperPunch)

print("Tux Script 🐧 loaded successfully!")
