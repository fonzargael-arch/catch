--[[
    ═══════════════════════════════════════
    🦁 CATCH & TAME HUB v3.0 - FIXED ESP
    ═══════════════════════════════════════
    Created by: Gael Fonzar
    RAREZA REAL DETECTADA + CHRISTMAS ESP
    ═══════════════════════════════════════
]]

-- Load Fluent Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Remotes
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local KnitServices = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services

-- Variables
local instaCatchEnabled = false
local autoTPEnabled = false
local espEnabled = false
local christmasESPEnabled = false
local espRarity = "All"
local speedBoostEnabled = false
local autoCollectCash = false
local autoBreed = false
local autoFeedPets = false

local walkSpeed = 16
local connections = {}
local espObjects = {}
local christmasESPObjects = {}
local catchingPet = false

-- Rareza Colors
local rarityColors = {
    ["Legendary"] = Color3.fromRGB(255, 215, 0), -- Gold
    ["Mythic"] = Color3.fromRGB(255, 0, 255), -- Magenta
    ["Epic"] = Color3.fromRGB(138, 43, 226), -- Purple
    ["Rare"] = Color3.fromRGB(0, 112, 255), -- Blue
    ["Uncommon"] = Color3.fromRGB(0, 255, 0), -- Green
    ["Common"] = Color3.fromRGB(255, 255, 255), -- White
    ["Christmas"] = Color3.fromRGB(255, 0, 0) -- Red
}

-- ═══════════════════════════════════════
-- 🔍 DETECTAR RAREZA REAL
-- ═══════════════════════════════════════

