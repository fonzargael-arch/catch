--[[
    🔍 GAME STRUCTURE SCANNER
    ═══════════════════════════════════════
    Escanea todo el juego para encontrar:
    - RemoteEvents/Functions
    - Pets/Animals
    - Money/Currency
    - Important Objects
]]

print("═══════════════════════════════════")
print("🔍 Starting Game Scanner...")
print("═══════════════════════════════════")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Results Storage
local scanResults = {
    remoteEvents = {},
    remoteFunctions = {},
    pets = {},
    animals = {},
    money = {},
    important = {},
    folders = {}
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 255, 255)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "🔍 Game Structure Scanner"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Buttons Container
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.new(1, -20, 0, 50)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = MainFrame

local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonLayout.Padding = UDim.new(0, 10)
ButtonLayout.Parent = ButtonsFrame

-- Scroll Frame for Results
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -120)
ScrollFrame.Position = UDim2.new(0, 10, 0, 110)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local ResultsLayout = Instance.new("UIListLayout")
ResultsLayout.Padding = UDim.new(0, 5)
ResultsLayout.Parent = ScrollFrame

-- Function to create button
local function createButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 130, 1, 0)
    Button.BackgroundColor3 = color
    Button.Text = text
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = ButtonsFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return Button
end

-- Function to add result
local function addResult(text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Label.Text = text
    Label.TextColor3 = color or Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = false
    Label.ClipsDescendants = true
    Label.Parent = ScrollFrame
    
    local LblCorner = Instance.new("UICorner")
    LblCorner.CornerRadius = UDim.new(0, 4)
    LblCorner.Parent = Label
    
    -- Copy on click
    Label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setclipboard(text)
            Label.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            task.wait(0.2)
            Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)
end

-- Function to clear results
local function clearResults()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

