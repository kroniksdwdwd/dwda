-- Name ESP Script for Roblox (Single Player)
-- Features:
-- - Player name display through walls
-- - Customizable height, color, transparency
-- - Toggle on/off
-- - Team color support

-- CONFIGURATION SECTION --
local config = {
    enabled = true,              -- Enable/disable ESP
    textSize = 16,                -- Text size
    textHeight = 4,              -- Height above player's head
    textColor = Color3.new(1, 1, 1), -- Default text color (white)
    teamColor = true,            -- Use team color if available
    outlineColor = Color3.new(0, 0, 0), -- Text outline color
    transparency = 0,            -- Text transparency (0-1)
    maxDistance = 500,           -- Max distance to show ESP
    refreshRate = 0.1            -- Update rate in seconds
}

-- SCRIPT SECTION --
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")

local function createESP(player)
    if player == localPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Create BillboardGui for ESP
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_ESP"
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, config.textHeight, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = config.maxDistance
    billboard.Enabled = config.enabled
    billboard.Parent = character
    
    -- Create text label
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "NameLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = false
    textLabel.TextSize = config.textSize
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextColor3 = config.textColor
    textLabel.TextStrokeColor3 = config.outlineColor
    textLabel.TextStrokeTransparency = config.transparency
    textLabel.Text = player.Name
    textLabel.Parent = billboard
    
    -- Update function
    local function updateESP()
        if not character or not humanoidRootPart or not billboard or not textLabel then
            return
        end
        
        -- Set team color if enabled
        if config.teamColor and player.Team then
            textLabel.TextColor3 = player.TeamColor.Color
        else
            textLabel.TextColor3 = config.textColor
        end
        
        -- Check distance
        local distance = (humanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
        billboard.Enabled = config.enabled and distance <= config.maxDistance
    end
    
    -- Connect update function to heartbeat
    local connection
    connection = runService.Heartbeat:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
            return
        end
        updateESP()
    end)
    
    -- Clean up when character is removed
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if billboard then billboard:Destroy() end
            if connection then connection:Disconnect() end
        end
    end)
end

-- Initialize ESP for existing players
for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
        coroutine.wrap(function()
            createESP(player)
        end)()
    end
end

-- Connect for new players
players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function(character)
            createESP(player)
        end)
    end
end)

