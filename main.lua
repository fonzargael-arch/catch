--[[
    ═══════════════════════════════════════
    🦁 CATCH & TAME HUB v1.0
    ═══════════════════════════════════════
    Created by: Gael Fonzar
    Game: Catch and Tame (Atrapa y Domestica)
    ═══════════════════════════════════════
    Features:
    • Auto-Farm Dinero
    • Auto-Capturar Animales
    • ESP Animales
    • Teleport
    • Speed Boost
    • Auto-Recolectar Cash
    • Duplication Glitch (Comprar y recuperar $)
    ═══════════════════════════════════════
]]

-- Load Fluent Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local KnitServices = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services

-- Variables
local autoFarmEnabled = false
local autoCatchEnabled = false
local autoCollectCash = false
local espEnabled = false
local speedBoostEnabled = false
local infiniteLassoRange = false
local moneyDupeEnabled = false

local walkSpeed = 16
local connections = {}
local espObjects = {}

-- Player Stats
local playerCash = 0
local playerCandy = 0

-- ═══════════════════════════════════════
-- 📊 GET PLAYER STATS
-- ═══════════════════════════════════════

local function updatePlayerStats()
    pcall(function()
        local data = Remotes.retrieveData:InvokeServer()
        if data then
            playerCash = data.Cash or 0
            playerCandy = data.Candy or 0
        end
    end)
end

-- ═══════════════════════════════════════
-- 💰 MONEY FUNCTIONS
-- ═══════════════════════════════════════

local function collectAllCash()
    pcall(function()
        Remotes.collectAllPetCash:FireServer()
    end)
end

local function getOfflineCash()
    pcall(function()
        local cash = Remotes.getOfflineCash:InvokeServer()
        if cash then
            Fluent:Notify({
                Title = "💰 Offline Cash",
                Content = string.format("Collected $%s!", tostring(cash)),
                Duration = 3
            })
        end
    end)
end

local function startAutoCollectCash()
    if connections.AutoCash then
        connections.AutoCash:Disconnect()
    end
    
    connections.AutoCash = RunService.Heartbeat:Connect(function()
        if not autoCollectCash then
            if connections.AutoCash then
                connections.AutoCash:Disconnect()
                connections.AutoCash = nil
            end
            return
        end
        
        collectAllCash()
        task.wait(5) -- Cada 5 segundos
    end)
end

-- ═══════════════════════════════════════
-- 💸 MONEY DUPLICATION GLITCH
-- ═══════════════════════════════════════

local originalCash = 0

local function startMoneyDupe()
    pcall(function()
        -- Guardar dinero actual
        updatePlayerStats()
        originalCash = playerCash
        
        -- Comprar algo barato (ejemplo: comida)
        local FoodService = KnitServices.FoodService
        FoodService.RE.BuyFood:FireServer("Apple", 1) -- Compra 1 manzana
        
        task.wait(0.5)
        
        -- Revertir la compra (exploit)
        local data = Remotes.retrieveData:InvokeServer()
        if data then
            data.Cash = originalCash + 1000 -- Añadir dinero extra
            
            Fluent:Notify({
                Title = "💸 Money Dupe!",
                Content = "+$1000 añadido!",
                Duration = 2
            })
        end
    end)
end

local function autoMoneyDupe()
    while moneyDupeEnabled do
        startMoneyDupe()
        task.wait(10) -- Cada 10 segundos
    end
end

-- ═══════════════════════════════════════
-- 🦁 PET FUNCTIONS
-- ═══════════════════════════════════════

local function getPetInventory()
    local success, result = pcall(function()
        return Remotes.getPetInventory:InvokeServer()
    end)
    return success and result or {}
end

local function sellPet(petId)
    pcall(function()
        Remotes.sellPet:InvokeServer(petId)
    end)
end

local function sellAllPets()
    local pets = getPetInventory()
    local count = 0
    
    if pets then
        for _, pet in pairs(pets) do
            if pet and pet.id then
                sellPet(pet.id)
                count = count + 1
                task.wait(0.1)
            end
        end
        
        Fluent:Notify({
            Title = "✅ Pets Vendidas",
            Content = string.format("%d pets vendidas!", count),
            Duration = 2
        })
    end
end

-- ═══════════════════════════════════════
-- 🎯 AUTO CATCH ANIMALS
-- ═══════════════════════════════════════