-- Scanner Functions
local function scanRemotes()
    clearResults()
    addResult("═══ SCANNING REMOTES ═══", Color3.fromRGB(0, 255, 255))
    
    local count = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            count = count + 1
            local path = obj:GetFullName()
            addResult("📡 [RemoteEvent] " .. path, Color3.fromRGB(255, 100, 100))
            table.insert(scanResults.remoteEvents, path)
        elseif obj:IsA("RemoteFunction") then
            count = count + 1
            local path = obj:GetFullName()
            addResult("📞 [RemoteFunction] " .. path, Color3.fromRGB(255, 150, 100))
            table.insert(scanResults.remoteFunctions, path)
        end
    end
    
    addResult(string.format("
✅ Found %d remotes", count), Color3.fromRGB(0, 255, 0))
end

local function scanPets()
    clearResults()
    addResult("═══ SCANNING PETS/ANIMALS ═══", Color3.fromRGB(0, 255, 255))
    
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart") then
            if name:find("animal") or name:find("pet") or name:find("hipopótamo") or 
               name:find("dragon") or name:find("lion") or name:find("tiger") or
               obj:FindFirstChild("Animal") or obj:FindFirstChild("Pet") then
                count = count + 1
                local path = obj:GetFullName()
                local objType = obj.ClassName
                addResult(string.format("🦁 [%s] %s", objType, path), Color3.fromRGB(255, 200, 0))
                table.insert(scanResults.pets, path)
            end
        end
    end
    
    addResult(string.format("
✅ Found %d pets/animals", count), Color3.fromRGB(0, 255, 0))
end

local function scanMoney()
    clearResults()
    addResult("═══ SCANNING MONEY/CURRENCY ═══", Color3.fromRGB(0, 255, 255))
    
    local count = 0
    
    -- Check player stats
    if player:FindFirstChild("leaderstats") then
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            count = count + 1
            local path = stat:GetFullName()
            local value = stat.Value
            addResult(string.format("💰 [Stat] %s = %s", path, tostring(value)), Color3.fromRGB(255, 215, 0))
            table.insert(scanResults.money, {path = path, value = value})
        end
    end
    
    -- Check for money/currency in ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("money") or name:find("coin") or name:find("cash") or name:find("currency") then
            count = count + 1
            local path = obj:GetFullName()
            addResult("💵 [" .. obj.ClassName .. "] " .. path, Color3.fromRGB(0, 255, 100))
            table.insert(scanResults.money, path)
        end
    end
    
    addResult(string.format("
✅ Found %d money-related objects", count), Color3.fromRGB(0, 255, 0))
end

local function scanImportant()
    clearResults()
    addResult("═══ SCANNING IMPORTANT OBJECTS ═══", Color3.fromRGB(0, 255, 255))
    
    local keywords = {
        "catch", "tame", "capture", "lasso", "rope", "purchase", "buy", "shop",
        "inventory", "equip", "tool", "spawn", "collect", "farm"
    }
    
    local count = 0
    
    -- Scan ReplicatedStorage
    addResult("
📦 ReplicatedStorage:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        local name = obj.Name:lower()
        for _, keyword in pairs(keywords) do
            if name:find(keyword) then
                count = count + 1
                local path = obj:GetFullName()
                addResult(string.format("  ⭐ [%s] %s", obj.ClassName, path), Color3.fromRGB(200, 200, 255))
                break
            end
        end
    end
    
    -- Scan Workspace important folders
    addResult("
🌍 Workspace:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") or obj:IsA("Model") then
            count = count + 1
            local path = obj:GetFullName()
            addResult(string.format("  📁 [%s] %s", obj.ClassName, path), Color3.fromRGB(150, 255, 150))
        end
    end
    
    addResult(string.format("
✅ Found %d important objects", count), Color3.fromRGB(0, 255, 0))
end

local function exportAll()
    clearResults()
    addResult("═══ FULL GAME STRUCTURE EXPORT ═══", Color3.fromRGB(255, 0, 255))
    
    local export = "🔍 CATCH AND TAME - GAME STRUCTURE
"
    export = export .. "═══════════════════════════════════

"
    
    -- RemoteEvents
    export = export .. "📡 REMOTE EVENTS:
"
    for _, remote in pairs(scanResults.remoteEvents) do
        export = export .. "  " .. remote .. "
"
    end
    
    export = export .. "
📞 REMOTE FUNCTIONS:
"
    for _, remote in pairs(scanResults.remoteFunctions) do
        export = export .. "  " .. remote .. "
"
    end
    
    -- Pets
    export = export .. "
🦁 PETS/ANIMALS:
"
    for _, pet in pairs(scanResults.pets) do
        export = export .. "  " .. pet .. "
"
    end
    
    -- Money
    export = export .. "
💰 MONEY/CURRENCY:
"
    for _, money in pairs(scanResults.money) do
        if type(money) == "table" then
            export = export .. string.format("  %s = %s
", money.path, tostring(money.value))
        else
            export = export .. "  " .. money .. "
"
        end
    end
    
    setclipboard(export)
    addResult("✅ FULL EXPORT COPIED TO CLIPBOARD!", Color3.fromRGB(0, 255, 0))
    addResult("", Color3.new(1, 1, 1))
    addResult("Preview:", Color3.fromRGB(255, 255, 0))
    
    for line in export:gmatch("[^
]+") do
        addResult(line, Color3.fromRGB(200, 200, 200))
    end
end

-- Create Buttons
createButton("🔍 Scan Remotes", Color3.fromRGB(255, 50, 50), scanRemotes)
createButton("🦁 Scan Pets", Color3.fromRGB(255, 165, 0), scanPets)
createButton("💰 Scan Money", Color3.fromRGB(255, 215, 0), scanMoney)
createButton("⭐ Important", Color3.fromRGB(100, 150, 255), scanImportant)
createButton("📋 Export All", Color3.fromRGB(200, 50, 200), exportAll)

-- Initial message
addResult("👆 Click any button to start scanning", Color3.fromRGB(150, 150, 150))
addResult("💡 Click on any result to copy it to clipboard", Color3.fromRGB(150, 150, 150))

print("✅ Scanner GUI Loaded!")
print("🔍 Use the buttons to scan different parts of the game")
