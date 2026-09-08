-- Tux Script 🐧 | Minecraft-Style Roblox Exploit GUI (Mobile & PC Responsive Edition)
-- Themes: Dark Glass, Neon Accents, Minecraft Cheat Columns (Celestial/Neverhook Style)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

---------------------------------------------------------
-- CLEANUP REGISTRY (For Full Script Unload)
---------------------------------------------------------
local Connections = {}
local InstancesToClean = {}
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

local function registerConn(conn)
    table.insert(Connections, conn)
    return conn
end

local function registerInst(inst)
    table.insert(InstancesToClean, inst)
    return inst
end

---------------------------------------------------------
-- STATE & CONFIG
---------------------------------------------------------
local State = {
    -- Player
    SpeedEnabled = false,
    WalkSpeed = 50,
    Fly = false,
    FlySpeed = 60,
    NoClip = false,
    InfJump = false,
    AntiAFK = false,
    
    -- Rage
    PunchEnabled = false,
    PunchMode = "Combined",
    HitboxEnabled = false,
    HitboxSize = 10,
    Spinbot = false,
    AntiFling = false,
    
    -- Fun
    ClickTP = false,
    TuxPet = false,
    Gravity = 196.2,
    ChatSpam = false,
    
    -- Visuals
    ESP = false,
    Tracers = false,
    Fullbright = false,
    
    -- Design
    Theme = "DarkTux",
    GuiVisible = true
}

---------------------------------------------------------
-- THEMES DICTIONARY
---------------------------------------------------------
local Themes = {
    DarkTux = {
        Header = Color3.fromRGB(30, 30, 46),
        Card = Color3.fromRGB(24, 24, 37),
        Accent = Color3.fromRGB(249, 226, 175),
        Text = Color3.fromRGB(205, 214, 244),
        Active = Color3.fromRGB(166, 227, 161)
    },
    NeonPurple = {
        Header = Color3.fromRGB(35, 20, 50),
        Card = Color3.fromRGB(25, 15, 38),
        Accent = Color3.fromRGB(203, 166, 247),
        Text = Color3.fromRGB(245, 224, 220),
        Active = Color3.fromRGB(243, 139, 168)
    },
    CyberCyan = {
        Header = Color3.fromRGB(15, 35, 45),
        Card = Color3.fromRGB(10, 25, 33),
        Accent = Color3.fromRGB(148, 226, 213),
        Text = Color3.fromRGB(227, 240, 245),
        Active = Color3.fromRGB(137, 220, 235)
    },
    Midnight = {
        Header = Color3.fromRGB(18, 18, 24),
        Card = Color3.fromRGB(12, 12, 16),
        Accent = Color3.fromRGB(137, 180, 250),
        Text = Color3.fromRGB(235, 238, 245),
        Active = Color3.fromRGB(166, 227, 161)
    }
}

local currentTheme = Themes.DarkTux

---------------------------------------------------------
-- TARGET GUI PARENT & CLEANUP
---------------------------------------------------------
local guiParent = game:GetService("CoreGui")
pcall(function()
    if not guiParent or not pcall(function() return guiParent.Name end) then
        guiParent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if guiParent:FindFirstChild("TuxScriptMinecraftGUI") then
    guiParent.TuxScriptMinecraftGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TuxScriptMinecraftGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent
registerInst(ScreenGui)

---------------------------------------------------------
-- 1. BEAUTIFUL LOADER ANIMATION
---------------------------------------------------------
local LoaderFrame = Instance.new("Frame")
LoaderFrame.Name = "LoaderFrame"
LoaderFrame.Size = UDim2.new(0, 290, 0, 160)
LoaderFrame.Position = UDim2.new(0.5, -145, 0.5, -80)
LoaderFrame.BackgroundColor3 = currentTheme.Card
LoaderFrame.BorderSizePixel = 0
LoaderFrame.ClipsDescendants = true
LoaderFrame.Parent = ScreenGui

local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 14)
LoaderCorner.Parent = LoaderFrame

local LoaderStroke = Instance.new("UIStroke")
LoaderStroke.Color = currentTheme.Accent
LoaderStroke.Thickness = 2
LoaderStroke.Parent = LoaderFrame

local LoaderLogo = Instance.new("TextLabel")
LoaderLogo.Size = UDim2.new(1, 0, 0, 45)
LoaderLogo.Position = UDim2.new(0, 0, 0, 20)
LoaderLogo.BackgroundTransparency = 1
LoaderLogo.Text = "Tux Script 🐧"
LoaderLogo.TextColor3 = currentTheme.Accent
LoaderLogo.TextSize = 22
LoaderLogo.Font = Enum.Font.GothamBold
LoaderLogo.Parent = LoaderFrame