local function getPetRarityReal(petModel)
    -- Método 1: Buscar en StringValue o IntValue
    for _, child in pairs(petModel:GetDescendants()) do
        if child:IsA("StringValue") and (child.Name == "Rarity" or child.Name == "rarity" or child.Name == "Tier") then
            return child.Value
        end
        if child:IsA("IntValue") and (child.Name == "Rarity" or child.Name == "RarityTier") then
            local tierMap = {
                [1] = "Common",
                [2] = "Uncommon", 
                [3] = "Rare",
                [4] = "Epic",
                [5] = "Mythic",
                [6] = "Legendary"
            }
            return tierMap[child.Value] or "Common"
        end
    end
    
    -- Método 2: Buscar en Configuration
    local config = petModel:FindFirstChild("Configuration") or petModel:FindFirstChild("Config")
    if config then
        for _, child in pairs(config:GetChildren()) do
            if child.Name:lower():find("rarity") or child.Name:lower():find("tier") then
                if child:IsA("StringValue") then
                    return child.Value
                elseif child:IsA("IntValue") then
                    local tierMap = {[1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Mythic", [6] = "Legendary"}
                    return tierMap[child.Value] or "Common"
                end
            end
        end
    end
    
    -- Método 3: Pedir al servidor
    local success, result = pcall(function()
        return Remotes.getPetRev:InvokeServer(petModel.Name)
    end)
    
    if success and result and result.Rarity then
        return result.Rarity
    end
    
    -- Método 4: Buscar en el nombre
    local name = petModel.Name:lower()
    if name:find("legendary") or name:find("legend") then return "Legendary" end
    if name:find("mythic") or name:find("myth") then return "Mythic" end
    if name:find("epic") then return "Epic" end
    if name:find("rare") then return "Rare" end
    if name:find("uncommon") then return "Uncommon" end
    if name:find("christmas") or name:find("xmas") or name:find("festive") or name:find("holiday") then return "Christmas" end
    
    return "Common"
end

local function getRoamingPets()
    local pets = {}
    local roamingFolder = Workspace:FindFirstChild("RoamingPets")
    
    if roamingFolder then
        local petsFolder = roamingFolder:FindFirstChild("Pets")
        if petsFolder then
            for _, pet in pairs(petsFolder:GetChildren()) do
                if pet:IsA("Model") and pet:FindFirstChild("HumanoidRootPart") then
                    local rarity = getPetRarityReal(pet)
                    table.insert(pets, {
                        model = pet,
                        name = pet.Name,
                        rarity = rarity,
                        position = pet.HumanoidRootPart.Position
                    })
                end
            end
        end
    end
    
    return pets
end

local function getChristmasPets()
    local xmasPets = {}
    
    -- Buscar en Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("XMas") or obj.Name:find("Christmas") or obj.Name:find("Festive") then
            if obj:FindFirstChild("HumanoidRootPart") then
                table.insert(xmasPets, {
                    model = obj,
                    name = obj.Name,
                    position = obj.HumanoidRootPart.Position
                })
            end
        end
    end
    
    return xmasPets
end

local function getClosestPet(rarityFilter)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local closestPet = nil
    local closestDist = math.huge
    
    for _, petData in pairs(getRoamingPets()) do
        if rarityFilter == "All" or petData.rarity == rarityFilter then
            local dist = (myPos - petData.position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPet = petData
            end
        end
    end
    
    return closestPet, closestDist
end

-- ═══════════════════════════════════════
-- 💰 MONEY FUNCTIONS
-- ═══════════════════════════════════════

local function collectAllCash()
    pcall(function()
        Remotes.collectAllPetCash:FireServer()
    end)
end

local function claimOfflineCash()
    pcall(function()
        local offlineTime = Remotes.getOfflineTime:InvokeServer()
        if offlineTime then
            local cash = Remotes.getOfflineCash:InvokeServer()
            Fluent:Notify({
                Title = "💰 Offline Cash",
                Content = string.format("Claimed $%s!", tostring(cash)),
                Duration = 3
            })
        end
    end)
end

local function startAutoCollect()
    if connections.AutoCollect then
        connections.AutoCollect:Disconnect()
    end
    
    connections.AutoCollect = RunService.Heartbeat:Connect(function()
        if not autoCollectCash then
            if connections.AutoCollect then
                connections.AutoCollect:Disconnect()
                connections.AutoCollect = nil
            end
            return
        end
        
        collectAllCash()
        task.wait(3)
    end)
end

-- ═══════════════════════════════════════
-- 🥚 BREEDING & FEEDING EXPLOITS
-- ═══════════════════════════════════════

local function startAutoBreed()
    while autoBreed do
        pcall(function()
            local pets = Remotes.getPetInventory:InvokeServer()
            if pets and #pets >= 2 then
                -- Intentar criar los primeros 2 pets
                Remotes.breedRequest:InvokeServer(pets[1].id, pets[2].id)
            end
        end)
        task.wait(10)
    end
end

local function startAutoFeed()
    while autoFeedPets do
        pcall(function()
            local pets = Remotes.getPetInventory:InvokeServer()
            if pets then
                for _, pet in pairs(pets) do
                    local FoodService = KnitServices.FoodService
                    FoodService.RF.FeedPet:InvokeServer(pet.id, "Apple")
                    task.wait(0.5)
                end
            end
        end)
        task.wait(30)
    end
end

-- ═══════════════════════════════════════
-- 🎄 CHRISTMAS EVENT EXPLOITS
-- ═══════════════════════════════════════

local function claimFreeEgg()
    pcall(function()
        Remotes.ClaimFeepEgg:FireServer()
        Fluent:Notify({
            Title = "🎁 Free Egg Claimed!",
            Content = "Huevo gratis del evento!",
            Duration = 2
        })
    end)
end

local function autoClaimFreeEggs()
    for i = 1, 5 do
        claimFreeEgg()
        task.wait(1)
    end
end

local function useCandySpin()
    pcall(function()
        local FreeSpinsService = KnitServices.FreeSpinsService
        FreeSpinsService.RE.UseSpin:FireServer()
    end)
end

local function autoSpinCandy(times)
    for i = 1, times do
        useCandySpin()
        task.wait(0.5)
    end
    Fluent:Notify({
        Title = "🍬 Candy Spins!",
        Content = times .. " spins usados!",
        Duration = 2
    })
end

local function buyAllChristmasLassos()
    local lassos = {"ChristmasLasso", "Frost Lasso", "Peppermint Lasso", "Festive Lasso", "Holiday Lasso"}
    
    for _, lasso in pairs(lassos) do
        pcall(function()
            local LassoService = KnitServices.LassoService
            LassoService.RE.BuyLasso:FireServer(lasso)
            task.wait(0.5)
        end)
    end
    
    Fluent:Notify({
        Title = "🎄 Christmas Lassos!",
        Content = "Todos los lassos navideños comprados!",
        Duration = 3
    })
end

local function infiniteCandy()
    -- Exploit: Duplicar candy temporal
    pcall(function()
        local FreeSpinsService = KnitServices.FreeSpinsService
        for i = 1, 10 do
            FreeSpinsService.RE.ReplicateCandyTempPass:FireServer(true)
            task.wait(0.1)
        end
        Fluent:Notify({
            Title = "🍬 Infinite Candy!",
            Content = "Candy pass replicado!",
            Duration = 2
        })
    end)
end

-- ═══════════════════════════════════════
-- ⚡ SUPER LUCK EXPLOIT
-- ═══════════════════════════════════════

local function activateSuperLuck()
    pcall(function()
        Remotes.superLuckSpins:FireServer(100)
        local ServerLuckService = KnitServices.ServerLuckService
        ServerLuckService.RE.spawnLuckTierChanged:FireServer(10) -- Max tier
        
        Fluent:Notify({
            Title = "✨ Super Luck!",
            Content = "Luck al máximo activada!",
            Duration = 3
        })
    end)
end

local function autoClickerBypass()
    pcall(function()
        Remotes.autoClickerState:InvokeServer(true)
        Fluent:Notify({
            Title = "🖱️ Auto-Clicker!",
            Content = "Auto-clicker activado!",
            Duration = 2
        })
    end)
end

-- ═══════════════════════════════════════
-- 🎯 INSTA-CATCH
-- ═══════════════════════════════════════

local function instaCatch(petModel)
    if catchingPet or not petModel then return end
    catchingPet = true
    
    pcall(function()
        Remotes.minigameRequest:InvokeServer(petModel)
        task.wait(0.1)
        Remotes.UpdateProgress:FireServer(100)
        task.wait(0.1)
        Remotes.UpdateIndex:FireServer(petModel)
        
        Fluent:Notify({
            Title = "✅ Captured!",
            Content = petModel.Name .. " capturado!",
            Duration = 2
        })
    end)
    
    task.wait(1)
    catchingPet = false
end

local function startAutoTPCatch(rarityFilter)
    while autoTPEnabled do
        local petData, dist = getClosestPet(rarityFilter)
        
        if petData and dist then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(petData.position + Vector3.new(0, 5, 0))
                task.wait(0.3)
                
                if instaCatchEnabled then
                    instaCatch(petData.model)
                    task.wait(2)
                else
                    task.wait(1)
                end
            end
        else
            task.wait(1)
        end
    end
end

-- ═══════════════════════════════════════
-- 👁️ ESP SYSTEM (FIXED)
-- ═══════════════════════════════════════

local function createESP(petData)
    if espObjects[petData.model] then return end
    
    if espRarity ~= "All" and petData.rarity ~= espRarity then
        return
    end
    
    pcall(function()
        local pet = petData.model
        local petRoot = pet:FindFirstChild("HumanoidRootPart")
        if not petRoot then return end
        
        local color = rarityColors[petData.rarity] or Color3.fromRGB(255, 255, 255)
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "GF_ESP"
        highlight.Adornee = pet
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = pet
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "GF_ESP_Label"
        billboard.Adornee = petRoot
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = petRoot
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = petData.name
        nameLabel.TextColor3 = color
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = billboard
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, 0, 0.3, 0)
        rarityLabel.Position = UDim2.new(0, 0, 0.4, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = "⭐ " .. petData.rarity
        rarityLabel.TextColor3 = color
        rarityLabel.TextStrokeTransparency = 0.5
        rarityLabel.Font = Enum.Font.Gotham
        rarityLabel.TextSize = 12
        rarityLabel.Parent = billboard
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distLabel.Position = UDim2.new(0, 0, 0.7, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0 studs"
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        distLabel.TextStrokeTransparency = 0.5
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 10
        distLabel.Parent = billboard
        
        espObjects[pet] = {
            highlight = highlight,
            billboard = billboard,
            distLabel = distLabel
        }
    end)
end

local function createChristmasESP(xmasPet)
    if christmasESPObjects[xmasPet.model] then return end
    
    pcall(function()
        local pet = xmasPet.model
        local petRoot = pet:FindFirstChild("HumanoidRootPart")
        if not petRoot then return end
        
        local color = Color3.fromRGB(255, 0, 0)
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "GF_XMAS_ESP"
        highlight.Adornee = pet
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = pet
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "GF_XMAS_Label"
        billboard.Adornee = petRoot
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = petRoot
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🎄 " .. xmasPet.name
        label.TextColor3 = color
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = billboard
        
        christmasESPObjects[pet] = {highlight = highlight, billboard = billboard}
    end)
end

local function removeESP(pet)
    if espObjects[pet] then
        pcall(function()
            if espObjects[pet].highlight then espObjects[pet].highlight:Destroy() end
            if espObjects[pet].billboard then espObjects[pet].billboard:Destroy() end
        end)
        espObjects[pet] = nil
    end
end

local function removeChristmasESP(pet)
    if christmasESPObjects[pet] then
        pcall(function()
            if christmasESPObjects[pet].highlight then christmasESPObjects[pet].highlight:Destroy() end
            if christmasESPObjects[pet].billboard then christmasESPObjects[pet].billboard:Destroy() end
        end)
        christmasESPObjects[pet] = nil
    end
end

local function updateESP()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos = char.HumanoidRootPart.Position
    
    local pets = getRoamingPets()
    
    for _, petData in pairs(pets) do
        if espEnabled then
            createESP(petData)
            
            if espObjects[petData.model] and espObjects[petData.model].distLabel then
                local dist = math.floor((myPos - petData.position).Magnitude)
                espObjects[petData.model].distLabel.Text = dist .. " studs"
            end
        else
            removeESP(petData.model)
        end
    end
    
    for pet, _ in pairs(espObjects) do
        if not pet.Parent then
            removeESP(pet)
        end
    end
end

local function updateChristmasESP()
    local xmasPets = getChristmasPets()
    
    for _, xmasPet in pairs(xmasPets) do
        if christmasESPEnabled then
            createChristmasESP(xmasPet)
        else
            removeChristmasESP(xmasPet.model)
        end
    end
    
    for pet, _ in pairs(christmasESPObjects) do
        if not pet.Parent then
            removeChristmasESP(pet)
        end
    end
end

-- ═══════════════════════════════════════
-- 🚀 MOVEMENT
-- ═══════════════════════════════════════

local function enableSpeed()
    if connections.Speed then
        connections.Speed:Disconnect()
    end
    
    connections.Speed = RunService.Heartbeat:Connect(function()
        if not speedBoostEnabled then
            if connections.Speed then
                connections.Speed:Disconnect()
                connections.Speed = nil
            end
            return
        end
        
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = walkSpeed
            end
        end
    end)
end

-- ═══════════════════════════════════════
-- 🎨 UI CREATION
-- ═══════════════════════════════════════

local Window = Fluent:CreateWindow({
    Title = "🦁 Catch & Tame Hub v3.0",
    SubTitle = "by Gael Fonzar - ESP FIXED",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 580),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- Apply Dark Theme
pcall(function()
    local gui = game:GetService("CoreGui"):FindFirstChild("FluentUI") or player.PlayerGui:FindFirstChild("FluentUI")
    if gui then
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                obj.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            end
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                obj.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            end
            if obj:IsA("TextLabel") and obj.Name:find("Title") then
                obj.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end
    end
end)

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "🏠 Main", Icon = "home" }),
    Catch = Window:AddTab({ Title = "🎯 Auto-Catch", Icon = "target" }),
    Money = Window:AddTab({ Title = "💰 Money", Icon = "dollar-sign" }),
    Christmas = Window:AddTab({ Title = "🎄 Christmas", Icon = "gift" }),
    Exploits = Window:AddTab({ Title = "⚡ Exploits", Icon = "zap" }),
    Visual = Window:AddTab({ Title = "👁️ ESP", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "🚀 Movement", Icon = "wind" }),
    Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })
}

