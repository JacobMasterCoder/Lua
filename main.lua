-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local player = LocalPlayer

-- Variables
local webhookEnabled = false

local heartbeatConnection
local espEnabled = false
local nameEnabled = false
local espFolder = Instance.new("Folder", Workspace)
espFolder.Name = "BrainrotESP"

-- Lock ESP Variables
local lockEnabled = false
local lockTarget
local lockBillboard
local lockDuration = 5 -- seconds
local lockStartTime

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoName Hub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
MainFrame.Size = UDim2.new(0, 600, 0, 350)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Drag Detector
local dragDetector = Instance.new("UIDragDetector")
dragDetector.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 40, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Steal a Brainrot | NoName Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Title.ZIndex = 5

-- Window Buttons
local WindowButtons = Instance.new("Frame")
WindowButtons.Name = "WindowButtons"
WindowButtons.Size = UDim2.new(0, 90, 0, 24)
WindowButtons.AnchorPoint = Vector2.new(1, 0)
WindowButtons.Position = UDim2.new(1, -10, 0, 6)
WindowButtons.BackgroundTransparency = 1
WindowButtons.Parent = MainFrame
WindowButtons.ZIndex = 6

-- Dot Creator
local function createDot(color3, offset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.Position = UDim2.new(0, offset, 0, 0)
    btn.BackgroundColor3 = color3
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = WindowButtons
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.ZIndex = 7
    return btn
end

-- Window Dots
local greenBtn = createDot(Color3.fromRGB(39,201,63), 0)
local yellowBtn = createDot(Color3.fromRGB(255,189,46), 22)
local redBtn = createDot(Color3.fromRGB(255,95,86), 44)

-- Left Tabs
local SelectionFrame = Instance.new("Frame")
SelectionFrame.Size = UDim2.new(0, 140, 1, -40)
SelectionFrame.Position = UDim2.new(0, 10, 0, 40)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
SelectionFrame.Parent = MainFrame
SelectionFrame.ZIndex = 3
Instance.new("UICorner", SelectionFrame).CornerRadius = UDim.new(0, 8)

-- Tabs Setup
local Tabs = {"Main", "Stealer", "Esp", "Player", "Logs", "Settings"}
local tabButtons, tabFrames, layoutRefs = {}, {}, {}

for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tabName
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, (i-1)*50)
    btn.BackgroundColor3 = Color3.fromRGB(22, 26, 39)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.Parent = SelectionFrame
    btn.ZIndex = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    tabButtons[tabName] = btn

    local frame = Instance.new("ScrollingFrame")
    frame.Name = tabName .. "Frame"
    frame.Size = UDim2.new(1, -160, 1, -50)
    frame.Position = UDim2.new(0, 150, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(22, 26, 39)
    frame.BorderSizePixel = 0
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.ScrollBarThickness = 6
    frame.Visible = false
    frame.Parent = MainFrame
    frame.ZIndex = 3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    tabFrames[tabName] = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame
    layoutRefs[tabName] = layout

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)
end

local function setActiveTab(name)
    for tn, f in pairs(tabFrames) do
        f.Visible = (tn == name)
    end
    for tn, b in pairs(tabButtons) do
        if tn == name then
            b.BackgroundColor3 = Color3.fromRGB(35, 145, 255)
            b.TextColor3 = Color3.fromRGB(255,255,255)
        else
            b.BackgroundColor3 = Color3.fromRGB(22,26,39)
            b.TextColor3 = Color3.fromRGB(200,200,200)
        end
    end
end

for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)
end
setActiveTab("Main")

-- Toggle Creator
local function createToggle(name, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
    frame.Parent = parent
    frame.ZIndex = 4
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(245, 245, 245)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Parent = frame

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 50, 0, 25)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -12)
    toggleBg.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
    toggleBg.Text = ""
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 12)

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 23, 0, 23)
    toggleCircle.Position = UDim2.new(0, 1, 0, 1)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = toggleBg
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

    local toggled = false
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    toggleBg.MouseButton1Click:Connect(function()
        toggled = not toggled
        local targetPos = toggled and UDim2.new(1, -24, 0, 1) or UDim2.new(0, 1, 0, 1)
        local targetColor = toggled and Color3.fromRGB(0, 205, 102) or Color3.fromRGB(200, 200, 200)

        TweenService:Create(toggleCircle, tweenInfo, {Position = targetPos}):Play()
        TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = targetColor}):Play()

        if callback then
            pcall(callback, toggled)
        end
    end)