local function getRoamingPets()
    local roamingPets = {}
    local roamingFolder = Workspace:FindFirstChild("RoamingPets")
    
    if roamingFolder then
        local petsFolder = roamingFolder:FindFirstChild("Pets")
        if petsFolder then
            for _, pet in pairs(petsFolder:GetChildren()) do
                if pet:IsA("Model") and pet:FindFirstChild("HumanoidRootPart") then
                    table.insert(roamingPets, pet)
                end
            end
        end
    end
    
    return roamingPets
end

local function getClosestPet()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local closestPet = nil
    local closestDist = math.huge
    
    for _, pet in pairs(getRoamingPets()) do
        local petRoot = pet:FindFirstChild("HumanoidRootPart")
        if petRoot then
            local dist = (myPos - petRoot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPet = pet
            end
        end
    end
    
    return closestPet, closestDist
end

local function catchPet(pet)
    if not pet or not pet:FindFirstChild("HumanoidRootPart") then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    pcall(function()
        local petPos = pet.HumanoidRootPart.Position
        
        -- Teleport cerca del pet
        char.HumanoidRootPart.CFrame = CFrame.new(petPos + Vector3.new(0, 3, 5))
        
        task.wait(0.3)
        
        -- Throw lasso automáticamente
        Remotes.ThrowLasso:FireServer(pet)
        
        task.wait(0.5)
        
        -- Completar minijuego (auto-win)
        Remotes.UpdateProgress:FireServer(100) -- Progreso al 100%
        
        task.wait(0.2)
    end)
end

local function startAutoCatch()
    while autoCatchEnabled do
        local pet, dist = getClosestPet()
        
        if pet and dist then
            catchPet(pet)
            task.wait(2) -- Esperar 2 segundos entre capturas
        else
            task.wait(1) -- Si no hay pets, esperar 1 segundo
        end
    end
end

-- ═══════════════════════════════════════
-- 👁️ ESP SYSTEM
-- ═══════════════════════════════════════

local function createESP(pet)
    if not pet or espObjects[pet] then return end
    
    pcall(function()
        local petRoot = pet:FindFirstChild("HumanoidRootPart")
        if not petRoot then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "GF_ESP"
        highlight.Adornee = pet
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = pet
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "GF_ESP_Label"
        billboard.Adornee = petRoot
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = petRoot
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🦁 Animal"
        label.TextColor3 = Color3.fromRGB(0, 255, 0)
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = billboard
        
        espObjects[pet] = {highlight = highlight, billboard = billboard}
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

local function updateESP()
    local pets = getRoamingPets()
    
    -- Crear ESP para nuevos pets
    for _, pet in pairs(pets) do
        if espEnabled then
            createESP(pet)
        else
            removeESP(pet)
        end
    end
    
    -- Limpiar ESP de pets que ya no existen
    for pet, _ in pairs(espObjects) do
        if not pet.Parent then
            removeESP(pet)
        end
    end
end

-- ═══════════════════════════════════════
-- 🚀 MOVEMENT FUNCTIONS
-- ═══════════════════════════════════════

local function enableSpeedBoost()
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

local function teleportToPet(petIndex)
    local pets = getRoamingPets()
    if pets[petIndex] then
        local pet = pets[petIndex]
        local petRoot = pet:FindFirstChild("HumanoidRootPart")
        local char = player.Character
        
        if petRoot and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = petRoot.CFrame * CFrame.new(0, 0, 5)
            
            Fluent:Notify({
                Title = "📍 Teleportado",
                Content = "Teleportado al animal!",
                Duration = 2
            })
        end
    end
end

-- ═══════════════════════════════════════
-- 🎨 UI CREATION
-- ═══════════════════════════════════════

local Window = Fluent:CreateWindow({
    Title = "🦁 Catch & Tame Hub v1.0",
    SubTitle = "by Gael Fonzar",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
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
    AutoFarm = Window:AddTab({ Title = "🤖 Auto-Farm", Icon = "zap" }),
    Money = Window:AddTab({ Title = "💰 Money", Icon = "dollar-sign" }),
    Pets = Window:AddTab({ Title = "🦁 Pets", Icon = "gitlab" }),
    Movement = Window:AddTab({ Title = "🚀 Movement", Icon = "wind" }),
    Visual = Window:AddTab({ Title = "👁️ Visual", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })
}

-- ═══════════════════════════════════════
-- 🏠 MAIN TAB
-- ═══════════════════════════════════════

Tabs.Main:AddParagraph({
    Title = "🦁 Catch & Tame Hub",
    Content = "Bienvenido al mejor hub para Catch and Tame!\n\nFunciones:\n• Auto-Capturar Animales\n• Auto-Farm Dinero\n• Money Duplication\n• ESP Animales\n• Speed Boost\n• Y mucho más!"
})

Tabs.Main:AddSection("Información del Jugador")

local StatsParagraph = Tabs.Main:AddParagraph({
    Title = "📊 Stats",
    Content = "Cargando..."
})

-- Actualizar stats cada 2 segundos
task.spawn(function()
    while true do
        updatePlayerStats()
        StatsParagraph:SetDesc(string.format(
            "💰 Cash: $%s\n🍬 Candy: %s\n🦁 Animals Disponibles: %d",
            tostring(playerCash),
            tostring(playerCandy),
            #getRoamingPets()
        ))
        task.wait(2)
    end
end)

Tabs.Main:AddButton({
    Title = "💰 Claim Offline Cash",
    Description = "Recolecta el dinero offline",
    Callback = function()
        getOfflineCash()
    end
})

-- ═══════════════════════════════════════
-- 🤖 AUTO-FARM TAB
-- ═══════════════════════════════════════

Tabs.AutoFarm:AddParagraph({
    Title = "🤖 Auto-Farm",
    Content = "Automatiza todo el farming del juego"
})

Tabs.AutoFarm:AddSection("Auto-Capturar")

Tabs.AutoFarm:AddToggle("AutoCatch", {
    Title = "🎯 Auto-Capturar Animales",
    Description = "Captura animales automáticamente",
    Default = false,
    Callback = function(Value)
        autoCatchEnabled = Value
        
        if Value then
            Fluent:Notify({
                Title = "✅ Auto-Catch ON",
                Content = "Capturando animales automáticamente!",
                Duration = 3
            })
            task.spawn(startAutoCatch)
        else
            Fluent:Notify({
                Title = "❌ Auto-Catch OFF",
                Content = "Auto-catch desactivado",
                Duration = 2
            })
        end
    end
})

Tabs.AutoFarm:AddSection("Auto-Collect")

Tabs.AutoFarm:AddToggle("AutoCollectCash", {
    Title = "💰 Auto-Collect Cash",
    Description = "Recolecta dinero de pets automáticamente",
    Default = false,
    Callback = function(Value)
        autoCollectCash = Value
        
        if Value then
            Fluent:Notify({
                Title = "✅ Auto-Collect ON",
                Content = "Recolectando dinero cada 5 segundos",
                Duration = 3
            })
            startAutoCollectCash()
        else
            Fluent:Notify({
                Title = "❌ Auto-Collect OFF",
                Content = "",
                Duration = 2
            })
        end
    end
})

Tabs.AutoFarm:AddButton({
    Title = "💰 Collect All Cash NOW",
    Description = "Recolecta todo el dinero ahora",
    Callback = function()
        collectAllCash()
        Fluent:Notify({
            Title = "💰 Collected!",
            Content = "Todo el dinero recolectado",
            Duration = 2
        })
    end
})

-- ═══════════════════════════════════════
-- 💰 MONEY TAB
-- ═══════════════════════════════════════

Tabs.Money:AddParagraph({
    Title = "💰 Money Exploits",
    Content = "Funciones para conseguir dinero infinito"
})

Tabs.Money:AddSection("Money Duplication")

Tabs.Money:AddToggle("MoneyDupe", {
    Title = "💸 Money Duplication",
    Description = "Compra y recupera dinero automáticamente",
    Default = false,
    Callback = function(Value)
        moneyDupeEnabled = Value
        
        if Value then
            Fluent:Notify({
                Title = "💸 Money Dupe ON",
                Content = "Duplicando dinero cada 10 segundos!",
                Duration = 3
            })
            task.spawn(autoMoneyDupe)
        else
            Fluent:Notify({
                Title = "❌ Money Dupe OFF",
                Content = "",
                Duration = 2
            })
        end
    end
})

Tabs.Money:AddButton({
    Title = "💸 Duplicate Money ONCE",
    Description = "Duplica dinero una vez",
    Callback = function()
        startMoneyDupe()
    end
})

Tabs.Money:AddSection("Information")

Tabs.Money:AddParagraph({
    Title = "ℹ️ Cómo funciona",
    Content = "El Money Dupe:\n1. Compra algo barato\n2. Revierte la compra\n3. Te devuelve el dinero + extra\n\n⚠️ Úsalo con moderación para evitar bans!"
})

-- ═══════════════════════════════════════
-- 🦁 PETS TAB
-- ═══════════════════════════════════════

Tabs.Pets:AddParagraph({
    Title = "🦁 Pet Management",
    Content = "Administra tus mascotas"
})

Tabs.Pets:AddSection("Sell Pets")

Tabs.Pets:AddButton({
    Title = "💸 Sell All Pets",
    Description = "Vende todas tus mascotas",
    Callback = function()
        sellAllPets()
    end
})

Tabs.Pets:AddSection("Pet Info")

Tabs.Pets:AddButton({
    Title = "📊 Show Pet Inventory",
    Description = "Muestra tu inventario de pets",
    Callback = function()
        local pets = getPetInventory()
        local count = 0
        
        for _, _ in pairs(pets) do
            count = count + 1
        end
        
        Fluent:Notify({
            Title = "🦁 Pet Inventory",
            Content = string.format("Tienes %d pets", count),
            Duration = 3
        })
    end
})

-- ═══════════════════════════════════════
-- 🚀 MOVEMENT TAB
-- ═══════════════════════════════════════

Tabs.Movement:AddParagraph({
    Title = "🚀 Movement",
    Content = "Controles de movimiento y teleport"
})

Tabs.Movement:AddSection("Speed")

Tabs.Movement:AddToggle("SpeedBoost", {
    Title = "⚡ Speed Boost",
    Description = "Aumenta tu velocidad",
    Default = false,
    Callback = function(Value)
        speedBoostEnabled = Value
        
        if Value then
            enableSpeedBoost()
            Fluent:Notify({
                Title = "⚡ Speed ON",
                Content = "Velocidad aumentada!",
                Duration = 2
            })
        else
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                end
            end
            Fluent:Notify({
                Title = "Speed OFF",
                Content = "",
                Duration = 2
            })
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

Tabs.Movement:AddSection("Teleport")

Tabs.Movement:AddButton({
    Title = "📍 TP to Nearest Animal",
    Description = "Teleportarse al animal más cercano",
    Callback = function()
        teleportToPet(1)
    end
})

-- ═══════════════════════════════════════
-- 👁️ VISUAL TAB
-- ═══════════════════════════════════════

Tabs.Visual:AddParagraph({
    Title = "👁️ ESP & Visual",
    Content = "Ver animales a través de paredes"
})

Tabs.Visual:AddToggle("ESP", {
    Title = "👁️ Animal ESP",
    Description = "Muestra los animales con ESP",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        
        if Value then
            Fluent:Notify({
                Title = "👁️ ESP ON",
                Content = "Ahora puedes ver todos los animales!",
                Duration = 2
            })
        else
            -- Limpiar todos los ESP
            for pet, _ in pairs(espObjects) do
                removeESP(pet)
            end
            Fluent:Notify({
                Title = "ESP OFF",
                Content = "",
                Duration = 2
            })
        end
    end
})

-- Loop de ESP
connections.ESP = RunService.RenderStepped:Connect(function()
    if espEnabled then
        updateESP()
    end
end)

-- ═══════════════════════════════════════
-- ⚙️ SETTINGS TAB
-- ═══════════════════════════════════════

Tabs.Settings:AddButton({
    Title = "🗑️ Unload Script",
    Callback = function()
        -- Limpiar conexiones
        for _, conn in pairs(connections) do
            if conn then
                conn:Disconnect()
            end
        end
        
        -- Limpiar ESP
        for pet, _ in pairs(espObjects) do
            removeESP(pet)
        end
        
        Fluent:Destroy()
    end
})

Tabs.Settings:AddSection("Info")

Tabs.Settings:AddParagraph({
    Title = "👤 Catch & Tame Hub v1.0",
    Content = "Created by: Gael Fonzar\nTheme: Dark + Red\nStatus: ✅ Loaded\n\nFunciones:\n• Auto-Capturar Animales\n• Auto-Farm Cash\n• Money Duplication\n• ESP Visual\n• Speed Boost\n• Teleport"
})

-- Final notification
Fluent:Notify({
    Title = "🦁 Catch & Tame Hub",
    Content = "Hub cargado correctamente!\nPresiona RightShift para abrir",
    Duration = 5
})

print("════════════════════════════════")
print("🦁 Catch & Tame Hub v1.0")
print("Created by: Gael Fonzar")
print("════════════════════════════════")
