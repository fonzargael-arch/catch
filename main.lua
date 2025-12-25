--[[
    🦁 CATCH AND TAME - OPTIMIZED SCRIPT
    ═══════════════════════════════════════
    Using Rayfield UI Library for efficiency
    
    Features:
    ✨ Insta Catch
    💰 Infinite Money
    👁️ ESP System
    📍 Pet List with TP
    ⏱️ Despawn Timer
]]

-- Cargar Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Verificar carga del juego
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart", 10)

if not root then
    warn("⚠️ Error: No se encontró HumanoidRootPart")
    return
end

-- Actualizar character al respawn
player.CharacterAdded:Connect(function(c)
    wait(0.5)
    char = c
    root = char:WaitForChild("HumanoidRootPart", 10)
end)

-- Configuración
local config = {
    InstaCatch = false,
    InfiniteMoney = false,
    ESPEnabled = false,
    ESPDistance = 500,
    AutoFarm = false
}

-- Datos de pets
local activePets = {}
local petTimers = {}

local petRarity = {
    ["Dragon"] = {color = Color3.fromRGB(255, 0, 0), rarity = "Legendary"},
    ["Phoenix"] = {color = Color3.fromRGB(255, 100, 0), rarity = "Legendary"},
    ["Unicorn"] = {color = Color3.fromRGB(255, 0, 255), rarity = "Legendary"},
    ["Hipopótamo"] = {color = Color3.fromRGB(150, 0, 255), rarity = "Epic"},
    ["Tiger"] = {color = Color3.fromRGB(150, 0, 255), rarity = "Epic"},
    ["Lion"] = {color = Color3.fromRGB(180, 0, 200), rarity = "Epic"},
    ["Bear"] = {color = Color3.fromRGB(100, 50, 150), rarity = "Epic"},
    ["Elephant"] = {color = Color3.fromRGB(0, 100, 255), rarity = "Rare"},
    ["Giraffe"] = {color = Color3.fromRGB(0, 150, 255), rarity = "Rare"},
    ["Rabbit"] = {color = Color3.fromRGB(0, 255, 0), rarity = "Common"},
    ["Sheep"] = {color = Color3.fromRGB(100, 255, 100), rarity = "Common"}
}

