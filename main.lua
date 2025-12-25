--[[
    🔍 GAME STRUCTURE SCANNER
    ═══════════════════════════════════════
    Compatible con Xeno Executor
    Click en resultados para copiar
]]

print("═══════════════════════════════════")
print("🔍 Starting Game Scanner...")
print("═══════════════════════════════════")

-- Wait for game
repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Safe clipboard function
local function copyToClipboard(text)
    local success, err = pcall(function()
        if setclipboard then
            setclipboard(text)
            return true
        elseif toclipboard then
            toclipboard(text)
            return true
        end
    end)
    return success
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerGUI"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
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
Stroke.Thickness = 3
Stroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "🔍 GAME STRUCTURE SCANNER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Buttons Frame
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.new(1, -20, 0, 50)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 55)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = MainFrame

local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonLayout.Padding = UDim.new(0, 8)
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.Parent = ButtonsFrame

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -125)
ScrollFrame.Position = UDim2.new(0, 10, 0, 115)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local ResultsLayout = Instance.new("UIListLayout")
ResultsLayout.Padding = UDim.new(0, 3)
ResultsLayout.Parent = ScrollFrame

-- Create Button Function
local function createButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 130, 1, 0)
    Button.BackgroundColor3 = color
    Button.Text = text
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.Parent = ButtonsFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(0.1)
        Button.BackgroundColor3 = color
        if callback then pcall(callback) end
    end)
    
    return Button
end

-- Add Result Function
local function addResult(text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 22)
    Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Label.Text = " " .. text
    Label.TextColor3 = color or Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Code
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.Parent = ScrollFrame
    
    local LblCorner = Instance.new("UICorner")
    LblCorner.CornerRadius = UDim.new(0, 4)
    LblCorner.Parent = Label
    
    -- Click to copy
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Label
    
    Button.MouseButton1Click:Connect(function()
        if copyToClipboard(text) then
            Label.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            task.wait(0.2)
            Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)
end

-- Clear Results
local function clearResults()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

-- SCANNER FUNCTIONS

local function scanRemotes()
    clearResults()
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("📡 REMOTE EVENTS & FUNCTIONS", Color3.fromRGB(0, 255, 255))
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("", Color3.new(1, 1, 1))
    
    local count = 0
    
    -- Scan ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            count = count + 1
            addResult("📡 " .. obj:GetFullName(), Color3.fromRGB(255, 100, 100))
        elseif obj:IsA("RemoteFunction") then
            count = count + 1
            addResult("📞 " .. obj:GetFullName(), Color3.fromRGB(255, 150, 100))
        end
    end
    
    addResult("", Color3.new(1, 1, 1))
    addResult("✅ Total: " .. count .. " remotes found", Color3.fromRGB(0, 255, 0))
    
    print("📡 Found " .. count .. " remotes")
end

local function scanPets()
    clearResults()
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("🦁 PETS & ANIMALS", Color3.fromRGB(0, 255, 255))
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("", Color3.new(1, 1, 1))
    
    local count = 0
    local found = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local isAnimal = name:find("animal") or name:find("pet") or 
                        name:find("hipopótamo") or name:find("hipopotamo") or
                        obj:FindFirstChild("Animal") or obj:FindFirstChild("Pet")
        
        if isAnimal and not found[obj:GetFullName()] then
            count = count + 1
            found[obj:GetFullName()] = true
            local icon = obj:IsA("Model") and "📦" or "🔷"
            addResult(icon .. " " .. obj:GetFullName(), Color3.fromRGB(255, 200, 0))
        end
    end
    
    addResult("", Color3.new(1, 1, 1))
    addResult("✅ Total: " .. count .. " pets/animals found", Color3.fromRGB(0, 255, 0))
    
    print("🦁 Found " .. count .. " pets")
end