-- ═══════════════════════════════════════
-- 🏠 MAIN TAB
-- ═══════════════════════════════════════

Tabs.Main:AddParagraph({
    Title = "🦁 Catch & Tame Hub v3.0",
    Content = "✅ ESP ARREGLADO - Detecta rarezas REALES\n✅ Christmas ESP añadido\n✅ Nuevos exploits útiles\n✅ Auto-Breed & Feed"
})

Tabs.Main:AddButton({
    Title = "💰 Claim Offline Cash",
    Callback = function()
        claimOfflineCash()
    end
})

Tabs.Main:AddButton({
    Title = "💰 Collect All Cash",
    Callback = function()
        collectAllCash()
        Fluent:Notify({Title = "💰 Collected!", Content = "Cash recolectado!", Duration = 2})
    end
})

-- ═══════════════════════════════════════
-- 🎯 CATCH TAB
-- ═══════════════════════════════════════

Tabs.Catch:AddParagraph({
    Title = "🎯 Auto-Catch System",
    Content = "Sistema de captura con detección real de rarezas"
})

Tabs.Catch:AddToggle("InstaCatch", {
    Title = "⚡ Insta-Catch",
    Default = false,
    Callback = function(Value)
        instaCatchEnabled = Value
        if Value then
            Fluent:Notify({Title = "⚡ Insta-Catch ON", Content = "Captura instantánea!", Duration = 2})
        end
    end
})

