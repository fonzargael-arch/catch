--[[
    🦁 CATCH AND TAME - ULTIMATE SCRIPT
    ═══════════════════════════════════════
    ✨ Insta Catch con cualquier lasso
    💰 Dinero infinito (se regresa al comprar)
    👁️ ESP de pets en tiempo real
    📍 Lista de pets actuales con TP
    ⏱️ Timer de desaparición de pets
    
    Created by: Krxtopher (Fixed & Completed)
]]

print("═══════════════════════════════════")
print("🦁 Loading Catch And Tame Script...")
print("═══════════════════════════════════")

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
    wait(0.5)
    char = c
    root = char:WaitForChild("HumanoidRootPart")
end)

--// Config
local config = {
    InstaCatch = false,
    InfiniteMoney = false,
    ESPEnabled = false,
    AutoTPToPets = false,
    ESPDistance = 500
}

--// Pets detectadas
local activePets = {}
local petTimers = {}

--// Rareza de pets (puedes añadir más según el juego)
local petRarity = {
    -- Legendarios (Rojo)
    ["Dragon"] = {color = Color3.fromRGB(255, 0, 0), rarity = "Legendario"},
    ["Phoenix"] = {color = Color3.fromRGB(255, 100, 0), rarity = "Legendario"},
    ["Unicorn"] = {color = Color3.fromRGB(255, 0, 255), rarity = "Legendario"},
    ["Hipopótamo"] = {color = Color3.fromRGB(255, 0, 255), rarity = "Épico"},
    
    -- Épicos (Morado)
    ["Tiger"] = {color = Color3.fromRGB(150, 0, 255), rarity = "Épico"},
    ["Lion"] = {color = Color3.fromRGB(180, 0, 200), rarity = "Épico"},
    ["Bear"] = {color = Color3.fromRGB(100, 50, 150), rarity = "Épico"},
    
    -- Raros (Azul)
    ["Elephant"] = {color = Color3.fromRGB(0, 100, 255), rarity = "Raro"},
    ["Giraffe"] = {color = Color3.fromRGB(0, 150, 255), rarity = "Raro"},
    
    -- Comunes (Verde)
    ["Rabbit"] = {color = Color3.fromRGB(0, 255, 0), rarity = "Común"},
    ["Sheep"] = {color = Color3.fromRGB(100, 255, 100), rarity = "Común"}
}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CatchTameGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999999
gui.Parent = player:WaitForChild("PlayerGui")

-- Icono minimizado
local miniIcon = Instance.new("TextButton")
miniIcon.Size = UDim2.new(0, 50, 0, 50)
miniIcon.Position = UDim2.new(0, 10, 0.5, -25)
miniIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
miniIcon.Text = "🦁"
miniIcon.TextSize = 28
miniIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
miniIcon.Visible = false
miniIcon.Parent = gui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniIcon

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(255, 165, 0)
miniStroke.Thickness = 2
miniStroke.Parent = miniIcon

-- Panel principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 550)
frame.Position = UDim2.new(0.5, -175, 0.5, -275)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameBorder = Instance.new("UIStroke")
frameBorder.Color = Color3.fromRGB(255, 165, 0)
frameBorder.Thickness = 2
frameBorder.Parent = frame

-- TopBar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topFix.BorderSizePixel = 0
topFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 35, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Catch & Tame"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = topBar

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.Position = UDim2.new(0, 3, 0.5, -15)
icon.BackgroundTransparency = 1
icon.Text = "🦁"
icon.TextSize = 20
icon.Parent = topBar

-- Botón minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -52, 0.5, -12.5)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -25, 0.5, -12.5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = topBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

-- Funciones minimizar/maximizar
local function minimize()
    frame.Visible = false
    miniIcon.Visible = true
end

local function maximize()
    frame.Visible = true
    miniIcon.Visible = false
end

minimizeBtn.MouseButton1Click:Connect(minimize)
miniIcon.MouseButton1Click:Connect(maximize)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Hacer draggable el GUI
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -16, 1, -42)
content.Position = UDim2.new(0, 8, 0, 38)
content.BackgroundTransparency = 1
content.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = content

-- Stats
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, 0, 0, 45)
statsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statsFrame.BorderSizePixel = 0
statsFrame.Parent = content

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsFrame

local petsLabel = Instance.new("TextLabel")
petsLabel.Size = UDim2.new(1, -8, 0, 20)
petsLabel.Position = UDim2.new(0, 4, 0, 3)
petsLabel.BackgroundTransparency = 1
petsLabel.Text = "🦁 Active Pets: 0"
petsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
petsLabel.Font = Enum.Font.GothamBold
petsLabel.TextSize = 12
petsLabel.TextXAlignment = Enum.TextXAlignment.Left
petsLabel.Parent = statsFrame

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -8, 0, 18)
moneyLabel.Position = UDim2.new(0, 4, 0, 23)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "💰 Infinite Money: OFF"
moneyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
moneyLabel.Font = Enum.Font.Gotham
moneyLabel.TextSize = 11
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = statsFrame