local LoaderStatus = Instance.new("TextLabel")
LoaderStatus.Size = UDim2.new(1, 0, 0, 25)
LoaderStatus.Position = UDim2.new(0, 0, 0, 65)
LoaderStatus.BackgroundTransparency = 1
LoaderStatus.Text = "Loading Mobile & PC Interface..."
LoaderStatus.TextColor3 = currentTheme.Text
LoaderStatus.TextSize = 12
LoaderStatus.Font = Enum.Font.Gotham
LoaderStatus.Parent = LoaderFrame

local ProgressBarBg = Instance.new("Frame")
ProgressBarBg.Size = UDim2.new(0.8, 0, 0, 6)
ProgressBarBg.Position = UDim2.new(0.1, 0, 0, 105)
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
ProgressBarBg.BorderSizePixel = 0
ProgressBarBg.Parent = LoaderFrame

local ProgressBgCorner = Instance.new("UICorner")
ProgressBgCorner.CornerRadius = UDim.new(1, 0)
ProgressBgCorner.Parent = ProgressBarBg

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = currentTheme.Accent
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.Parent = ProgressBarBg

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(1, 0)
ProgressFillCorner.Parent = ProgressBarFill

-- Animate Loader
local loaderTweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local progressTween = TweenService:Create(ProgressBarFill, loaderTweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
progressTween:Play()

progressTween.Completed:Connect(function()
    LoaderStatus.Text = "Welcome, LO! Ready 🚀"
    task.wait(0.3)
    local fadeOut = TweenService:Create(LoaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
    fadeOut:Play()
    for _, child in pairs(LoaderFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            if child:IsA("TextLabel") then
                TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            end
        end
    end
    task.wait(0.4)
    LoaderFrame.Visible = false
end)

---------------------------------------------------------
-- 2. RESPONSIVE MAIN CONTAINER (Mobile & PC Support)
---------------------------------------------------------
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0.92, 0, 0.85, 0)
MainContainer.Position = UDim2.new(0.04, 0, 0.075, 0)
MainContainer.BackgroundTransparency = 1
MainContainer.Visible = true
MainContainer.Parent = ScreenGui

-- Max/Min Size Bounds for PC & Mobile
local SizeConstraint = Instance.new("UISizeConstraint")
SizeConstraint.MaxSize = Vector2.new(960, 520)
SizeConstraint.MinSize = Vector2.new(280, 260)
SizeConstraint.Parent = MainContainer

-- Top Header Bar
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 42)
HeaderBar.Position = UDim2.new(0, 0, 0, 0)
HeaderBar.BackgroundColor3 = currentTheme.Header
HeaderBar.BorderSizePixel = 0
HeaderBar.Active = true
HeaderBar.Parent = MainContainer

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = HeaderBar

local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Color = currentTheme.Accent
HeaderStroke.Thickness = 2
HeaderStroke.Parent = HeaderBar

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0.6, 0, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "TuxScript 🐧"
HeaderTitle.TextColor3 = currentTheme.Accent
HeaderTitle.TextSize = 15
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = HeaderBar

-- Header Buttons: Minimize & Full Close (Destroy)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -74, 0, 7)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
MinimizeBtn.Text = "─"
MinimizeBtn.TextColor3 = currentTheme.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = HeaderBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(235, 87, 87)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = HeaderBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Draggable HeaderBar
local hDragging, hDragInput, hDragStart, hStartPos
HeaderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hDragging = true
        hDragStart = input.Position
        hStartPos = MainContainer.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                hDragging = false
            end
        end)
    end
end)

HeaderBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        hDragInput = input
    end
end)

registerConn(UserInputService.InputChanged:Connect(function(input)
    if input == hDragInput and hDragging then
        local delta = input.Position - hDragStart
        MainContainer.Position = UDim2.new(hStartPos.X.Scale, hStartPos.X.Offset + delta.X, hStartPos.Y.Scale, hStartPos.Y.Offset + delta.Y)
    end
end))

-- HORIZONTAL SCROLLING FRAME FOR COLUMNS (Touch Swipe Support on Mobile!)
local ColumnsFrame = Instance.new("ScrollingFrame")
ColumnsFrame.Name = "ColumnsFrame"
ColumnsFrame.Size = UDim2.new(1, 0, 1, -48)
ColumnsFrame.Position = UDim2.new(0, 0, 0, 48)
ColumnsFrame.BackgroundTransparency = 1
ColumnsFrame.BorderSizePixel = 0
ColumnsFrame.ScrollBarThickness = 4
ColumnsFrame.ScrollBarImageColor3 = currentTheme.Accent
ColumnsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ColumnsFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
ColumnsFrame.Parent = MainContainer