local function scanMoney()
    clearResults()
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("💰 MONEY & CURRENCY", Color3.fromRGB(0, 255, 255))
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("", Color3.new(1, 1, 1))
    
    local count = 0
    
    -- Player Stats
    if player:FindFirstChild("leaderstats") then
        addResult("📊 PLAYER STATS:", Color3.fromRGB(100, 200, 255))
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            count = count + 1
            local value = tostring(stat.Value)
            addResult("  💰 " .. stat.Name .. " = " .. value, Color3.fromRGB(255, 215, 0))
        end
        addResult("", Color3.new(1, 1, 1))
    end
    
    -- ReplicatedStorage
    addResult("📦 REPLICATED STORAGE:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("money") or name:find("coin") or name:find("cash") or name:find("currency") then
            count = count + 1
            addResult("  💵 " .. obj:GetFullName(), Color3.fromRGB(0, 255, 100))
        end
    end
    
    addResult("", Color3.new(1, 1, 1))
    addResult("✅ Total: " .. count .. " money objects found", Color3.fromRGB(0, 255, 0))
    
    print("💰 Found " .. count .. " money objects")
end

local function scanImportant()
    clearResults()
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("⭐ IMPORTANT OBJECTS", Color3.fromRGB(0, 255, 255))
    addResult("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addResult("", Color3.new(1, 1, 1))
    
    local keywords = {
        "catch", "tame", "capture", "lasso", "rope", "purchase", "buy", "shop",
        "inventory", "equip", "tool", "spawn"
    }
    
    local count = 0
    
    addResult("📦 REPLICATED STORAGE:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        local name = obj.Name:lower()
        for _, keyword in pairs(keywords) do
            if name:find(keyword) then
                count = count + 1
                local icon = obj:IsA("RemoteEvent") and "📡" or obj:IsA("RemoteFunction") and "📞" or "⭐"
                addResult("  " .. icon .. " " .. obj:GetFullName(), Color3.fromRGB(200, 200, 255))
                break
            end
        end
    end
    
    addResult("", Color3.new(1, 1, 1))
    addResult("🌍 WORKSPACE FOLDERS:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") or obj:IsA("Model") then
            count = count + 1
            addResult("  📁 " .. obj.Name, Color3.fromRGB(150, 255, 150))
        end
    end
    
    addResult("", Color3.new(1, 1, 1))
    addResult("✅ Total: " .. count .. " important objects found", Color3.fromRGB(0, 255, 0))
    
    print("⭐ Found " .. count .. " important objects")
end

local function exportAll()
    clearResults()
    
    local export = [[
🔍 CATCH AND TAME - FULL SCAN RESULTS
═══════════════════════════════════════

📡 REMOTE EVENTS:
]]
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            export = export .. obj:GetFullName() .. "\n"
        end
    end
    
    export = export .. "\n📞 REMOTE FUNCTIONS:\n"
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            export = export .. obj:GetFullName() .. "\n"
        end
    end
    
    if copyToClipboard(export) then
        addResult("✅ FULL EXPORT COPIED TO CLIPBOARD!", Color3.fromRGB(0, 255, 0))
    else
        addResult("❌ Clipboard not available", Color3.fromRGB(255, 0, 0))
    end
    
    addResult("", Color3.new(1, 1, 1))
    addResult("═══ PREVIEW ═══", Color3.fromRGB(255, 255, 0))
    
    for line in export:gmatch("[^\n]+") do
        addResult(line, Color3.fromRGB(200, 200, 200))
    end
    
    print("📋 Export complete!")
end

-- Create Buttons
createButton("🔍 Remotes", Color3.fromRGB(255, 50, 50), scanRemotes)
createButton("🦁 Pets", Color3.fromRGB(255, 165, 0), scanPets)
createButton("💰 Money", Color3.fromRGB(255, 215, 0), scanMoney)
createButton("⭐ Important", Color3.fromRGB(100, 150, 255), scanImportant)
createButton("📋 Export", Color3.fromRGB(200, 50, 200), exportAll)

-- Initial message
addResult("👆 Click buttons to scan game structure", Color3.fromRGB(150, 150, 150))
addResult("💡 Click any result to copy to clipboard", Color3.fromRGB(150, 150, 150))

print("✅ Scanner loaded successfully!")
print("🔍 GUI ready - Click buttons to scan")