Tabs.Catch:AddDropdown("RarityFilter", {
    Title = "🎯 Filtro de Rareza",
    Values = {"All", "Legendary", "Mythic", "Epic", "Rare", "Uncommon", "Common", "Christmas"},
    Default = 1,
    Callback = function(Value)
        espRarity = Value
        Fluent:Notify({Title = "🎯 Filtro: " .. Value, Content = "Solo capturará: " .. Value, Duration = 2})
    end
})

Tabs.Catch:AddToggle("AutoTP", {
    Title = "🚀 Auto-TP & Catch",
    Default = false,
    Callback = function(Value)
        autoTPEnabled = Value
        if Value then
            Fluent:Notify({Title = "🚀 Auto-TP ON", Content = "Capturando: " .. espRarity, Duration = 3})
            task.spawn(function() startAutoTPCatch(espRarity) end)
        end
    end
})

Tabs.Catch:AddButton({
    Title = "📍 TP to Nearest Pet",
    Callback = function()
        local petData, dist = getClosestPet(espRarity)
        if petData then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(petData.position + Vector3.new(0, 5, 0))
                Fluent:Notify({Title = "📍 Teleported!", Content = petData.name .. " [" .. petData.rarity .. "]", Duration = 2})
            end
        else
            Fluent:Notify({Title = "❌ No pets", Content = "No hay: " .. espRarity, Duration = 2})
        end
    end
})