local ColumnsLayout = Instance.new("UIListLayout")
ColumnsLayout.Parent = ColumnsFrame
ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
ColumnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ColumnsLayout.Padding = UDim.new(0, 10)
ColumnsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

---------------------------------------------------------
-- MINECRAFT CATEGORY COLUMN BUILDER
---------------------------------------------------------
local categoryColumns = {}

local function createCategoryColumn(title, icon, layoutOrder)
    local col = Instance.new("Frame")
    col.Name = title .. "Column"
    col.Size = UDim2.new(0, 165, 0.98, 0)
    col.BackgroundColor3 = currentTheme.Card
    col.BorderSizePixel = 0
    col.LayoutOrder = layoutOrder
    col.Parent = ColumnsFrame

    local colCorner = Instance.new("UICorner")
    colCorner.CornerRadius = UDim.new(0, 10)
    colCorner.Parent = col

    local colStroke = Instance.new("UIStroke")
    colStroke.Color = currentTheme.Header
    colStroke.Thickness = 1.5
    colStroke.Parent = col

    -- Column Header
    local cHeader = Instance.new("TextLabel")
    cHeader.Size = UDim2.new(1, 0, 0, 34)
    cHeader.Position = UDim2.new(0, 0, 0, 0)
    cHeader.BackgroundColor3 = currentTheme.Header
    cHeader.Text = icon .. "  " .. title
    cHeader.TextColor3 = currentTheme.Accent
    cHeader.TextSize = 13
    cHeader.Font = Enum.Font.GothamBold
    cHeader.Parent = col

    local cHeaderCorner = Instance.new("UICorner")
    cHeaderCorner.CornerRadius = UDim.new(0, 10)
    cHeaderCorner.Parent = cHeader

    -- Scroll Area for Features inside Column
    local cScroll = Instance.new("ScrollingFrame")
    cScroll.Size = UDim2.new(1, -10, 1, -40)
    cScroll.Position = UDim2.new(0, 5, 0, 36)
    cScroll.BackgroundTransparency = 1
    cScroll.BorderSizePixel = 0
    cScroll.ScrollBarThickness = 3
    cScroll.ScrollBarImageColor3 = currentTheme.Accent
    cScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    cScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    cScroll.Parent = col

    local cLayout = Instance.new("UIListLayout")
    cLayout.Parent = cScroll
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout.Padding = UDim.new(0, 6)
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    categoryColumns[title] = cScroll
    return cScroll
end

-- Create the 5 Requested Minecraft Categories
local playerScroll  = createCategoryColumn("Player", "👤", 1)
local rageScroll    = createCategoryColumn("Rage", "⚡", 2)
local funScroll     = createCategoryColumn("Fun", "🎮", 3)
local visualsScroll = createCategoryColumn("Visuals", "👁️", 4)
local designScroll  = createCategoryColumn("Design", "🎨", 5)

---------------------------------------------------------
-- UI MODULE BUILDERS (Toggles, Sliders, Dropdowns)
---------------------------------------------------------

-- Create Module Toggle Button
local function addModuleToggle(parentScroll, name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Toggle"
    btn.Size = UDim2.new(0.96, 0, 0, 34)
    btn.BackgroundColor3 = defaultState and currentTheme.Active or Color3.fromRGB(38, 38, 55)
    btn.Text = name
    btn.TextColor3 = defaultState and Color3.fromRGB(17, 17, 27) or currentTheme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.Parent = parentScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and currentTheme.Active or Color3.fromRGB(38, 38, 55)
        local targetTextColor = state and Color3.fromRGB(17, 17, 27) or currentTheme.Text
        
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor, TextColor3 = targetTextColor}):Play()
        callback(state)
    end)
    return btn
end

-- Create Module Slider
local function addModuleSlider(parentScroll, name, min, max, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.96, 0, 0, 46)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    frame.Parent = parentScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -10, 0, 20)
    titleLbl.Position = UDim2.new(0, 5, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = name .. ": " .. tostring(defaultVal)
    titleLbl.TextColor3 = currentTheme.Text
    titleLbl.Font = Enum.Font.Gotham
    titleLbl.TextSize = 10
    titleLbl.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.9, 0, 0, 6)
    sliderBg.Position = UDim2.new(0.05, 0, 0, 28)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    sliderBg.Parent = frame

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(1, 0)
    sCorner.Parent = sliderBg

    local fillPercent = math.clamp((defaultVal - min) / (max - min), 0, 1)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = currentTheme.Accent
    sliderFill.Parent = sliderBg

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = sliderFill

    local sDragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        titleLbl.Text = name .. ": " .. tostring(val)
        callback(val)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sDragging = true
            updateSlider(input)
        end
    end)

    registerConn(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sDragging = false
        end
    end))

    registerConn(UserInputService.InputChanged:Connect(function(input)
        if sDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end))