end

-- ESP Functions
local function clearESP()
    for _, v in ipairs(espFolder:GetChildren()) do v:Destroy() end
end

local function updateESP()
    clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            if espEnabled then
                local box = Instance.new("BoxHandleAdornment")
                box.Adornee = root
                box.Size = Vector3.new(4,6,2)
                box.Color3 = Color3.fromRGB(0,255,100)
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Transparency = 0.5
                box.Parent = espFolder
            end
            if nameEnabled then
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = root
                billboard.Size = UDim2.new(0,200,0,30)
                billboard.AlwaysOnTop = true
                billboard.Parent = espFolder
                local nameLabel = Instance.new("TextLabel", billboard)
                nameLabel.Size = UDim2.new(1,0,1,0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = p.DisplayName
                nameLabel.TextColor3 = Color3.new(1,1,1)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
            end
        end
    end
end

local brainrotGodESPEnabled = false
local secretESPEnabled = false

-- Updated ESP function to include all types
local function updateESP()
    clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart

            -- Player Box ESP
            if espEnabled then
                local box = Instance.new("BoxHandleAdornment")
                box.Adornee = root
                box.Size = Vector3.new(4,6,2)
                box.Color3 = Color3.fromRGB(0,255,100)
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Transparency = 0.5
                box.Parent = espFolder
            end

            -- Player Name ESP
            if nameEnabled then
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = root
                billboard.Size = UDim2.new(0,200,0,30)
                billboard.StudsOffset = Vector3.new(0,3,0)
                billboard.AlwaysOnTop = true
                billboard.Parent = espFolder
                local nameLabel = Instance.new("TextLabel", billboard)
                nameLabel.Size = UDim2.new(1,0,1,0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = p.DisplayName
                nameLabel.TextColor3 = Color3.new(1,1,1)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
            end

            -- Brainrot God ESP
            if brainrotGodESPEnabled then
                if p:FindFirstChild("BrainrotGod") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = p.BrainrotGod
                    box.Size = Vector3.new(5,5,5)
                    box.Color3 = Color3.fromRGB(128,0,128)
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Transparency = 0.5
                    box.Parent = espFolder
                end
            end

            -- Secret ESP
            if secretESPEnabled then
                if p:FindFirstChild("Secret") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = p.Secret
                    box.Size = Vector3.new(5,5,5)
                    box.Color3 = Color3.fromRGB(0,0,0)
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Transparency = 0.5
                    box.Parent = espFolder
                end
            end
        end
    end
end

-- Webhook Variables
local WebhookUrl = "" -- stores the webhook entered by player
local BrainrotsToTrack = {
    "Extinct Matteo",
    "Los Chicleteiras",
    "Noobini Pizzanini",
    "Tacorita Bicicleta",
    "Quesadilla Crocodila",
    "67",
    "Las Sis",
    "Celularcini Viciosini",
    "La Extinct Grande"
}
local trackedWebhookInstances = {}

-- Webhook GUI Input
local webhookLabel = Instance.new("TextLabel")
webhookLabel.Text = "Webhook URL:"
webhookLabel.Size = UDim2.new(0, 200, 0, 20)
webhookLabel.Position = UDim2.new(0, 10, 0, 10)
webhookLabel.BackgroundTransparency = 1
webhookLabel.TextColor3 = Color3.fromRGB(255,255,255)
webhookLabel.Font = Enum.Font.Gotham
webhookLabel.TextSize = 16
webhookLabel.Parent = tabFrames["Logs"]

local webhookInput = Instance.new("TextBox")
webhookInput.Size = UDim2.new(0, 300, 0, 25)
webhookInput.Position = UDim2.new(0, 10, 0, 35)
webhookInput.PlaceholderText = "Enter your webhook URL here"
webhookInput.Text = ""
webhookInput.ClearTextOnFocus = false
webhookInput.BackgroundColor3 = Color3.fromRGB(40,40,50)
webhookInput.TextColor3 = Color3.fromRGB(255,255,255)
webhookInput.Font = Enum.Font.Gotham
webhookInput.TextSize = 16
webhookInput.Parent = tabFrames["Logs"]
Instance.new("UICorner", webhookInput).CornerRadius = UDim.new(0, 4)

webhookInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        WebhookUrl = webhookInput.Text
        print("Webhook URL set to:", WebhookUrl)
    end
end)

-- Webhook sending function
local function sendWebhook(brainrotName)
    if WebhookUrl == "" then return end
    local success, err = pcall(function()
        game:GetService("HttpService"):PostAsync(
            WebhookUrl,
            game:GetService("HttpService"):JSONEncode({
                username = "NoName Hub Notify",
                embeds = {{
                    title = "Brainrot Spawned!",
                    description = brainrotName .. " has appeared in workspace!",
                    color = 0x00ff00
                }}
            }),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    if not success then
        warn("Failed to send webhook:", err)
    end
end


-- Lock ESP Variables
local lockESPEnabled = false
local lockESPFolder = Instance.new("Folder", Workspace)
lockESPFolder.Name = "LockESPFolder"


-- Lock ESP Update Function
local function updateLockESP()
    if not lockESPEnabled then
        for _, child in ipairs(lockESPFolder:GetChildren()) do
            child:Destroy()
        end
        return
    end

    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        local purchases = plot:FindFirstChild("Purchases", true)
        local plotBlock = purchases and purchases:FindFirstChild("PlotBlock", true)
        local mainBlock = plotBlock and plotBlock:FindFirstChild("Main", true)
        local billboardGui = mainBlock and mainBlock:FindFirstChild("BillboardGui", true)
        local remainingTimeLabel = billboardGui and billboardGui:FindFirstChild("RemainingTime", true)

        if remainingTimeLabel and remainingTimeLabel:IsA("TextLabel") then
            local espName = "LockESP_" .. plot.Name
            local existingBillboard = lockESPFolder:FindFirstChild(espName)

            local isUnlocked = remainingTimeLabel.Text == "0s"
            local displayText = isUnlocked and "Unlocked" or ("Lock: " .. remainingTimeLabel.Text)
            local textColor = isUnlocked and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)

            if not existingBillboard then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = espName
                billboard.Size = UDim2.new(0, 200, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                billboard.Adornee = mainBlock
                billboard.Parent = lockESPFolder

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                label.Text = displayText
                label.TextColor3 = textColor
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                label.TextStrokeTransparency = 0
                label.Parent = billboard
            else
                existingBillboard.TextLabel.Text = displayText
                existingBillboard.TextLabel.TextColor3 = textColor
            end
        end
    end
end

-- Unified RenderStepped loop
RunService.RenderStepped:Connect(function()
    if espEnabled or nameEnabled or brainrotGodESPEnabled or secretESPEnabled then
        updateESP()
    else
        clearESP()
    end

    if lockESPEnabled then
        updateLockESP()
    else
        for _, child in ipairs(lockESPFolder:GetChildren()) do
            child:Destroy()
        end
    end

    -- Existing lock-on player updates
    if lockEnabled and lockTarget and lockTarget.Parent then
        local elapsed = tick() - lockStartTime
        local remaining = math.max(0, lockDuration - elapsed)
        if lockBillboard and lockBillboard.Label then
            lockBillboard.Label.Text = string.format("LOCKED: %s (%.1fs)", lockTarget.DisplayName, remaining)
        end
        if remaining <= 0 then
            if lockBillboard then lockBillboard.Gui:Destroy() end
            lockBillboard = nil
            lockTarget = nil
            lockEnabled = false
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not tabButtons["Logs"] then return end
    for _, name in ipairs(BrainrotsToTrack) do
        local found = workspace:FindFirstChild(name)
        if found then
            -- Only send once per spawn
            if not found:GetAttribute("WebhookSent") then
                sendWebhook(name)
                found:SetAttribute("WebhookSent", true)
            end

            -- Optional: Add a small lock ESP on tracked Brainrots
            if lockESPEnabled and not trackedWebhookInstances[found] then
                local hrp = found:FindFirstChild("HumanoidRootPart") or found.PrimaryPart or found:FindFirstChildWhichIsA("BasePart")
                if hrp then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "WebhookLockESP_" .. name
                    billboard.Size = UDim2.new(0,200,0,50)
                    billboard.StudsOffset = Vector3.new(0,3,0)
                    billboard.Adornee = hrp
                    billboard.AlwaysOnTop = true
                    billboard.Parent = lockESPFolder

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    label.TextColor3 = Color3.fromRGB(255,0,0)
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                    label.Text = "LOCKED: " .. name
                    label.Parent = billboard

                    trackedWebhookInstances[found] = billboard
                end
            end
        end
    end
end)


-- Speed Function
local function enableSpeed()
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local forward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
            local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end

            if move.Magnitude > 0 then
                root.Velocity = move.Unit * 50
            end
        end)
    end)
end

local function disableSpeed()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

-- Placeholder
local function placeholder(name)
    return function(toggled)
        print(name.." toggled:", toggled, "(Feature not implemented)")
    end
end



-- Toggles
createToggle("Walk to Base", tabFrames["Main"], placeholder("Walk to Base"))
createToggle("Auto Lock Base", tabFrames["Esp"], placeholder("Auto Lock Base"))
createToggle("Auto Buy Items", tabFrames["Main"], placeholder("Auto Buy Items"))
createToggle("Auto Collect", tabFrames["Main"], placeholder("Auto Collect"))

createToggle("Player Names", tabFrames["Player"], function(v) nameEnabled = v end)
createToggle("Anti-Ragdoll", tabFrames["Player"], placeholder("Anti-Ragdoll"))
createToggle("Speed Boost", tabFrames["Player"], function(t) if t then enableSpeed() else disableSpeed() end end)
createToggle("Anti-AFK", tabFrames["Player"], placeholder("Anti-AFK"))
createToggle("Anti Invisible", tabFrames["Player"], placeholder("Anti Invisible"))
createToggle("Anti Trap", tabFrames["Player"], placeholder("Anti Trap"))
createToggle("Anti Hit", tabFrames["Player"], placeholder("Anti Attack Effect"))

createToggle("Best Brainrot ESP", tabFrames["Stealer"], placeholder("Best Brainrot ESP"))
createToggle("Auto Buy Brainrots", tabFrames["Stealer"], placeholder("Auto Buy Brainrots"))
createToggle("Auto Spin Wheel", tabFrames["Stealer"], placeholder("Auto Spin Wheel"))

createToggle("Player ESP", tabFrames["Esp"], function(v) espEnabled = v end)
createToggle("Lock ESP", tabFrames["Esp"], function(v)
    lockESPEnabled = v
    if not v then
        for _, child in ipairs(lockESPFolder:GetChildren()) do
            child:Destroy()
        end
    end
end)
createToggle("Brainrot GOD ESP", tabFrames["Esp"], function(v)
    brainrotGodESPEnabled = v
end)

createToggle("Secret ESP", tabFrames["Esp"], function(v)
    secretESPEnabled = v
end)

createToggle("Webhook Sender", tabFrames["Logs"], function(toggled)
    webhookEnabled = toggled
    if toggled then
        print("Webhook Sender Enabled")
    else
        print("Webhook Sender Disabled")
    end
end)

-- Window controls
local normalPos, normalSize = MainFrame.Position, MainFrame.Size
local isExpanded, isMinimized = false, false

greenBtn.MouseButton1Click:Connect(function()
    if isExpanded then
        MainFrame.Position, MainFrame.Size = normalPos, normalSize
        isExpanded = false
    else
        normalPos, normalSize = MainFrame.Position, MainFrame.Size
        MainFrame.Position, MainFrame.Size = UDim2.new(0, 8, 0, 8), UDim2.new(1, -16, 1, -16)
        isExpanded, isMinimized = true, false
    end
end)

yellowBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Position, MainFrame.Size = normalPos, normalSize
        isMinimized = false
    else
        if isExpanded then
            MainFrame.Position, MainFrame.Size = normalPos, normalSize
            isExpanded = false
        end
        normalPos, normalSize = MainFrame.Position, MainFrame.Size
        MainFrame.Size = UDim2.new(normalSize.X.Scale, normalSize.X.Offset, 0, 36)
        isMinimized = true
    end
end)

redBtn.MouseButton1Click:Connect(function()
    pcall(function() ScreenGui:Destroy() end)
end)

-- Lock Closest Player Function
local function lockClosestPlayer()
    local closest, minDist = nil, math.huge
    local camPos = workspace.CurrentCamera.CFrame.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local dist = (root.Position - camPos).Magnitude
            if dist < minDist then
                minDist = dist
                closest = p
            end
        end
    end

    if closest then
        lockEnabled = true
        lockTarget = closest
        lockStartTime = tick()
        if lockBillboard then lockBillboard.Gui:Destroy() end

        local hrp = closest.Character.HumanoidRootPart
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "LockESP"
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.Adornee = hrp
        billboard.AlwaysOnTop = true
        billboard.Parent = espFolder

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(255,0,0)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0,0,0)
        label.Parent = billboard

        lockBillboard = {Gui = billboard, Label = label}
    end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    elseif input.KeyCode == Enum.KeyCode.L then
        lockClosestPlayer()
    end
end)

print("✅ NoName Hub fully loaded with all features")