-- Crear UI con Rayfield
local Window = Rayfield:CreateWindow({
    Name = "🦁 Catch & Tame Ultimate",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Krxtopher",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CatchTameConfig",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- Tab Principal
local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP & Visuals", 4483362458)
local PetsTab = Window:CreateTab("🦁 Pet List", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- Sección de estadísticas
local StatsSection = MainTab:CreateSection("📊 Statistics")

local activePetsLabel = MainTab:CreateLabel("Active Pets: 0")
local nearbyPetsLabel = MainTab:CreateLabel("Nearby Pets: 0")

-- Toggle Insta Catch
local InstaCatchToggle = MainTab:CreateToggle({
    Name = "⚡ Insta Catch",
    CurrentValue = false,
    Flag = "InstaCatch",
    Callback = function(value)
        config.InstaCatch = value
        Rayfield:Notify({
            Title = "Insta Catch",
            Content = value and "Activado ✅" or "Desactivado ❌",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Toggle Infinite Money
local InfiniteMoneyToggle = MainTab:CreateToggle({
    Name = "💰 Infinite Money",
    CurrentValue = false,
    Flag = "InfiniteMoney",
    Callback = function(value)
        config.InfiniteMoney = value
        Rayfield:Notify({
            Title = "Infinite Money",
            Content = value and "Activado ✅" or "Desactivado ❌",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Toggle Auto Farm
local AutoFarmToggle = MainTab:CreateToggle({
    Name = "🤖 Auto Farm Pets",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        config.AutoFarm = value
        Rayfield:Notify({
            Title = "Auto Farm",
            Content = value and "Activado ✅" or "Desactivado ❌",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- ESP Section
local ESPSection = ESPTab:CreateSection("👁️ ESP Configuration")

local ESPToggle = ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(value)
        config.ESPEnabled = value
        if not value then
            for _, esp in pairs(workspace:GetDescendants()) do
                if esp.Name == "PetESP" then
                    esp:Destroy()
                end
            end
        end
        Rayfield:Notify({
            Title = "ESP",
            Content = value and "Activado ✅" or "Desactivado ❌",
            Duration = 3
        })
    end
})

local ESPDistanceSlider = ESPTab:CreateSlider({
    Name = "ESP Distance",
    Range = {100, 1000},
    Increment = 50,
    CurrentValue = 500,
    Flag = "ESPDistance",
    Callback = function(value)
        config.ESPDistance = value
    end
})

-- Pet List Section
local PetListSection = PetsTab:CreateSection("🦁 Active Pets")

local petListLabel = PetsTab:CreateLabel("No pets detected nearby")

local RefreshButton = PetsTab:CreateButton({
    Name = "🔄 Refresh Pet List",
    Callback = function()
        detectPets()
        Rayfield:Notify({
            Title = "Pet List",
            Content = "Lista actualizada",
            Duration = 2
        })
    end
})

-- Funciones principales
local function createESP(petPart, petName, distance)
    if petPart:FindFirstChild("PetESP") then return end
    
    local rarityInfo = petRarity[petName] or {color = Color3.fromRGB(100, 100, 100), rarity = "Unknown"}
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP"
    billboard.Adornee = petPart
    billboard.Size = UDim2.new(0, 100, 0, 60)
    billboard.AlwaysOnTop = true
    billboard.Parent = petPart
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = petName
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
    
    -- Actualizar distancia
    task.spawn(function()
        while billboard.Parent and root do
            task.wait(0.5)
            if petPart and petPart.Parent then
                local newDist = (petPart.Position - root.Position).Magnitude
                distLabel.Text = math.floor(newDist) .. " studs"
            else
                billboard:Destroy()
                break
            end
        end
    end)
end

function detectPets()
    local pets = {}
    local nearbyCount = 0
    
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
                                 string.find(string.lower(obj.Name), "animal") or
                                 string.find(string.lower(obj.Name), "pet") or
                                 string.find(string.lower(obj.Name), "hipopótamo")
                    
                    if isPet then
                        local petPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
                        
                        if petPart and petPart:IsA("BasePart") and root then
                            local distance = (petPart.Position - root.Position).Magnitude
                            
                            if distance <= config.ESPDistance then
                                nearbyCount = nearbyCount + 1
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
                                
                                if config.ESPEnabled then
                                    createESP(petPart, obj.Name, distance)
                                end
                                
                                -- Auto Farm
                                if config.AutoFarm and distance > 10 then
                                    root.CFrame = CFrame.new(petPart.Position + Vector3.new(0, 5, 0))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Limpiar pets que ya no existen
    for id, pet in pairs(activePets) do
        if not pets[id] or not pet.model or not pet.model.Parent then
            activePets[id] = nil
            petTimers[id] = nil
        end
    end
    
    activePets = pets
    
    -- Actualizar labels
    activePetsLabel:Set("Active Pets: " .. #activePets)
    nearbyPetsLabel:Set("Nearby Pets: " .. nearbyCount)
    
    -- Crear botones de TP para cada pet
    updatePetButtons()
end

function updatePetButtons()
    -- Limpiar botones anteriores
    for _, v in pairs(PetsTab:GetChildren()) do
        if v.Name == "PetButton" then
            v:Destroy()
        end
    end
    
    -- Ordenar pets por distancia
    local sortedPets = {}
    for _, pet in pairs(activePets) do
        table.insert(sortedPets, pet)
    end
    
    table.sort(sortedPets, function(a, b)
        return a.distance < b.distance
    end)
    
    -- Crear botones para cada pet
    for i, pet in ipairs(sortedPets) do
        if i <= 10 then -- Limitar a 10 pets
            local rarityInfo = petRarity[pet.name] or {rarity = "Unknown"}
            local timeLeft = petTimers[pet.id] or 30
            
            PetsTab:CreateButton({
                Name = string.format("🦁 %s [%s] - %dm - %ds",
                    pet.name,
                    rarityInfo.rarity,
                    math.floor(pet.distance),
                    timeLeft
                ),
                Callback = function()
                    if pet.model and pet.model.Parent and root then
                        local petPos = pet.part.Position
                        root.CFrame = CFrame.new(petPos + Vector3.new(0, 5, 0))
                        Rayfield:Notify({
                            Title = "Teleported",
                            Content = "Teleportado a " .. pet.name,
                            Duration = 2
                        })
                    end
                end
            })
        end
    end
end

-- Infinite Money Hook
if config.InfiniteMoney then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" and string.find(tostring(self), "Purchase") then
            -- Guardar dinero antes de comprar
            local currentMoney = player.leaderstats and player.leaderstats.Money and player.leaderstats.Money.Value
            
            local result = oldNamecall(self, ...)
            
            -- Restaurar dinero después de comprar
            if currentMoney and player.leaderstats and player.leaderstats.Money then
                player.leaderstats.Money.Value = currentMoney
            end
            
            return result
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Insta Catch Hook
task.spawn(function()
    while task.wait(0.1) do
        if config.InstaCatch then
            for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    if string.find(string.lower(remote.Name), "catch") or 
                       string.find(string.lower(remote.Name), "capture") or
                       string.find(string.lower(remote.Name), "tame") then
                        
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(true, 100)
                            else
                                remote:InvokeServer(true, 100)
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- Loop principal de detección
task.spawn(function()
    while task.wait(2) do
        if root then
            pcall(detectPets)
        end
    end
end)

-- Timer countdown
task.spawn(function()
    while task.wait(1) do
        for id, timeLeft in pairs(petTimers) do
            if timeLeft > 0 then
                petTimers[id] = timeLeft - 1
            else
                petTimers[id] = nil
                activePets[id] = nil
            end
        end
        updatePetButtons()
    end
end)

-- Notificación de carga exitosa
Rayfield:Notify({
    Title = "🦁 Script Loaded",
    Content = "Catch & Tame Ultimate cargado correctamente",
    Duration = 5,
    Image = 4483362458
})

print("═══════════════════════════════════")
print("🦁 Catch & Tame Script Loaded!")
print("═══════════════════════════════════")