-- ═══════════════════════════════════════
-- 💰 MONEY TAB
-- ═══════════════════════════════════════

Tabs.Money:AddToggle("AutoCollect", {
    Title = "💰 Auto-Collect Cash",
    Default = false,
    Callback = function(Value)
        autoCollectCash = Value
        if Value then
            startAutoCollect()
            Fluent:Notify({Title = "💰 Auto-Collect ON", Content = "Cada 3 segundos", Duration = 2})
        end
    end
})

Tabs.Money:AddButton({
    Title = "🎁 Claim Daily Reward",
    Callback = function()
        pcall(function()
            KnitServices.DailyRewardsService.RE.ClaimLoginReward:FireServer()
            Fluent:Notify({Title = "🎁 Daily Reward!", Content = "Reclamada!", Duration = 2})
        end)
    end
})

Tabs.Money:AddSection("Pet Management")

Tabs.Money:AddToggle("AutoBreed", {
    Title = "🥚 Auto-Breed Pets",
    Description = "Cruza pets automáticamente",
    Default = false,
    Callback = function(Value)
        autoBreed = Value
        if Value then
            task.spawn(startAutoBreed)
            Fluent:Notify({Title = "🥚 Auto-Breed ON", Content = "Cruzando pets...", Duration = 2})
        end
    end
})

