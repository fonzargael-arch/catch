--[[
    🔍 GAME SCANNER - Linoria UI Library
    Compatible con Xeno y otros executors
    Con función de copiar al portapapeles
]]

print("═══════════════════════════════════")
print("🔍 Loading Scanner with Linoria UI...")
print("═══════════════════════════════════")

-- Load Linoria Library
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Storage
local scanData = {
    remotes = {},
    pets = {},
    money = {},
    important = {},
    tools = {}
}

-- Create Window
local Window = Library:CreateWindow({
    Title = '🔍 Game Structure Scanner',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Create Tabs
local Tabs = {
    Remotes = Window:AddTab('📡 Remotes'),
    Pets = Window:AddTab('🦁 Pets'),
    Money = Window:AddTab('💰 Money'),
    Important = Window:AddTab('⭐ Important'),
    Export = Window:AddTab('📋 Export')
}

-- Remotes Tab
local RemotesBox = Tabs.Remotes:AddLeftGroupbox('Remote Events & Functions')

RemotesBox:AddButton({
    Text = '🔍 Scan Remotes',
    Func = function()
        scanData.remotes = {}
        
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(scanData.remotes, {
                    type = "RemoteEvent",
                    path = obj:GetFullName(),
                    name = obj.Name
                })
            elseif obj:IsA("RemoteFunction") then
                table.insert(scanData.remotes, {
                    type = "RemoteFunction",
                    path = obj:GetFullName(),
                    name = obj.Name
                })
            end
        end
        
        Library:Notify('Found ' .. #scanData.remotes .. ' remotes!', 3)
    end,
    Tooltip = 'Scan for all RemoteEvents and RemoteFunctions'
})

RemotesBox:AddButton({
    Text = '📋 Copy All Remotes',
    Func = function()
        local text = "📡 REMOTES SCAN:\n" .. string.rep("=", 50) .. "\n\n"
        for _, remote in pairs(scanData.remotes) do
            text = text .. string.format("[%s] %s\n", remote.type, remote.path)
        end
        
        if setclipboard then
            setclipboard(text)
            Library:Notify('Copied ' .. #scanData.remotes .. ' remotes to clipboard!', 3)
        else
            Library:Notify('Clipboard not supported!', 3)
        end
    end,
    Tooltip = 'Copy all remotes to clipboard'
})

local RemotesDisplay = Tabs.Remotes:AddRightGroupbox('Results')
RemotesDisplay:AddLabel('Click "Scan Remotes" to start')

-- Pets Tab
local PetsBox = Tabs.Pets:AddLeftGroupbox('Pets & Animals Scanner')

PetsBox:AddButton({
    Text = '🔍 Scan Pets',
    Func = function()
        scanData.pets = {}
        local found = {}
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            local name = string.lower(obj.Name)
            local isPet = string.find(name, "animal") or 
                         string.find(name, "pet") or 
                         string.find(name, "hipopótamo") or
                         string.find(name, "hipopotamo") or
                         obj:FindFirstChild("Animal") or 
                         obj:FindFirstChild("Pet")
            
            if isPet and not found[obj:GetFullName()] then
                found[obj:GetFullName()] = true
                table.insert(scanData.pets, {
                    name = obj.Name,
                    path = obj:GetFullName(),
                    type = obj.ClassName
                })
            end
        end
        
        Library:Notify('Found ' .. #scanData.pets .. ' pets!', 3)
    end,
    Tooltip = 'Scan for all pets and animals'
})

PetsBox:AddButton({
    Text = '📋 Copy All Pets',
    Func = function()
        local text = "🦁 PETS SCAN:\n" .. string.rep("=", 50) .. "\n\n"
        for _, pet in pairs(scanData.pets) do
            text = text .. string.format("[%s] %s\n", pet.type, pet.path)
        end
        
        if setclipboard then
            setclipboard(text)
            Library:Notify('Copied ' .. #scanData.pets .. ' pets to clipboard!', 3)
        else
            Library:Notify('Clipboard not supported!', 3)
        end
    end,
    Tooltip = 'Copy all pets to clipboard'
})

local PetsDisplay = Tabs.Pets:AddRightGroupbox('Results')
PetsDisplay:AddLabel('Click "Scan Pets" to start')

-- Money Tab
local MoneyBox = Tabs.Money:AddLeftGroupbox('Money & Currency Scanner')

MoneyBox:AddButton({
    Text = '🔍 Scan Money',
    Func = function()
        scanData.money = {}
        
        -- Player Stats
        if player:FindFirstChild("leaderstats") then
            for _, stat in pairs(player.leaderstats:GetChildren()) do
                table.insert(scanData.money, {
                    type = "PlayerStat",
                    name = stat.Name,
                    value = tostring(stat.Value),
                    path = stat:GetFullName()
                })
            end
        end
        
        -- ReplicatedStorage
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            local name = string.lower(obj.Name)
            if string.find(name, "money") or string.find(name, "coin") or string.find(name, "cash") then
                table.insert(scanData.money, {
                    type = obj.ClassName,
                    name = obj.Name,
                    path = obj:GetFullName()
                })
            end
        end
        
        Library:Notify('Found ' .. #scanData.money .. ' money objects!', 3)
    end,
    Tooltip = 'Scan for money and currency'
})

MoneyBox:AddButton({
    Text = '📋 Copy All Money',
    Func = function()
        local text = "💰 MONEY SCAN:\n" .. string.rep("=", 50) .. "\n\n"
        for _, money in pairs(scanData.money) do
            if money.value then
                text = text .. string.format("[%s] %s = %s\n", money.type, money.name, money.value)
            else
                text = text .. string.format("[%s] %s\n", money.type, money.path)
            end
        end
        
        if setclipboard then
            setclipboard(text)
            Library:Notify('Copied ' .. #scanData.money .. ' money objects to clipboard!', 3)
        else
            Library:Notify('Clipboard not supported!', 3)
        end
    end,
    Tooltip = 'Copy all money objects to clipboard'
})

local MoneyDisplay = Tabs.Money:AddRightGroupbox('Results')
MoneyDisplay:AddLabel('Click "Scan Money" to start')

-- Important Tab
local ImportantBox = Tabs.Important:AddLeftGroupbox('Important Objects Scanner')

ImportantBox:AddButton({
    Text = '🔍 Scan Important',
    Func = function()
        scanData.important = {}
        local keywords = {"catch", "tame", "capture", "lasso", "rope", "purchase", "buy", "shop", "inventory"}
        
        -- ReplicatedStorage
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            local name = string.lower(obj.Name)
            for _, keyword in pairs(keywords) do
                if string.find(name, keyword) then
                    table.insert(scanData.important, {
                        type = obj.ClassName,
                        name = obj.Name,
                        path = obj:GetFullName(),
                        keyword = keyword
                    })
                    break
                end
            end
        end
        
        -- Workspace Folders
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Folder") or obj:IsA("Model") then
                table.insert(scanData.important, {
                    type = obj.ClassName,
                    name = obj.Name,
                    path = obj:GetFullName()
                })
            end
        end
        
        Library:Notify('Found ' .. #scanData.important .. ' important objects!', 3)
    end,
    Tooltip = 'Scan for important game objects'
})

ImportantBox:AddButton({
    Text = '📋 Copy All Important',
    Func = function()
        local text = "⭐ IMPORTANT SCAN:\n" .. string.rep("=", 50) .. "\n\n"
        for _, obj in pairs(scanData.important) do
            text = text .. string.format("[%s] %s\n", obj.type, obj.path)
        end
        
        if setclipboard then
            setclipboard(text)
            Library:Notify('Copied ' .. #scanData.important .. ' objects to clipboard!', 3)
        else
            Library:Notify('Clipboard not supported!', 3)
        end
    end,
    Tooltip = 'Copy all important objects to clipboard'
})

local ImportantDisplay = Tabs.Important:AddRightGroupbox('Results')
ImportantDisplay:AddLabel('Click "Scan Important" to start')

-- Export Tab
local ExportBox = Tabs.Export:AddLeftGroupbox('Export All Data')

ExportBox:AddButton({
    Text = '🔍 SCAN EVERYTHING',
    Func = function()
        -- Scan Remotes
        scanData.remotes = {}
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(scanData.remotes, {type = obj.ClassName, path = obj:GetFullName()})
            end
        end
        
        -- Scan Pets
        scanData.pets = {}
        local found = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            local name = string.lower(obj.Name)
            local isPet = string.find(name, "animal") or string.find(name, "pet") or 
                         string.find(name, "hipopótamo") or obj:FindFirstChild("Animal")
            if isPet and not found[obj:GetFullName()] then
                found[obj:GetFullName()] = true
                table.insert(scanData.pets, {type = obj.ClassName, path = obj:GetFullName()})
            end
        end
        
        -- Scan Money
        scanData.money = {}
        if player:FindFirstChild("leaderstats") then
            for _, stat in pairs(player.leaderstats:GetChildren()) do
                table.insert(scanData.money, {name = stat.Name, value = stat.Value})
            end
        end
        
        Library:Notify('Full scan complete!', 3)
    end,
    Tooltip = 'Scan all categories at once'
})

ExportBox:AddButton({
    Text = '📋 COPY FULL REPORT',
    Func = function()
        local text = [[
🔍 CATCH AND TAME - FULL GAME SCAN
════════════════════════════════════════════════

📡 REMOTE EVENTS & FUNCTIONS:
────────────────────────────────────────────────
]]
        
        for _, remote in pairs(scanData.remotes) do
            text = text .. string.format("[%s] %s\n", remote.type, remote.path)
        end
        
        text = text .. "\n🦁 PETS & ANIMALS:\n" .. string.rep("─", 52) .. "\n"
        for _, pet in pairs(scanData.pets) do
            text = text .. string.format("[%s] %s\n", pet.type, pet.path)
        end
        
        text = text .. "\n💰 MONEY & STATS:\n" .. string.rep("─", 52) .. "\n"
        for _, money in pairs(scanData.money) do
            if money.value then
                text = text .. string.format("%s = %s\n", money.name, tostring(money.value))
            end
        end
        
        text = text .. "\n⭐ IMPORTANT OBJECTS:\n" .. string.rep("─", 52) .. "\n"
        for _, obj in pairs(scanData.important) do
            text = text .. string.format("[%s] %s\n", obj.type, obj.path)
        end
        
        text = text .. "\n════════════════════════════════════════════════\n"
        text = text .. string.format("📊 SUMMARY:\n")
        text = text .. string.format("   Remotes: %d\n", #scanData.remotes)
        text = text .. string.format("   Pets: %d\n", #scanData.pets)
        text = text .. string.format("   Money Objects: %d\n", #scanData.money)
        text = text .. string.format("   Important: %d\n", #scanData.important)
        
        if setclipboard then
            setclipboard(text)
            Library:Notify('Full report copied to clipboard!', 5)
        else
            Library:Notify('Clipboard not supported!', 3)
        end
    end,
    Tooltip = 'Copy complete scan report'
})

ExportBox:AddDivider()

ExportBox:AddLabel('Quick Actions:')

ExportBox:AddButton({
    Text = '🖨️ Print to Console',
    Func = function()
        print("\n\n" .. string.rep("═", 50))
        print("🔍 GAME SCAN RESULTS")
        print(string.rep("═", 50))
        
        print("\n📡 REMOTES: " .. #scanData.remotes)
        for i, remote in pairs(scanData.remotes) do
            if i <= 10 then
                print("  " .. remote.path)
            end
        end
        
        print("\n🦁 PETS: " .. #scanData.pets)
        for i, pet in pairs(scanData.pets) do
            if i <= 10 then
                print("  " .. pet.path)
            end
        end
        
        print("\n" .. string.rep("═", 50) .. "\n")
        
        Library:Notify('Results printed to console!', 3)
    end,
    Tooltip = 'Print results to executor console'
})

local ExportInfo = Tabs.Export:AddRightGroupbox('Information')
ExportInfo:AddLabel('1. Click "SCAN EVERYTHING"')
ExportInfo:AddLabel('2. Click "COPY FULL REPORT"')
ExportInfo:AddLabel('3. Paste results anywhere!')
ExportInfo:AddDivider()
ExportInfo:AddLabel('Status: Ready to scan')

-- UI Settings
Library:SetWatermarkVisibility(true)
Library:SetWatermark('Game Scanner | Linoria UI')

-- Theme Manager
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('GameScanner')
ThemeManager:ApplyToTab(Window:AddTab('⚙️ Settings'))

-- Notifications
Library:Notify('Scanner loaded successfully!', 5)

print("✅ Scanner with Linoria UI loaded!")
print("📋 Use the Export tab to copy all results")