end

---------------------------------------------------------
-- 3. CATEGORY MODULES IMPLEMENTATION
---------------------------------------------------------

-- ==================== PLAYER CATEGORY ====================

-- Speedhack
addModuleToggle(playerScroll, "Speedhack ⚡", false, function(enabled)
    State.SpeedEnabled = enabled
end)
addModuleSlider(playerScroll, "Speed", 16, 200, 50, function(val)
    State.WalkSpeed = val
end)

registerConn(RunService.Stepped:Connect(function()
    if State.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = State.WalkSpeed
    end
end))

-- Fly (Upright CFrame)
local flyConn
addModuleToggle(playerScroll, "Fly 🕊️", false, function(enabled)
    State.Fly = enabled
    local char = LocalPlayer.Character
    if not char then return end

    if enabled then
        if flyConn then flyConn:Disconnect() end
        flyConn = registerConn(RunService.RenderStepped:Connect(function(dt)
            if not State.Fly or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if flyConn then flyConn:Disconnect() end
                return
            end

            local curChar = LocalPlayer.Character
            local curHrp = curChar:FindFirstChild("HumanoidRootPart")
            local curHum = curChar:FindFirstChildOfClass("Humanoid")

            if curHum then curHum.PlatformStand = false end

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

                if curHum and curHum.MoveDirection.Magnitude > 0 and moveDir == Vector3.zero then
                    moveDir = (camCF:VectorToWorldSpace(curHum.MoveDirection)).Unit
                end

                if moveDir.Magnitude > 0 then
                    local yawCFrame = CFrame.Angles(0, math.atan2(-camCF.LookVector.X, -camCF.LookVector.Z), 0)
                    local nextPos = curHrp.Position + (moveDir.Unit * State.FlySpeed * dt)
                    curHrp.CFrame = CFrame.new(nextPos) * yawCFrame
                end
            end
        end))
    else
        if flyConn then flyConn:Disconnect() end
    end
end)

-- NoClip
registerConn(RunService.Stepped:Connect(function()
    if State.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))
addModuleToggle(playerScroll, "NoClip 👻", false, function(enabled)
    State.NoClip = enabled
end)

-- Infinite Jump
registerConn(UserInputService.JumpRequest:Connect(function()
    if State.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))
addModuleToggle(playerScroll, "Infinite Jump 🦘", false, function(enabled)
    State.InfJump = enabled
end)

-- Anti-AFK
local afkConn
addModuleToggle(playerScroll, "Anti-AFK ⏰", false, function(enabled)
    State.AntiAFK = enabled
    if enabled then
        local vu = game:GetService("VirtualUser")
        afkConn = registerConn(LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end))
    else
        if afkConn then afkConn:Disconnect() end
    end
end)

-- ==================== RAGE CATEGORY ====================

-- Floating Action Button for Super Punch
local PunchActionGui = Instance.new("ScreenGui")
PunchActionGui.Name = "TuxPunchActionGui"
PunchActionGui.ResetOnSpawn = false
PunchActionGui.Enabled = false
PunchActionGui.Parent = guiParent
registerInst(PunchActionGui)

local PunchBtn = Instance.new("TextButton")
PunchBtn.Size = UDim2.new(0, 65, 0, 65)
PunchBtn.Position = UDim2.new(0.85, -33, 0.75, -33)
PunchBtn.BackgroundColor3 = currentTheme.Accent
PunchBtn.Text = "PUNCH\n🥊"
PunchBtn.TextColor3 = Color3.fromRGB(17, 17, 27)
PunchBtn.Font = Enum.Font.GothamBold
PunchBtn.TextSize = 12
PunchBtn.Parent = PunchActionGui

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(1, 0)
pCorner.Parent = PunchBtn

local pStroke = Instance.new("UIStroke")
pStroke.Color = Color3.fromRGB(255, 255, 255)
pStroke.Thickness = 2
pStroke.Parent = PunchBtn

-- Draggable Punch Action Button
local pDrag, pInput, pStart, pPos
PunchBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        pDrag = true
        pStart = input.Position
        pPos = PunchBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then pDrag = false end
        end)
    end
end)

PunchBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        pInput = input
    end
end)

registerConn(UserInputService.InputChanged:Connect(function(input)
    if input == pInput and pDrag then
        local delta = input.Position - pStart
        PunchBtn.Position = UDim2.new(pPos.X.Scale, pPos.X.Offset + delta.X, pPos.Y.Scale, pPos.Y.Offset + delta.Y)
    end
end))