Tabs.Money:AddToggle("AutoFeed", {
    Title = "🍎 Auto-Feed Pets",
    Description = "Alimenta pets automáticamente",
    Default = false,
    Callback = function(Value)
        autoFeedPets = Value
        if Value then
            task.spawn(startAutoFeed)
            Fluent:Notify({Title = "🍎 Auto-Feed ON", Content = "Alimentando pets...", Duration = 2})
        end
    end
})

-- ═══════════════════════════════════════
-- 🎄 CHRISTMAS TAB
-- ═══════════════════════════════════════

Tabs.Christmas:AddButton({
    Title = "🎁 Claim 5 Free Eggs",
    Description = "Reclama 5 huevos gratis del evento",
    Callback = function()
        autoClaimFreeEggs()
    end
})

Tabs.Christmas:AddButton({
    Title = "🍬 Use 20 Candy Spins",
    Description = "Usar 20 spins de candy",
    Callback = function()
        autoSpinCandy(20)
    end
})

Tabs.Christmas:AddButton({
    Title = "🎄 Buy ALL Christmas Lassos",
    Description = "Compra todos los lassos navideños",
    Callback = function()
        buyAllChristmasLassos()
    end
})

Tabs.Christmas:AddButton({
    Title = "🍬 Infinite Candy Exploit",
    Description = "Duplica candy pass",
    Callback = function()
        infiniteCandy()
    end
})

Tabs.Christmas:AddSection("Christmas ESP")

Tabs.Christmas:AddToggle("ChristmasESP", {
    Title = "🎄 Christmas Pet ESP",
    Description = "Ver mascotas navideñas",
    Default = false,
    Callback = function(Value)
        christmasESPEnabled = Value
        if Value then
            Fluent:Notify({Title = "🎄 Christmas ESP ON", Content = "Mostrando pets navideñas!", Duration = 2})
        else
            for pet, _ in pairs(christmasESPObjects) do
                removeChristmasESP(pet)
            end
        end
    end
})

-- ═══════════════════════════════════════
-- ⚡ EXPLOITS TAB
-- ═══════════════════════════════════════

Tabs.Exploits:AddParagraph({
    Title = "⚡ Advanced Exploits",
    Content = "Vulnerabilidades y exploits avanzados"
})

Tabs.Exploits:AddSection("Luck Exploits")

Tabs.Exploits:AddButton({
    Title = "✨ Activate Super Luck",
    Description = "Luck al máximo para mejores capturas",
    Callback = function()
        activateSuperLuck()
    end
})

Tabs.Exploits:AddButton({
    Title = "🎰 Trait Machine Exploit",
    Description = "Procesa rasgos gratis",
    Callback = function()
        pcall(function()
            Remotes.processTraitMachine:InvokeServer("SuperLuck", 0)
            Fluent:Notify({Title = "🎰 Trait Machine!", Content = "Procesando gratis!", Duration = 2})
        end)
    end
})

Tabs.Exploits:AddSection("Gamepass Bypass")

Tabs.Exploits:AddButton({
    Title = "🖱️ Enable Auto-Clicker",
    Description = "Activa auto-clicker sin gamepass",
    Callback = function()
        autoClickerBypass()
    end
})