-- Toggles
local function createToggle(parent, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 165, 0)
    stroke.Thickness = 1
    stroke.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 38, 0, 22)
    toggle.Position = UDim2.new(1, -43, 0.5, -11)
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggle.Text = ""
    toggle.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 3, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        game:GetService("TweenService"):Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(30, 30, 30)
        }):Play()
        game:GetService("TweenService"):Create(indicator, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
        }):Play()
        if callback then callback(enabled) end
    end)
end

createToggle(content, "⚡ Insta Catch", function(enabled)
    config.InstaCatch = enabled
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🦁 Insta Catch",
        Text = enabled and "Activado" or "Desactivado",
        Duration = 2
    })
end)

createToggle(content, "💰 Infinite Money", function(enabled)
    config.InfiniteMoney = enabled
    moneyLabel.Text = "💰 Infinite Money: " .. (enabled and "ON" or "OFF")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "💰 Infinite Money",
        Text = enabled and "Activado" or "Desactivado",
        Duration = 2
    })
end)

createToggle(content, "👁️ ESP Pets", function(enabled)
    config.ESPEnabled = enabled
    if not enabled then
        for _, esp in pairs(workspace:GetDescendants()) do
            if esp.Name == "DragonESP" then
                esp:Destroy()
            end
        end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "👁️ ESP",
        Text = enabled and "Activado" or "Desactivado",
        Duration = 2
    })
end)

-- Lista de Pets Activas
local petListSection = Instance.new("Frame")
petListSection.Size = UDim2.new(1, 0, 0, 25)
petListSection.BackgroundTransparency = 1
petListSection.Parent = content

local petListTitle = Instance.new("TextLabel")
petListTitle.Size = UDim2.new(1, 0, 1, 0)
petListTitle.BackgroundTransparency = 1
petListTitle.Text = "📋 Active Pets (Click to TP)"
petListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
petListTitle.Font = Enum.Font.GothamBold
petListTitle.TextSize = 13
petListTitle.TextXAlignment = Enum.TextXAlignment.Left
petListTitle.Parent = petListSection

local petListLine = Instance.new("Frame")
petListLine.Size = UDim2.new(1, 0, 0, 2)
petListLine.Position = UDim2.new(0, 0, 1, -2)
petListLine.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
petListLine.BorderSizePixel = 0
petListLine.Parent = petListSection

-- Contenedor de lista con scroll
local petListContainer = Instance.new("Frame")
petListContainer.Size = UDim2.new(1, 0, 0, 200)
petListContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
petListContainer.BorderSizePixel = 0
petListContainer.Parent = content

local petListCorner = Instance.new("UICorner")
petListCorner.CornerRadius = UDim.new(0, 8)
petListCorner.Parent = petListContainer

local petListStroke = Instance.new("UIStroke")
petListStroke.Color = Color3.fromRGB(255, 165, 0)
petListStroke.Thickness = 1
petListStroke.Parent = petListContainer

local petScroll = Instance.new("ScrollingFrame")
petScroll.Size = UDim2.new(1, -8, 1, -8)
petScroll.Position = UDim2.new(0, 4, 0, 4)
petScroll.BackgroundTransparency = 1
petScroll.BorderSizePixel = 0
petScroll.ScrollBarThickness = 5
petScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 165, 0)
petScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
petScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
petScroll.Parent = petListContainer

local petListLayout = Instance.new("UIListLayout")
petListLayout.Padding = UDim.new(0, 4)
petListLayout.Parent = petScroll

-- Función para crear item de pet en la lista
local function createPetListItem(pet, petModel)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, -8, 0, 45)
    item.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    item.Text = ""
    item.AutoButtonColor = false
    item.Parent = petScroll
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = item
    
    local rarityInfo = petRarity[pet.name] or {color = Color3.fromRGB(100, 100, 100), rarity = "Desconocido"}
    
    local itemStroke = Instance.new("UIStroke")
    itemStroke.Color = rarityInfo.color
    itemStroke.Thickness = 2
    itemStroke.Parent = item
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 18)
    nameLabel.Position = UDim2.new(0, 5, 0, 3)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "🦁 " .. pet.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = item
    
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Size = UDim2.new(0.5, -5, 0, 13)
    rarityLabel.Position = UDim2.new(0, 5, 0, 22)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = "⭐ " .. rarityInfo.rarity
    rarityLabel.TextColor3 = rarityInfo.color
    rarityLabel.Font = Enum.Font.Gotham
    rarityLabel.TextSize = 10
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = item
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0.5, -5, 0, 13)
    distLabel.Position = UDim2.new(0.5, 0, 0, 22)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "📏 " .. math.floor(pet.distance) .. " studs"
    distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 10
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = item
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, -10, 0, 10)
    timerLabel.Position = UDim2.new(0, 5, 1, -13)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "⏱️ 30s"
    timerLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextSize = 9
    timerLabel.TextXAlignment = Enum.TextXAlignment.Right
    timerLabel.Parent = item
    
    item.MouseButton1Click:Connect(function()
        if petModel and petModel.Parent and root then
            local petPos = petModel:IsA("Model") and petModel.PrimaryPart and petModel.PrimaryPart.Position or petModel.Position
            root.CFrame = CFrame.new(petPos + Vector3.new(0, 5, 0))
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "📍 Teleport",
                Text = "Teleportado a " .. pet.name,
                Duration = 2
            })
        end
    end)
    
    item.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(item, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        }):Play()
    end)
    
    item.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(item, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        }):Play()
    end)
    
    return item, timerLabel