-- AUTHENTIC REPLICATED SUPER PUNCH FLING (Instant Detachment & Anti-Void Protection)
local isPunching = false
local function performSuperPunch()
    if isPunching then return end
    isPunching = true

    local char = LocalPlayer.Character
    if not char then isPunching = false; return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then isPunching = false; return end

    -- 1. Single-Play Arm Swing Animation (No Looping!)
    task.spawn(function()
        pcall(function()
            local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
            local anim = Instance.new("Animation")
            anim.AnimationId = char:FindFirstChild("UpperTorso") and "rbxassetid://507770453" or "rbxassetid://125750799"
            local track = animator:LoadAnimation(anim)
            track.Looped = false
            track:Play(0.05, 1, 2.5)
            task.delay(0.35, function()
                pcall(function() track:Stop() end)
            end)
        end)

        local shoulder = char:FindFirstChild("Right Shoulder", true) or char:FindFirstChild("RightShoulder", true)
        if shoulder then
            local origC0 = shoulder.C0
            shoulder.C0 = origC0 * CFrame.Angles(math.rad(110), math.rad(-30), 0)
            task.wait(0.25)
            shoulder.C0 = origC0
        end
    end)

    -- 2. Detect Target Player (Aim-First Mouse Target + Universal Avatar Scanner)
    local targetCharacter = nil
    local targetPart = nil
    local maxPunchDist = 85 -- Safe distance to prevent Anti-Cheat speed/teleport detections
    local closestDist = maxPunchDist

    -- Universal rig part detector (R6, R15, custom skins, bundles, mesh rigs)
    local function getTargetRoot(character)
        if not character then return nil end
        -- Prioritize central torso parts that have solid collisions in R6 & R15
        return character:FindFirstChild("Torso")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("LowerTorso")
            or character:FindFirstChild("Head")
            or (character.PrimaryPart and character.PrimaryPart:IsA("BasePart") and character.PrimaryPart)
            or character:FindFirstChildWhichIsA("BasePart")
    end

    -- Priority 1: Aiming directly at a player with Mouse
    if Mouse.Target then
        local mChar = Mouse.Target.Parent
        if mChar and not mChar:FindFirstChildOfClass("Humanoid") and mChar.Parent then
            mChar = mChar.Parent
        end
        local mPlayer = Players:GetPlayerFromCharacter(mChar)
        if mPlayer and mPlayer ~= LocalPlayer and mChar then
            local mHum = mChar:FindFirstChildOfClass("Humanoid")
            local mRoot = getTargetRoot(mChar)
            if mRoot and (not mHum or mHum.Health > 0) then
                local dist = (mRoot.Position - hrp.Position).Magnitude
                if dist <= maxPunchDist then
                    targetCharacter = mChar
                    targetPart = mRoot
                end
            end
        end
    end

    -- Priority 2: Closest Player within safe melee range
    if not targetCharacter then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tChar = player.Character
                local tHum = tChar:FindFirstChildOfClass("Humanoid")
                local tMainPart = getTargetRoot(tChar)

                if tMainPart and (not tHum or tHum.Health > 0) then
                    local dist = (tMainPart.Position - hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        targetCharacter = tChar
                        targetPart = tMainPart
                    end
                end
            end
        end
    end

    -- 3. True Skid Fling Engine (Anti-Death, Anti-Cheat Safe, Lead-Ramming)
    if targetCharacter and targetPart and targetCharacter.Parent then
        local homeCF = hrp.CFrame

        -- 1. Anti-Death & State Protection
        local origDeadState = humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead)
        local origFallingState = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
        local origRagdollState = humanoid:GetStateEnabled(Enum.HumanoidStateType.Ragdoll)
        local origPhysicsState = humanoid:GetStateEnabled(Enum.HumanoidStateType.Physics)

        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        humanoid.PlatformStand = true

        -- Disable common in-game fall damage & touch damage localscripts
        for _, scriptName in ipairs({"FallDamage", "FallDamageScript", "Fall_Damage", "FallDamage_Client", "RagdollClient", "TouchDamage"}) do
            pcall(function()
                local s = char:FindFirstChild(scriptName) or (LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild(scriptName))
                if s and s:IsA("LocalScript") then
                    s.Disabled = true
                end
            end)
        end

        -- 2. Prevent Ground & Touch Damage (NoClip + CanTouch = false on all limbs)
        local origProperties = {}
        local origCanTouch = {}
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                origProperties[p] = p.CustomPhysicalProperties
                origCanTouch[p] = p.CanTouch
                pcall(function()
                    p.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5) -- High mass
                    if p ~= hrp then
                        p.CanTouch = false -- Prevent .Touched damage from ground/traps
                    end
                end)
            end
        end

        -- Continuous Stepped NoClip: Absolutely NO collision with ground, terrain, or map
        local noclipConn = RunService.Stepped:Connect(function()
            if char and char.Parent then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)

        -- 3. Controlled High-Torque Spin (Safe within Anti-Cheat limits, but lethal mass)
        local bav = Instance.new("BodyAngularVelocity")
        bav.Name = "TuxPunchBAM"
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.AngularVelocity = Vector3.new(0, 3500, 0) -- Safe rotational threshold
        bav.P = math.huge
        bav.Parent = hrp

        -- 4. Target Tracking & Kinetic Ramming Loop
        local duration = 0.38
        local startTime = tick()

        while tick() - startTime < duration do
            if not targetCharacter or not targetCharacter.Parent or not targetPart or not targetPart.Parent then
                break
            end

            local tPos = targetPart.Position
            local tVel = targetPart.AssemblyLinearVelocity

            -- Kinematic Lead: match velocity so moving targets can NEVER outrun the punch
            local lead = (tVel.Magnitude > 1) and (tVel * 0.035) or Vector3.zero
            local targetPos = tPos + lead

            -- Safe height: ensure HRP never clips below ground level
            local safeY = math.max(targetPos.Y, 2.8)
            local cycle = (tick() % 0.08 > 0.04) and 0.2 or -0.2
            local attackCFrame = CFrame.new(targetPos.X, safeY + cycle, targetPos.Z) * CFrame.Angles(0, math.rad(tick() * 1500 % 360), 0)

            hrp.CFrame = attackCFrame

            -- Ramming impulse: local velocity pushes into the target's movement vector
            local ramVel = (tVel.Magnitude > 1) and (tVel + tVel.Unit * 60) or Vector3.new(0, 30, 0)
            -- Cap velocity to 180 to guarantee no Anti-Cheat speed/velocity flags
            if ramVel.Magnitude > 180 then
                ramVel = ramVel.Unit * 180
            end
            hrp.AssemblyLinearVelocity = ramVel

            -- Detach early if target got launched
            if tVel.Magnitude > 180 then
                break
            end

            RunService.Heartbeat:Wait()
        end

        -- 5. Safe Cleanup & Home Recovery
        bav:Destroy()
        noclipConn:Disconnect()

        -- Restore original physical properties & CanTouch
        for p, prop in pairs(origProperties) do
            if p and p.Parent then
                pcall(function() p.CustomPhysicalProperties = prop end)
            end
        end
        for p, touch in pairs(origCanTouch) do
            if p and p.Parent then
                pcall(function() p.CanTouch = touch end)
            end
        end

        -- Velocity Nullification & Smooth Home Return
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = homeCF

        RunService.Heartbeat:Wait()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = homeCF

        task.wait(0.05)
        humanoid.PlatformStand = false

        -- Restore Humanoid states safely
        task.delay(0.2, function()
            if humanoid and humanoid.Parent then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, origDeadState)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, origFallingState)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, origRagdollState)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, origPhysicsState)
            end
        end)
    end

    task.wait(0.1)
    isPunching = false