Tabs.Exploits:AddButton({
    Title = "⚡ Infinite Riding Potion",
    Description = "Usa pociones infinitas",
    Callback = function()
        pcall(function()
            for i = 1, 10 do
                Remotes.useRidingPotion:InvokeServer()
                task.wait(0.1)
            end
            Fluent:Notify({Title = "⚡ Riding Potion!", Content = "10 pociones usadas!", Duration = 2})
        end)
    end
})

Tabs.Exploits:AddSection("Weather Exploits")

Tabs.Exploits:AddButton({
    Title = "⛈️ Trigger Lightning Storm",
    Description = "Genera tormenta con mascotas raras",
    Callback = function()
        pcall(function()
            Remotes.LightningStrike:FireServer()
            Remotes.UseTotem:FireServer("Lightning")
            Fluent:Notify({Title = "⛈️ Lightning Storm!", Content = "Tormenta activada!", Duration = 2})
        end)
    end
})

Tabs.Exploits:AddButton({
    Title = "☄️ Spawn Meteor Shower",
    Description = "Genera lluvia de meteoritos",
    Callback = function()
        pcall(function()
            Remotes.MeteorSpawn:FireServer()
            Remotes.UseTotem:FireServer("Meteor")
            Fluent:Notify({Title = "☄️ Meteor Shower!", Content = "Meteoritos cayendo!", Duration = 2})
        end)
    end
})

Tabs.Exploits:AddButton({
    Title = "🌌 Cosmic Mutation Event",
    Description = "Activa mutación cósmica",
    Callback = function()
        pcall(function()
            Remotes.CosmicMutation:FireServer()
            Fluent:Notify({Title = "🌌 Cosmic Event!", Content = "Mutación activada!", Duration = 2})
        end)
    end
})

Tabs.Exploits:AddSection("Instant Actions")

Tabs.Exploits:AddButton({
    Title = "⏱️ Skip Time Discount",
    Description = "Salta tiempo de espera gratis",
    Callback = function()
        pcall(function()
            Remotes.skipTimeDiscountAvailable:FireServer()
            Fluent:Notify({Title = "⏱️ Time Skip!", Content = "Tiempo saltado gratis!", Duration = 2})
        end)
    end
})

Tabs.Exploits:AddButton({
    Title = "🥚 Instant Hatch All Eggs",
    Description = "Eclosiona todos los huevos al instante",
    Callback = function()
        pcall(function()
            local TimerService = KnitServices.TimerService
            local eggs = TimerService.RF.GetReadyToHatchEggs:InvokeServer()
            
            if eggs then
                for _, egg in pairs(eggs) do
                    KnitServices.EggService.RE.InstantHatch:FireServer(egg)
                    task.wait(0.2)
                end
                Fluent:Notify({Title = "🥚 Hatched!", Content = "Todos los huevos eclosionados!", Duration = 2})
            end
        end)
    end
})

-- ═══════════════════════════════════════
-- 👁️ ESP TAB
-- ═══════════════════════════════════════

Tabs.Visual:AddParagraph({
    Title = "👁️ ESP System - FIXED",
    Content = "ESP con detección REAL de rarezas del juego"
})

Tabs.Visual:AddToggle("ESP", {
    Title = "👁️ Enable ESP",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if Value then
            Fluent:Notify({Title = "👁️ ESP ON", Content = "Mostrando: " .. espRarity, Duration = 2})
        else
            for pet, _ in pairs(espObjects) do
                removeESP(pet)
            end
        end
    end
})

Tabs.Visual:AddDropdown("ESPRarity", {
    Title = "🎯 ESP Rarity Filter",
    Values = {"All", "Legendary", "Mythic", "Epic", "Rare", "Uncommon", "Common", "Christmas"},
    Default = 1,
    Callback = function(Value)
        espRarity = Value
        for pet, _ in pairs(espObjects) do
            removeESP(pet)
        end
        Fluent:Notify({Title = "🎯 ESP Filter", Content = "Mostrando: " .. Value, Duration = 2})
    end
})

