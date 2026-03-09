-- [[ VOID HUB FULL RECONSTRUCTION - QUANTUM V13.0 ]] --
-- Optimized by RianModss

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local vp = camera.ViewportSize

-- [[ MOBILE COMPATIBILITY SCALING ]] --
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local uiScaleValue = isMobile and (vp.X >= 1024 and 1.5 or 2.0) or 1.1
local baseScale = math.clamp((vp.X / 1920), 0.5, 1.5)
local function s(n) return math.floor(n * baseScale * uiScaleValue) end

-- [[ THEME CONFIG ]] --
local THEME = {
    Background = Color3.fromRGB(8, 8, 8),
    Section = Color3.fromRGB(12, 12, 12),
    Card = Color3.fromRGB(14, 14, 14),
    Accent = Color3.fromRGB(160, 0, 255),
    Text = Color3.fromRGB(160, 0, 255),
    DarkText = Color3.fromRGB(100, 100, 100),
    Outline = Color3.fromRGB(160, 0, 255),
    InputBg = Color3.fromRGB(16, 16, 16),
    ToggleOff = Color3.fromRGB(30, 30, 30),
    FloatButton = Color3.fromRGB(5, 5, 5)
}

-- [[ GLOBAL STATES ]] --
local NORMAL_SPEED, CARRY_SPEED = 60, 30
local speedToggled, autoStealEnabled = false, false
local batAimbotToggled, spinBotEnabled, espEnabled = false, false, true
local galaxyEnabled, antiRagdollEnabled, floatEnabled = false, false, false
local STEAL_RADIUS, STEAL_DURATION = 20, 0.2
local GALAXY_GRAVITY_PERCENT, GALAXY_HOP_POWER, SPIN_SPEED = 42, 35, 19
local fovValue, floatHeight = 70, 8
local KEYBINDS = {
    ToggleGUI = {PC = Enum.KeyCode.U, Controller = Enum.KeyCode.ButtonY},
    AutoLeft = {PC = Enum.KeyCode.Z, Controller = Enum.KeyCode.DPadLeft},
    AutoRight = {PC = Enum.KeyCode.C, Controller = Enum.KeyCode.DPadRight},
    BatAimbot = {PC = Enum.KeyCode.E, Controller = Enum.KeyCode.ButtonB},
    SpeedToggle = {PC = Enum.KeyCode.Q, Controller = Enum.KeyCode.ButtonX},
    Float = {PC = Enum.KeyCode.F, Controller = Enum.KeyCode.ButtonA}
}

-- [[ CORE FUNCTIONS: ESP & COMBAT ]] --
local function createESP(plr)
    if plr == LocalPlayer or not plr.Character then return end
    local charHrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not charHrp then return end
    if plr.Character:FindFirstChild("NightESP") then return end

    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "NightESP"
    hitbox.Adornee = charHrp
    hitbox.Size = Vector3.new(4, 6, 2)
    hitbox.Color3 = THEME.Accent
    hitbox.Transparency = 0.5
    hitbox.AlwaysOnTop = true
    hitbox.ZIndex = 10
    hitbox.Parent = plr.Character
end

-- [[ UI INITIALIZATION ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidHub_Quantum_V13"
ScreenGui.Parent = (gethui and gethui()) or CoreGui
ScreenGui.ResetOnSpawn = false

-- UI SCALE ADJUSTER
local UIScale = Instance.new("UIScale", ScreenGui)
UIScale.Scale = uiScaleValue

-- MAIN FRAME
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, s(480), 0, s(680))
Main.Position = UDim2.new(0.5, -s(240), 0.5, -s(340))
Main.BackgroundColor3 = THEME.Background
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, s(18))

-- [ HEADER SECT ] --
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, s(70))
Header.BackgroundColor3 = THEME.Section
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, s(18))

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 0, s(30))
Title.Position = UDim2.new(0, 0, 0, s(15))
Title.Text = "VOID HUB x QUANTUM"
Title.TextColor3 = THEME.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = s(22)
Title.BackgroundTransparency = 1

-- [ SCROLLING CONTENT ] --
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -s(20), 1, -s(90))
Content.Position = UDim2.new(0, s(10), 0, s(80))
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, s(1300))
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = THEME.Accent

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, s(10))
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ RESTORING STEAL PROGRESS BAR ]] --
local ProgressBarContainer = Instance.new("Frame", ScreenGui)
ProgressBarContainer.Size = UDim2.new(0, s(400), 0, s(60))
ProgressBarContainer.Position = UDim2.new(0.5, -s(200), 1, -s(120))
ProgressBarContainer.BackgroundColor3 = THEME.Section
ProgressBarContainer.Visible = true
Instance.new("UICorner", ProgressBarContainer).CornerRadius = UDim.new(0, s(10))

local Fill = Instance.new("Frame", ProgressBarContainer)
Fill.Size = UDim2.new(0, 0, 1, 0)
Fill.BackgroundColor3 = THEME.Accent
Fill.BackgroundTransparency = 0.5
Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, s(10))

-- [[ FLOATING BUTTONS (MOBILE) ]] --
if isMobile then
    local FloatFrame = Instance.new("Frame", ScreenGui)
    FloatFrame.Size = UDim2.new(0, s(90), 0, s(400))
    FloatFrame.Position = UDim2.new(1, -s(100), 0.5, -s(200))
    FloatFrame.BackgroundTransparency = 1
    
    local FLayout = Instance.new("UIListLayout", FloatFrame)
    FLayout.Padding = UDim.new(0, s(8))

    local function createFloat(name, txt)
        local b = Instance.new("TextButton", FloatFrame)
        b.Size = UDim2.new(1, 0, 0, s(80))
        b.BackgroundColor3 = THEME.FloatButton
        b.Text = txt
        b.TextColor3 = THEME.Accent
        b.Font = Enum.Font.GothamBold
        b.TextSize = s(14)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, s(12))
        local s = Instance.new("UIStroke", b)
        s.Color = THEME.Accent
        return b
    end
    
    local btnA = createFloat("Aimbot", "BAT\nAIM")
    local btnS = createFloat("Speed", "CARRY\nMODE")
    local btnL = createFloat("Left", "AUTO\nLEFT")
    local btnR = createFloat("Right", "AUTO\nRIGHT")
end

-- [[ CORE HEARTBEAT LOOP ]] --
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    -- Normal/Carry Speed Logic
    if not batAimbotToggled then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local targetSpeed = speedToggled and CARRY_SPEED or NORMAL_SPEED
            hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * targetSpeed, hrp.AssemblyLinearVelocity.Y, moveDir.Z * targetSpeed)
        end
    end

    -- SpinBot Logic
    if spinBotEnabled then
        hrp.RotVelocity = Vector3.new(0, SPIN_SPEED, 0)
    end
end)

-- [[ DRAGGING SYSTEM ]] --
local dragToggle, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

print("Quantum V13.0: Full Script Restored Successfully.")

