--[[
    🦁 CATCH AND TAME - OPTIMIZED SCRIPT
    ═══════════════════════════════════════
    Versión optimizada sin librerías externas
    
    Features:
    ✨ Insta Catch
    💰 Infinite Money
    👁️ ESP System
    📍 Pet List with TP
]]

repeat task.wait() until game:IsLoaded()

print("═══════════════════════════════════")
print("🦁 Catch & Tame Loading...")
print("═══════════════════════════════════")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- Config
local config = {
    InstaCatch = false,
    InfiniteMoney = false,
    ESPEnabled = false,
    ESPDistance = 500
}

local activePets = {}
local espObjects = {}

-- Pet Rarity
local petRarity = {
    ["Hipopótamo"] = {color = Color3.new(1, 0, 1), rarity = "Epic"},
    ["Dragon"] = {color = Color3.new(1, 0, 0), rarity = "Legendary"},
    ["Tiger"] = {color = Color3.new(0.6, 0, 1), rarity = "Epic"},
    ["Lion"] = {color = Color3.new(0.7, 0, 0.8), rarity = "Epic"}
}

-- Funciones de utilidad
local function notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- GUI Creation (Minimalista)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CatchTameGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end)

if not success then
    warn("Error creating GUI:", err)
    return
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 165, 0)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.BorderSizePixel = 0
Title.Text = "🦁 Catch & Tame"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Container
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Container

-- Stats Label
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 30)
StatsLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
StatsLabel.BorderSizePixel = 0
StatsLabel.Text = "📊 Active Pets: 0"
StatsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextSize = 14
StatsLabel.Parent = Container

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsLabel

-- Create Toggle Function
local function createToggle(name, icon, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = icon .. " " .. name
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 40, 0, 24)
    Button.Position = UDim2.new(1, -50, 0.5, -12)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = ""
    Button.Parent = ToggleFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = Button
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 18, 0, 18)
    Indicator.Position = UDim2.new(0, 3, 0.5, -9)
    Indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Button
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(50, 50, 50)
        }):Play()
        
        TweenService:Create(Indicator, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(80, 80, 80)
        }):Play()
        
        if callback then
            pcall(callback, enabled)
        end
    end)
    
    return ToggleFrame
end

-- Create Toggles
createToggle("Insta Catch", "⚡", function(enabled)
    config.InstaCatch = enabled
    notify("⚡ Insta Catch", enabled and "ON" or "OFF")
end)

createToggle("Infinite Money", "💰", function(enabled)
    config.InfiniteMoney = enabled
    notify("💰 Infinite Money", enabled and "ON" or "OFF")
end)

createToggle("ESP Pets", "👁️", function(enabled)
    config.ESPEnabled = enabled
    if not enabled then
        for _, esp in pairs(espObjects) do
            if esp and esp.Parent then
                esp:Destroy()
            end
        end
        espObjects = {}
    end
    notify("👁️ ESP", enabled and "ON" or "OFF")
end)

-- Pet List Section
local PetListLabel = Instance.new("TextLabel")
PetListLabel.Size = UDim2.new(1, 0, 0, 30)
PetListLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PetListLabel.BorderSizePixel = 0
PetListLabel.Text = "📋 Pet List"
PetListLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
PetListLabel.Font = Enum.Font.GothamBold
PetListLabel.TextSize = 14
PetListLabel.Parent = Container

local PetListCorner = Instance.new("UICorner")
PetListCorner.CornerRadius = UDim.new(0, 8)
PetListCorner.Parent = PetListLabel

-- ESP Function
local function createESP(obj, petName, distance)
    if obj:FindFirstChild("PetESP") then
        return
    end
    
    local rarityData = petRarity[petName] or {color = Color3.new(0.5, 0.5, 0.5), rarity = "Common"}
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP"
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = petName
    nameLabel.TextColor3 = rarityData.color
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = math.floor(distance) .. "m"
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextStrokeTransparency = 0
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextScaled = true
    distLabel.Parent = billboard
    
    table.insert(espObjects, billboard)
    
    -- Update distance
    task.spawn(function()
        while billboard.Parent and root do
            task.wait(0.5)
            if obj and obj.Parent then
                local dist = (obj.Position - root.Position).Magnitude
                distLabel.Text = math.floor(dist) .. "m"
            else
                break
            end
        end
    end)
end

-- Detect Pets Function
local function detectPets()
    local petCount = 0
    activePets = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local isPet = obj:FindFirstChild("Animal") or 
                         obj:FindFirstChild("Pet") or
                         string.find(string.lower(obj.Name), "hipopótamo") or
                         string.find(string.lower(obj.Name), "animal")
            
            if isPet then
                local petPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
                
                if petPart and petPart:IsA("BasePart") and root then
                    local distance = (petPart.Position - root.Position).Magnitude
                    
                    if distance <= config.ESPDistance then
                        petCount = petCount + 1
                        table.insert(activePets, {
                            name = obj.Name,
                            part = petPart,
                            distance = distance
                        })
                        
                        if config.ESPEnabled then
                            createESP(petPart, obj.Name, distance)
                        end
                    end
                end
            end
        end
    end
    
    StatsLabel.Text = string.format("📊 Active Pets: %d", petCount)
end

-- Main Loop
task.spawn(function()
    while task.wait(2) do
        pcall(detectPets)
    end
end)

-- Character Update
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
end)

print("✅ Script Loaded Successfully!")
notify("🦁 Script Loaded", "Catch & Tame ready!")
