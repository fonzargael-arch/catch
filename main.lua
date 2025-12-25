--[[
    🔍 GAME STRUCTURE SCANNER
    ═══════════════════════════════════════
    Compatible con Xeno - SIN CoreGui
]]

print("═══════════════════════════════════")
print("🔍 Starting Scanner...")
print("═══════════════════════════════════")

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Safe clipboard
local function copyText(text)
    pcall(function()
        if setclipboard then
            setclipboard(text)
        elseif toclipboard then
            toclipboard(text)
        end
    end)
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Scanner"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 500)
Main.Position = UDim2.new(0.5, -350, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 10)
Corner1.Parent = Main

local Stroke1 = Instance.new("UIStroke")
Stroke1.Color = Color3.fromRGB(0, 255, 255)
Stroke1.Thickness = 3
Stroke1.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "🔍 GAME SCANNER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BorderSizePixel = 0
Title.Parent = Main

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 10)
Corner2.Parent = Title

-- Close
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.Parent = Title

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 8)
Corner3.Parent = Close

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Buttons
local BtnFrame = Instance.new("Frame")
BtnFrame.Size = UDim2.new(1, -20, 0, 50)
BtnFrame.Position = UDim2.new(0, 10, 0, 55)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Parent = Main

local BtnLayout = Instance.new("UIListLayout")
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.Padding = UDim.new(0, 8)
BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
BtnLayout.Parent = BtnFrame

-- Results
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -125)
Scroll.Position = UDim2.new(0, 10, 0, 115)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 8
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local Corner4 = Instance.new("UICorner")
Corner4.CornerRadius = UDim.new(0, 8)
Corner4.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 3)
Layout.Parent = Scroll

-- Functions
local function makeButton(txt, col, func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 1, 0)
    btn.BackgroundColor3 = col
    btn.Text = txt
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = BtnFrame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(0.1)
        btn.BackgroundColor3 = col
        pcall(func)
    end)
end

local function addLine(txt, col)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 22)
    lbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    lbl.Text = " " .. txt
    lbl.TextColor3 = col or Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = Scroll
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = lbl
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = lbl
    
    btn.MouseButton1Click:Connect(function()
        copyText(txt)
        lbl.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.wait(0.2)
        lbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)
end

local function clear()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("TextLabel") then
            v:Destroy()
        end
    end
end

-- Scans
local function scanRemotes()
    clear()
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("📡 REMOTE EVENTS & FUNCTIONS", Color3.fromRGB(0, 255, 255))
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("", Color3.new(1, 1, 1))
    
    local count = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            count = count + 1
            addLine("📡 " .. obj:GetFullName(), Color3.fromRGB(255, 100, 100))
        elseif obj:IsA("RemoteFunction") then
            count = count + 1
            addLine("📞 " .. obj:GetFullName(), Color3.fromRGB(255, 150, 100))
        end
    end
    
    addLine("", Color3.new(1, 1, 1))
    addLine("✅ Total: " .. count, Color3.fromRGB(0, 255, 0))
    print("Found " .. count .. " remotes")
end

local function scanPets()
    clear()
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("🦁 PETS & ANIMALS", Color3.fromRGB(0, 255, 255))
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("", Color3.new(1, 1, 1))
    
    local count = 0
    local seen = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local check = name:find("animal") or name:find("pet") or 
                     name:find("hipopótamo") or name:find("hipopotamo") or
                     obj:FindFirstChild("Animal") or obj:FindFirstChild("Pet")
        
        if check and not seen[obj:GetFullName()] then
            count = count + 1
            seen[obj:GetFullName()] = true
            local icon = obj:IsA("Model") and "📦" or "🔷"
            addLine(icon .. " " .. obj:GetFullName(), Color3.fromRGB(255, 200, 0))
        end
    end
    
    addLine("", Color3.new(1, 1, 1))
    addLine("✅ Total: " .. count, Color3.fromRGB(0, 255, 0))
    print("Found " .. count .. " pets")
end

local function scanMoney()
    clear()
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("💰 MONEY & STATS", Color3.fromRGB(0, 255, 255))
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("", Color3.new(1, 1, 1))
    
    local count = 0
    
    if player:FindFirstChild("leaderstats") then
        addLine("📊 PLAYER STATS:", Color3.fromRGB(100, 200, 255))
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            count = count + 1
            addLine("  💰 " .. stat.Name .. " = " .. tostring(stat.Value), Color3.fromRGB(255, 215, 0))
        end
        addLine("", Color3.new(1, 1, 1))
    end
    
    addLine("📦 REPLICATEDSTORAGE:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("money") or name:find("coin") or name:find("cash") then
            count = count + 1
            addLine("  💵 " .. obj:GetFullName(), Color3.fromRGB(0, 255, 100))
        end
    end
    
    addLine("", Color3.new(1, 1, 1))
    addLine("✅ Total: " .. count, Color3.fromRGB(0, 255, 0))
    print("Found " .. count .. " money objects")
end

local function scanAll()
    clear()
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("⭐ IMPORTANT OBJECTS", Color3.fromRGB(0, 255, 255))
    addLine("═══════════════════════════════════", Color3.fromRGB(0, 255, 255))
    addLine("", Color3.new(1, 1, 1))
    
    local keywords = {"catch", "tame", "capture", "lasso", "rope", "purchase", "buy", "shop"}
    local count = 0
    
    addLine("📦 REPLICATEDSTORAGE:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        local name = obj.Name:lower()
        for _, word in pairs(keywords) do
            if name:find(word) then
                count = count + 1
                local icon = obj:IsA("RemoteEvent") and "📡" or obj:IsA("RemoteFunction") and "📞" or "⭐"
                addLine("  " .. icon .. " " .. obj:GetFullName(), Color3.fromRGB(200, 200, 255))
                break
            end
        end
    end
    
    addLine("", Color3.new(1, 1, 1))
    addLine("🌍 WORKSPACE:", Color3.fromRGB(100, 200, 255))
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") or obj:IsA("Model") then
            count = count + 1
            addLine("  📁 " .. obj.Name, Color3.fromRGB(150, 255, 150))
        end
    end
    
    addLine("", Color3.new(1, 1, 1))
    addLine("✅ Total: " .. count, Color3.fromRGB(0, 255, 0))
    print("Found " .. count .. " objects")
end

local function exportAll()
    clear()
    
    local txt = "🔍 GAME SCAN\n═══════════════\n\n📡 REMOTES:\n"
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            txt = txt .. obj:GetFullName() .. "\n"
        end
    end
    
    copyText(txt)
    addLine("✅ COPIED TO CLIPBOARD!", Color3.fromRGB(0, 255, 0))
    addLine("", Color3.new(1, 1, 1))
    
    for line in txt:gmatch("[^\n]+") do
        addLine(line, Color3.fromRGB(200, 200, 200))
    end
    
    print("Exported!")
end

-- Create Buttons
makeButton("🔍 Remotes", Color3.fromRGB(255, 50, 50), scanRemotes)
makeButton("🦁 Pets", Color3.fromRGB(255, 165, 0), scanPets)
makeButton("💰 Money", Color3.fromRGB(255, 215, 0), scanMoney)
makeButton("⭐ All", Color3.fromRGB(100, 150, 255), scanAll)
makeButton("📋 Export", Color3.fromRGB(200, 50, 200), exportAll)

-- Start
addLine("👆 Click buttons to scan", Color3.fromRGB(150, 150, 150))
addLine("💡 Click results to copy", Color3.fromRGB(150, 150, 150))

print("✅ Scanner loaded!")