end

PunchBtn.MouseButton1Click:Connect(performSuperPunch)

addModuleToggle(rageScroll, "Super Punch 🥊", false, function(enabled)
    State.PunchEnabled = enabled
    PunchActionGui.Enabled = enabled
end)

-- Hitbox Expander (Supports custom avatars, R6, R15, and custom meshes)
addModuleToggle(rageScroll, "Hitbox Expander 📦", false, function(enabled)
    State.HitboxEnabled = enabled
end)
addModuleSlider(rageScroll, "Hitbox Size", 4, 25, 10, function(val)
    State.HitboxSize = val
end)

registerConn(RunService.RenderStepped:Connect(function()
    if State.HitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tChar = player.Character
                local targetP = tChar:FindFirstChild("HumanoidRootPart")
                    or tChar:FindFirstChild("Torso")
                    or tChar:FindFirstChild("UpperTorso")
                    or tChar:FindFirstChildOfClass("BasePart")

                if targetP then
                    targetP.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                    targetP.Transparency = 0.7
                    targetP.Color = currentTheme.Accent
                    targetP.Material = Enum.Material.ForceField
                    targetP.CanCollide = false
                end
            end
        end
    end
end))

-- Spinbot
addModuleToggle(rageScroll, "Spinbot 🌀", false, function(enabled)
    State.Spinbot = enabled
end)

registerConn(RunService.RenderStepped:Connect(function()
    if State.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end
end))