end

-- Función para actualizar la lista de pets
local function updatePetList()
    for _, child in pairs(petScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if not petScroll:FindFirstChildOfClass("UIListLayout") then
        petListLayout = Instance.new("UIListLayout")
        petListLayout.Padding = UDim.new(0, 4)
        petListLayout.Parent = petScroll
    end
    
    local sortedPets = {}
    for id, pet in pairs(activePets) do
        table.insert(sortedPets, pet)
    end
    
    table.sort(sortedPets, function(a, b)
        return a.distance < b.distance
    end)
    
    for _, pet in pairs(sortedPets) do
        local item, timerLabel = createPetListItem(pet, pet.model)
        
        task.spawn(function()
            local timeLeft = petTimers[pet.id] or 30
            while item and item.Parent and timeLeft > 0 do
                wait(1)
                timeLeft = timeLeft - 1
                petTimers[pet.id] = timeLeft
                
                if timerLabel and timerLabel.Parent then
                    timerLabel.Text = "⏱️ " .. timeLeft .. "s"
                    
                    if timeLeft <= 10 then
                        timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    elseif timeLeft <= 20 then
                        timerLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    end
                end
            end
            
            if item and item.Parent then
                item:Destroy()
            end
        end)
    end
    
    petsLabel.Text = "🦁 Active Pets: " .. #sortedPets
end

-- Detectar pets en el juego
local function detectPets()
    local pets = {}
    
    local possibleLocations = {
        Workspace:FindFirstChild("Animals"),
        Workspace:FindFirstChild("Pets"),
        Workspace:FindFirstChild("Spawns"),
        Workspace
    }
    
    for _, location in pairs(possibleLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local isPet = obj:FindFirstChild("Animal") or 
                                 obj:FindFirstChild("Pet") or
                                 obj:FindFirstChild("Health") or
                                 string.find(obj.Name:lower(), "animal") or
                                 string.find(obj.Name:lower(), "pet")
                    
                    if isPet then
                        local petPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
                        
                        if petPart and petPart:IsA("BasePart") and root then
                            local distance = (petPart.Position - root.Position).Magnitude
                            
                            if distance <= config.ESPDistance then
                                local petId = tostring(obj)
                                pets[petId] = {
                                    id = petId,
                                    name = obj.Name,
                                    model = obj,
                                    part = petPart,
                                    distance = distance
                                }
                                
                                if not petTimers[petId] then
                                    petTimers[petId] = 30
                                end
                                
                                if config.ESPEnabled and not petPart:FindFirstChild("DragonESP") then
                                    local rarityInfo = petRarity[obj.Name] or {color = Color3.fromRGB(100, 100, 100), rarity = "Desconocido"}
                                    
                                    local billboard = Instance.new("BillboardGui")
                                    billboard.Name = "DragonESP"
                                    billboard.Adornee = petPart
                                    billboard.Size = UDim2.new(0, 100, 0, 60)
                                    billboard.AlwaysOnTop = true
                                    billboard.Parent = petPart
                                    
                                    local nameLabel = Instance.new("TextLabel")
                                    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                    nameLabel.BackgroundTransparency = 1
                                    nameLabel.Text = obj.Name
                                    nameLabel.TextColor3 = rarityInfo.color
                                    nameLabel.TextStrokeTransparency = 0
                                    nameLabel.Font = Enum.Font.GothamBold
                                    nameLabel.TextScaled = true
                                    nameLabel.Parent = billboard
                                    
                                    local distLabel = Instance.new("TextLabel")
                                    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                                    distLabel.BackgroundTransparency = 1
                                    distLabel.Text = math.floor(distance) .. " studs"
                                    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    distLabel.TextStrokeTransparency = 0
                                    distLabel.Font = Enum.Font.Gotham
                                    distLabel.TextScaled = true
                                    distLabel.Parent = billboard
                                    
                                    task.spawn(function()
                                        while billboard.Parent and root do
                                            wait(0.5)