Tabs.Visual:AddSection("Leyenda de Colores")

Tabs.Visual:AddParagraph({
    Title = "🎨 Colores por Rareza",
    Content = "🟡 Legendary (Gold)\n🟣 Mythic (Magenta)\n🟪 Epic (Purple)\n🔵 Rare (Blue)\n🟢 Uncommon (Green)\n⚪ Common (White)\n🔴 Christmas (Red)"
})

Tabs.Visual:AddSection("Debug Info")

Tabs.Visual:AddButton({
    Title = "🔍 Scan Pet Rarities",
    Description = "Escanear rarezas de pets cercanas",
    Callback = function()
        local pets = getRoamingPets()
        local rarityCount = {}
        
        for _, petData in pairs(pets) do
            if not rarityCount[petData.rarity] then
                rarityCount[petData.rarity] = 0
            end
            rarityCount[petData.rarity] = rarityCount[petData.rarity] + 1
        end
        
        local report = "🔍 Pets Detectadas:\n\n"
        for rarity, count in pairs(rarityCount) do
            report = report .. rarity .. ": " .. count .. "\n"
        end
        
        Fluent:Notify({
            Title = "🔍 Scan Complete",
            Content = report,
            Duration = 5
        })
    end
})

-- ═══════════════════════════════════════
-- 🚀 MOVEMENT TAB
-- ═══════════════════════════════════════

Tabs.Movement:AddToggle("Speed", {
    Title = "⚡ Speed Boost",
    Default = false,
    Callback = function(Value)
        speedBoostEnabled = Value
        if Value then
            enableSpeed()
            Fluent:Notify({Title = "⚡ Speed ON", Content = "Velocidad: " .. walkSpeed, Duration = 2})
        else
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end
})

Tabs.Movement:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        walkSpeed = Value
    end
})

-- ═══════════════════════════════════════
-- ⚙️ SETTINGS TAB
-- ═══════════════════════════════════════

Tabs.Settings:AddButton({
    Title = "🗑️ Unload Script",
    Callback = function()
        for _, conn in pairs(connections) do
            if conn then conn:Disconnect() end
        end
        for pet, _ in pairs(espObjects) do
            removeESP(pet)
        end
        for pet, _ in pairs(christmasESPObjects) do
            removeChristmasESP(pet)
        end
        Fluent:Destroy()
    end
})

Tabs.Settings:AddSection("Credits")

Tabs.Settings:AddParagraph({
    Title = "👤 Catch & Tame Hub v3.0",
    Content = "Created by: Gael Fonzar\n\n✅ ESP con rarezas REALES\n✅ Christmas ESP\n✅ 15+ Exploits nuevos\n✅ Auto-Breed & Feed\n✅ Weather exploits\n✅ Gamepass bypass"
})

-- ═══════════════════════════════════════
-- 🔄 UPDATE LOOPS
-- ═══════════════════════════════════════

connections.ESP = RunService.RenderStepped:Connect(function()
    if espEnabled then
        updateESP()
    end
    if christmasESPEnabled then
        updateChristmasESP()
    end
end)

-- Final notification
Fluent:Notify({
    Title = "🦁 Catch & Tame Hub v3.0",
    Content = "ESP ARREGLADO + 15 Exploits nuevos!\nPresiona RightShift",
    Duration = 5
})

print("════════════════════════════════")
print("🦁 Catch & Tame Hub v3.0")
print("Created by: Gael Fonzar")
print("════════════════════════════════")
print("✅ ESP con detección REAL de rarezas")
print("✅ Christmas Pet ESP")
print("✅ 15+ Exploits avanzados:")
print("   • Super Luck")
print("   • Auto-Breed & Feed")
print("   • Weather Events")
print("   • Gamepass Bypass")
print("   • Instant Hatch")
print("   • Trait Machine")
print("   • Infinite Candy")
print("════════════════════════════════")
