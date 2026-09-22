--==================================================
-- BIGBOSS SAE - SMART AUTO STEAL
-- Target Best Egg - Grab - Return Fast and Fair
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    AutoSteal     = false,
    SafeZone      = nil,
    StealRange    = 300,
    StealDelay    = 1.0,
    StealWait     = 0.3,
    ReturnDelay   = 0.4,
    GrabDistance  = 3,
    RandomJitter  = true,
    TargetMode    = "best",
    CustomTargets = {
        "Secret",
        "Eternal",
        "Divine",
        "Cosmic",
    },
}

local RARITY_PRIORITY = {
    "Secret",
    "Eternal",
    "Celestial",
    "Godly",
    "Divine",
    "Cosmic",
    "Mythic",
    "Legendary",
    "Epic",
    "Rare",
    "Uncommon",
    "Common",
}

--==================================================
-- SAVE SAFE ZONE
--==================================================

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

if hrp then
    CONFIG.SafeZone = hrp.CFrame
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "BIGBOSS_SMART_STEAL"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(340, 260)
main.Position = UDim2.new(0.5, -170, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
main.BorderSizePixel = 0
main.Parent = gui

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 10)
c.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "SMART AUTO STEAL"
title.TextColor3 = Color3.fromRGB(255, 166, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = main

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -30, 0, 42)
toggle.Position = UDim2.fromOffset(15, 45)
toggle.BackgroundColor3 = Color3.fromRGB(24, 31, 47)
toggle.Text = "Auto Steal: OFF"
toggle.TextColor3 = Color3.fromRGB(235, 235, 235)
toggle.TextSize = 13
toggle.Font = Enum.Font.GothamBold
toggle.Parent = main

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 7)
tc.Parent = toggle

toggle.MouseButton1Click:Connect(function()
    CONFIG.AutoSteal = not CONFIG.AutoSteal
    toggle.Text = "Auto Steal: " .. (CONFIG.AutoSteal and "ON" or "OFF")
    toggle.TextColor3 = CONFIG.AutoSteal and Color3.fromRGB(60, 200, 110) or Color3.fromRGB(235, 235, 235)
end)

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(1, -30, 0, 42)
modeBtn.Position = UDim2.fromOffset(15, 92)
modeBtn.BackgroundColor3 = Color3.fromRGB(24, 31, 47)
modeBtn.Text = "Target: BEST ONLY"
modeBtn.TextColor3 = Color3.fromRGB(255, 166, 0)
modeBtn.TextSize = 12
modeBtn.Font = Enum.Font.GothamBold
modeBtn.Parent = main

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 7)
mc.Parent = modeBtn

modeBtn.MouseButton1Click:Connect(function()
    if CONFIG.TargetMode == "best" then
        CONFIG.TargetMode = "all"
        modeBtn.Text = "Target: ALL EGGS"
    elseif CONFIG.TargetMode == "all" then
        CONFIG.TargetMode = "custom"
        modeBtn.Text = "Target: CUSTOM LIST"
    else
        CONFIG.TargetMode = "best"
        modeBtn.Text = "Target: BEST ONLY"
    end
end)

local saveZone = Instance.new("TextButton")
saveZone.Size = UDim2.new(1, -30, 0, 40)
saveZone.Position = UDim2.fromOffset(15, 139)
saveZone.BackgroundColor3 = Color3.fromRGB(24, 31, 47)
saveZone.Text = "Save Safe Zone (Current Pos)"
saveZone.TextColor3 = Color3.fromRGB(255, 166, 0)
saveZone.TextSize = 12
saveZone.Font = Enum.Font.GothamBold
saveZone.Parent = main

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 7)
sc.Parent = saveZone

saveZone.MouseButton1Click:Connect(function()
    local currentChar = player.Character
    if currentChar then
        local root = currentChar:FindFirstChild("HumanoidRootPart")
        if root then
            CONFIG.SafeZone = root.CFrame
            saveZone.Text = "Safe Zone Saved!"
            task.wait(1.5)
            saveZone.Text = "Save Safe Zone (Current Pos)"
        end
    end
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 60)
status.Position = UDim2.fromOffset(15, 185)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(130, 140, 155)
status.TextSize = 11
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.TextWrapped = true
status.Parent = main

--==================================================
-- HELPERS
--==================================================

local function randomBetween(min, max)
    return min + math.random() * (max - min)
end

local function isCustomTarget(name)
    local lower = name:lower()
    for _, target in ipairs(CONFIG.CustomTargets) do
        if lower:find(target:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function getEggScore(part)
    local name = part.Name:lower()

    if CONFIG.TargetMode == "all" then
        return 1
    end

    if CONFIG.TargetMode == "custom" then
        if isCustomTarget(name) then
            for i, t in ipairs(CONFIG.CustomTargets) do
                if name:find(t:lower(), 1, true) then
                    return 1000 - i
                end
            end
        end
        return 0
    end

    for i, rarity in ipairs(RARITY_PRIORITY) do
        if name:find(rarity:lower(), 1, true) then
            return 1000 - i
        end
    end

    return 0
end

local function findBestEgg(root)
    local best, bestScore, bestDist = nil, 0, CONFIG.StealRange

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            local score = getEggScore(obj)
            if score > 0 then
                local d = (obj.Position - root.Position).Magnitude
                if d < CONFIG.StealRange then
                    if score > bestScore or (score == bestScore and d < bestDist) then
                        best, bestScore, bestDist = obj, score, d
                    end
                end
            end
        end
    end

    return best
end

--==================================================
-- SMART STEAL LOOP
--==================================================

task.spawn(function()
    while task.wait(CONFIG.StealDelay) do
        if not CONFIG.AutoSteal then
            status.Text = "Status: Idle"
            continue
        end
        if not CONFIG.SafeZone then
            status.Text = "Status: No safe zone saved"
            continue
        end

        local currentChar = player.Character
        if not currentChar then continue end

        local root = currentChar:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local egg = findBestEgg(root)

        if not egg then
            status.Text = "Status: No target eggs in range"
            continue
        end

        status.Text = "Status: Stealing " .. egg.Name

        root.CFrame = CFrame.new(egg.Position + Vector3.new(0, CONFIG.GrabDistance, 0))

        task.wait(CONFIG.StealWait + (CONFIG.RandomJitter and randomBetween(0, 0.15) or 0))

        root.CFrame = CONFIG.SafeZone

        status.Text = "Status: Returned to base"

        task.wait(CONFIG.ReturnDelay + (CONFIG.RandomJitter and randomBetween(0, 0.3) or 0))
    end
end)

--==================================================
-- RE-ATTACH ON RESPAWN
--==================================================

player.CharacterAdded:Connect(function(newChar)
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

print("[BIGBOSS SAE] Smart Auto Steal loaded.")
