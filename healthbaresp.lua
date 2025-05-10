-- Настройки
local settings = {
    maxDistance = 999999, -- Максимальная дистанция отрисовки
    updateInterval = 0.1, -- Интервал обновления в секундах
    healthBarHeight = 0.3, -- Высота полоски здоровья
    healthBarWidth = 3, -- Ширина полоски здоровья
    healthBarOffset = Vector3.new(0, 3, 0), -- Смещение полоски здоровья над головой
    barHeightAdjustment = 3, -- Высота над головой персонажа (в studs)
    showTeamHealth = false, -- Показывать здоровье членов своей команды
    teamColor = Color3.fromRGB(0, 250, 0), -- Цвет для своей команды
    enemyColor = Color3.fromRGB(0, 250, 0), -- Цвет для врагов
    backgroundColor = Color3.fromRGB(50, 50, 50), -- Цвет фона полоски здоровья
    textColor = Color3.fromRGB(0, 0, 0), -- Цвет текста
    textSize = 15, -- Размер текста
    textOffset = Vector3.new(0, 1.5, 0) -- Смещение текста относительно полоски здоровья
}

-- Локальные переменные
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local billboards = {} -- Таблица для хранения BillboardGui

-- Функция для создания полоски здоровья
local function createHealthBar(humanoid)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Size = UDim2.new(settings.healthBarWidth, 0, settings.healthBarHeight, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = settings.maxDistance
    billboard.ExtentsOffset = Vector3.new(0, settings.barHeightAdjustment, 0) -- Регулировка высоты
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = settings.backgroundColor
    background.BorderSizePixel = 0
    background.ZIndex = 1
    background.Parent = billboard
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "Health"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = settings.enemyColor
    healthBar.BorderSizePixel = 0
    healthBar.ZIndex = 2
    healthBar.Parent = billboard
    
    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(2, 0, 1, 0)
    healthText.Position = UDim2.new(-0.5, 0, -1, 0)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = settings.textColor
    healthText.TextSize = settings.textSize
    healthText.Font = Enum.Font.SourceSansBold
    healthText.Text = "100/100"
    healthText.ZIndex = 3
    healthText.Parent = billboard
    
    -- Прикрепляем к HumanoidRootPart или Head
    local attachTo = humanoid.Parent:FindFirstChild("HumanoidRootPart") or humanoid.Parent:FindFirstChild("Head") or humanoid.Parent:WaitForChild("Head")
    billboard.Parent = attachTo
    
    return billboard
end

-- Функция обновления полоски здоровья
local function updateHealthBar(billboard, humanoid)
    if not billboard or not billboard:FindFirstChild("Health") or not humanoid then return end
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local healthBar = billboard.Health
    healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
    
    -- Обновление цвета в зависимости от команды (если нужно)
    if settings.showTeamHealth then
        local character = humanoid.Parent
        local player = players:GetPlayerFromCharacter(character)
        
        if player and player.Team == localPlayer.Team then
            healthBar.BackgroundColor3 = settings.teamColor
        else
            healthBar.BackgroundColor3 = settings.enemyColor
        end
    end
    
    -- Обновление текста
    local healthText = billboard.HealthText
    healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
end

-- Основная функция
local function main()
    -- Обработка уже существующих персонажей
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                billboards[humanoid] = createHealthBar(humanoid)
            end
        end
    end
    
    -- Обработка новых игроков
    players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            billboards[humanoid] = createHealthBar(humanoid)
        end)
    end)
    
    -- Обновление полосок здоровья
    runService.Heartbeat:Connect(function()
        for humanoid, billboard in pairs(billboards) do
            if humanoid and humanoid.Parent and billboard then
                updateHealthBar(billboard, humanoid)
            else
                if billboard then billboard:Destroy() end
                billboards[humanoid] = nil
            end
        end
    end)
end

-- Запуск скрипта
main()