-- Anti-Fling Shield
addModuleToggle(rageScroll, "Anti-Fling Shield 🛡️", false, function(enabled)
    State.AntiFling = enabled
end)

registerConn(RunService.Heartbeat:Connect(function()
    if State.AntiFling and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.AssemblyLinearVelocity.Magnitude > 150 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end))

-- ==================== FUN CATEGORY ====================

-- Click Teleport
addModuleToggle(funScroll, "Click Teleport 📍", false, function(enabled)
    State.ClickTP = enabled
end)

registerConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and State.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Mouse.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end))

-- Tux Companion Pet
local petModel = nil
addModuleToggle(funScroll, "Tux Companion Pet 🐧", false, function(enabled)
    State.TuxPet = enabled
    if enabled then
        if petModel then petModel:Destroy() end
        petModel = Instance.new("Part")
        petModel.Name = "TuxPet"
        petModel.Size = Vector3.new(1.5, 1.8, 1.2)
        petModel.Color = Color3.fromRGB(30, 30, 46)
        petModel.Material = Enum.Material.SmoothPlastic
        petModel.CanCollide = false
        petModel.Parent = Workspace
        registerInst(petModel)

        local petFace = Instance.new("Decal")
        petFace.Texture = "rbxassetid://28328223"
        petFace.Face = Enum.NormalId.Front
        petFace.Parent = petModel

        local petGlow = Instance.new("SelectionBox")
        petGlow.Adornee = petModel
        petGlow.Color3 = currentTheme.Accent
        petGlow.Parent = petModel

        local petAngle = 0
        registerConn(RunService.RenderStepped:Connect(function()
            if State.TuxPet and petModel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                petAngle = petAngle + 2
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local offset = Vector3.new(math.sin(math.rad(petAngle)) * 3.5, 2.5 + math.sin(math.rad(petAngle * 2)) * 0.5, math.cos(math.rad(petAngle)) * 3.5)
                petModel.CFrame = CFrame.new(hrp.Position + offset, hrp.Position)
            else
                if petModel then petModel:Destroy() end
            end
        end))
    else
        if petModel then petModel:Destroy(); petModel = nil end
    end
end)

-- Gravity Modifier
addModuleSlider(funScroll, "Gravity", 0, 196, 196, function(val)
    Workspace.Gravity = val
end)

-- Chat Spammer
local spamConn
addModuleToggle(funScroll, "Tux Chat Spammer 💬", false, function(enabled)
    State.ChatSpam = enabled
    if enabled then
        spamConn = task.spawn(function()
            while State.ChatSpam do
                pcall(function()
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Tux Script 🐧 | Best Roblox Cheat Engine!", "All")
                end)
                task.wait(4)
            end
        end)
    end
end)

-- ==================== VISUALS CATEGORY ====================

-- Highlight ESP
local espHighlights = {}
local function applyESP(player)
    if player == LocalPlayer then return end
    local function highlightChar(char)
        if not char then return end
        if not espHighlights[player] then
            local hl = Instance.new("Highlight")
            hl.Name = "TuxESP"
            hl.FillColor = currentTheme.Accent
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.4
            hl.Enabled = State.ESP
            hl.Parent = char
            espHighlights[player] = hl
            registerInst(hl)
        else
            espHighlights[player].Parent = char
            espHighlights[player].Enabled = State.ESP
        end
    end
    if player.Character then highlightChar(player.Character) end
    registerConn(player.CharacterAdded:Connect(highlightChar))
end

for _, plr in pairs(Players:GetPlayers()) do applyESP(plr) end
registerConn(Players.PlayerAdded:Connect(applyESP))

addModuleToggle(visualsScroll, "Highlight ESP 👁️", false, function(enabled)
    State.ESP = enabled
    for _, hl in pairs(espHighlights) do
        if hl then hl.Enabled = enabled end
    end
end)

-- Tracers ESP
local tracerLines = {}
addModuleToggle(visualsScroll, "Tracers 🎯", false, function(enabled)
    State.Tracers = enabled
end)

registerConn(RunService.RenderStepped:Connect(function()
    if State.Tracers then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local line = tracerLines[player]
                    if not line then
                        line = Drawing.new("Line")
                        line.Thickness = 1.5
                        line.Color = currentTheme.Accent
                        line.Transparency = 0.8
                        tracerLines[player] = line
                    end
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Visible = true
                else
                    if tracerLines[player] then tracerLines[player].Visible = false end
                end
            else
                if tracerLines[player] then tracerLines[player].Visible = false end
            end
        end
    else
        for _, line in pairs(tracerLines) do
            line.Visible = false
        end
    end
end))

-- Fullbright
addModuleToggle(visualsScroll, "Fullbright ☀️", false, function(enabled)
    State.Fullbright = enabled
    if enabled then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
    end
end)

-- ==================== DESIGN & CONTROL CATEGORY ====================

-- Theme Switches
local themeList = {"DarkTux", "NeonPurple", "CyberCyan", "Midnight"}
for _, themeName in ipairs(themeList) do
    addModuleToggle(designScroll, "Theme: " .. themeName, (State.Theme == themeName), function()
        State.Theme = themeName
        currentTheme = Themes[themeName]
        HeaderBar.BackgroundColor3 = currentTheme.Header
        HeaderStroke.Color = currentTheme.Accent
        HeaderTitle.TextColor3 = currentTheme.Accent
        LoaderStroke.Color = currentTheme.Accent
        ProgressBarFill.BackgroundColor3 = currentTheme.Accent
        PunchBtn.BackgroundColor3 = currentTheme.Accent
        ColumnsFrame.ScrollBarImageColor3 = currentTheme.Accent
        
        for _, col in pairs(ColumnsFrame:GetChildren()) do
            if col:IsA("Frame") then
                col.BackgroundColor3 = currentTheme.Card
                local cHead = col:FindFirstChildOfClass("TextLabel")
                if cHead then
                    cHead.BackgroundColor3 = currentTheme.Header
                    cHead.TextColor3 = currentTheme.Accent
                end
            end
        end
    end)
end

-- Full Unload Script (Destroys Everything Cleanly)
addModuleToggle(designScroll, "UNLOAD SCRIPT ❌", false, function()
    print("Unloading Tux Script 🐧...")
    
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    Lighting.Ambient = OriginalLighting.Ambient

    for _, line in pairs(tracerLines) do
        pcall(function() line:Remove() end)
    end

    for _, inst in ipairs(InstancesToClean) do
        pcall(function() inst:Destroy() end)
    end

    ScreenGui:Destroy()
    print("Tux Script 🐧 cleanly unloaded!")
end)

---------------------------------------------------------
-- WINDOW CONTROLS & KEYBIND TOGGLE (RAlt / Mobile Toggle)
---------------------------------------------------------

-- Minimize Button
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ColumnsFrame.Visible = not isMinimized
    MainContainer.Size = isMinimized and UDim2.new(0.92, 0, 0, 42) or UDim2.new(0.92, 0, 0.85, 0)
end)

-- Close Button (Unloads Script Completely)
CloseBtn.MouseButton1Click:Connect(function()
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    Lighting.Ambient = OriginalLighting.Ambient
    for _, line in pairs(tracerLines) do pcall(function() line:Remove() end) end
    ScreenGui:Destroy()
    print("Tux Script 🐧 cleanly unloaded via Close Button!")
end)

-- RAlt Keybind Toggle & Mobile Floating Toggle
registerConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightAlt then
        State.GuiVisible = not State.GuiVisible
        MainContainer.Visible = State.GuiVisible
    end
end))

-- Floating Mobile GUI Toggle Button (For iOS/Android users without RAlt key)
local MobileToggleGui = Instance.new("ScreenGui")
MobileToggleGui.Name = "TuxMobileToggle"
MobileToggleGui.ResetOnSpawn = false
MobileToggleGui.Parent = guiParent
registerInst(MobileToggleGui)

local MobileBtn = Instance.new("TextButton")
MobileBtn.Size = UDim2.new(0, 48, 0, 48)
MobileBtn.Position = UDim2.new(0, 12, 0.35, 0)
MobileBtn.BackgroundColor3 = currentTheme.Header
MobileBtn.Text = "🐧"
MobileBtn.TextSize = 22
MobileBtn.Parent = MobileToggleGui

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(1, 0)
mCorner.Parent = MobileBtn

local mStroke = Instance.new("UIStroke")
mStroke.Color = currentTheme.Accent
mStroke.Thickness = 2
mStroke.Parent = MobileBtn

-- Make Mobile Toggle Button Draggable
local mDrag, mInput, mStart, mPos
MobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDrag = true
        mStart = input.Position
        mPos = MobileBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then mDrag = false end
        end)
    end
end)

MobileBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        mInput = input
    end
end)

registerConn(UserInputService.InputChanged:Connect(function(input)
    if input == mInput and mDrag then
        local delta = input.Position - mStart
        MobileBtn.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + delta.X, mPos.Y.Scale, mPos.Y.Offset + delta.Y)
    end
end))

MobileBtn.MouseButton1Click:Connect(function()
    State.GuiVisible = not State.GuiVisible
    MainContainer.Visible = State.GuiVisible
end)

print("Tux Script 🐧 Mobile & PC Minecraft GUI initialized successfully!")
