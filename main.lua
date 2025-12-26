--[[
    ═══════════════════════════════════════
    🔍 GF GAME SCANNER
    ═══════════════════════════════════════
    Created by: Gael Fonzar
    Detects: Scripts, RemoteEvents, Assets, 
    Security, Important Objects & More
    ═══════════════════════════════════════
]]

-- Load Linoria Library
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer

-- Scan Results
local scanResults = {
    LocalScripts = {},
    Scripts = {},
    ModuleScripts = {},
    RemoteEvents = {},
    RemoteFunctions = {},
    BindableEvents = {},
    BindableFunctions = {},
    ValueObjects = {},
    Tools = {},
    Animations = {},
    Sounds = {},
    Decals = {},
    Textures = {},
    MeshParts = {},
    SpecialMeshes = {},
    ParticleEmitters = {},
    Lights = {},
    GUIs = {},
    AntiCheats = {},
    Important = {}
}

local scanStats = {
    totalObjects = 0,
    scannedObjects = 0,
    suspiciousObjects = 0
}

-- Create Window
local Window = Library:CreateWindow({
    Title = '🔍 GF Game Scanner',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Scanner = Window:AddTab('🔍 Scanner'),
    Scripts = Window:AddTab('📜 Scripts'),
    Remotes = Window:AddTab('📡 Remotes'),
    Assets = Window:AddTab('🎨 Assets'),
    Security = Window:AddTab('🛡️ Security'),
    Results = Window:AddTab('📊 Results')
}

-- ═══════════════════════════════════════
-- 🔍 SCANNER TAB
-- ═══════════════════════════════════════
local ScanBox = Tabs.Scanner:AddLeftGroupbox('Quick Scan')

local scanProgress = ScanBox:AddLabel('Ready to scan...')
local scanStatus = ScanBox:AddLabel('Status: Idle')

ScanBox:AddButton({
    Text = '🔍 START FULL SCAN',
    Func = function()
        Library:Notify('Starting full game scan...', 3)
        scanProgress:SetText('Scanning: 0%')
        scanStatus:SetText('Status: Scanning...')
        
        -- Reset results
        for k, v in pairs(scanResults) do
            if type(v) == "table" then
                scanResults[k] = {}
            end
        end
        scanStats.totalObjects = 0
        scanStats.scannedObjects = 0
        scanStats.suspiciousObjects = 0
        
        task.spawn(function()
            performFullScan()
            scanProgress:SetText('Scan Complete!')
            scanStatus:SetText('Status: Complete ✅')
            Library:Notify('Scan completed! Check results.', 4)
        end)
    end
})

ScanBox:AddDivider()

local QuickActions = ScanBox:AddLabel('Quick Actions:')

ScanBox:AddButton({
    Text = '📜 Scan Scripts Only',
    Func = function()
        Library:Notify('Scanning scripts...', 2)
        scanScriptsOnly()
    end
})

ScanBox:AddButton({
    Text = '📡 Scan Remotes Only',
    Func = function()
        Library:Notify('Scanning remotes...', 2)
        scanRemotesOnly()
    end
})

ScanBox:AddButton({
    Text = '🛡️ Detect Anti-Cheat',
    Func = function()
        Library:Notify('Detecting anti-cheat...', 2)
        detectAntiCheat()
    end
})

local InfoBox = Tabs.Scanner:AddRightGroupbox('Scan Information')

InfoBox:AddLabel('What this scanner detects:')
InfoBox:AddDivider()
InfoBox:AddLabel('📜 All Scripts (Local/Server/Module)')
InfoBox:AddLabel('📡 Remote Events & Functions')
InfoBox:AddLabel('🎨 Assets (Meshes, Textures, Sounds)')
InfoBox:AddLabel('🛡️ Anti-Cheat Systems')
InfoBox:AddLabel('💎 Rare/Important Objects')
InfoBox:AddLabel('🎮 Tools & Animations')
InfoBox:AddLabel('💡 Lights & Particles')
InfoBox:AddLabel('🖼️ GUIs & Decals')

-- ═══════════════════════════════════════
-- 📜 SCRIPTS TAB
-- ═══════════════════════════════════════
local ScriptsBox = Tabs.Scripts:AddLeftGroupbox('Script Results')

local scriptsList = ScriptsBox:AddLabel('No scripts scanned yet')
local scriptsCount = ScriptsBox:AddLabel('Total: 0')

ScriptsBox:AddDivider()

ScriptsBox:AddButton({
    Text = '📋 Copy All Script Paths',
    Func = function()
        local paths = ""
        for _, script in pairs(scanResults.LocalScripts) do
            paths = paths .. script.Path .. "\n"
        end
        for _, script in pairs(scanResults.Scripts) do
            paths = paths .. script.Path .. "\n"
        end
        for _, script in pairs(scanResults.ModuleScripts) do
            paths = paths .. script.Path .. "\n"
        end
        setclipboard(paths)
        Library:Notify('Script paths copied!', 2)
    end
})

local ModulesBox = Tabs.Scripts:AddRightGroupbox('Module Scripts')
local modulesList = ModulesBox:AddLabel('No modules found')

-- ═══════════════════════════════════════
-- 📡 REMOTES TAB
-- ═══════════════════════════════════════
local RemotesBox = Tabs.Remotes:AddLeftGroupbox('Remote Events')

local remotesList = RemotesBox:AddLabel('No remotes scanned yet')
local remotesCount = RemotesBox:AddLabel('Total: 0')

RemotesBox:AddDivider()

RemotesBox:AddButton({
    Text = '📋 Copy Remote Paths',
    Func = function()
        local paths = ""
        for _, remote in pairs(scanResults.RemoteEvents) do
            paths = paths .. remote.Path .. "\n"
        end
        for _, remote in pairs(scanResults.RemoteFunctions) do
            paths = paths .. remote.Path .. "\n"
        end
        setclipboard(paths)
        Library:Notify('Remote paths copied!', 2)
    end
})

local FunctionsBox = Tabs.Remotes:AddRightGroupbox('Remote Functions')
local functionsList = FunctionsBox:AddLabel('No functions found')

-- ═══════════════════════════════════════
-- 🎨 ASSETS TAB
-- ═══════════════════════════════════════
local AssetsBox = Tabs.Assets:AddLeftGroupbox('Asset Summary')

local soundsLabel = AssetsBox:AddLabel('🔊 Sounds: 0')
local meshesLabel = AssetsBox:AddLabel('🗿 Meshes: 0')
local texturesLabel = AssetsBox:AddLabel('🖼️ Textures: 0')
local animationsLabel = AssetsBox:AddLabel('🎬 Animations: 0')
local particlesLabel = AssetsBox:AddLabel('✨ Particles: 0')
local lightsLabel = AssetsBox:AddLabel('💡 Lights: 0')

AssetsBox:AddDivider()

AssetsBox:AddButton({
    Text = '📋 Export Asset IDs',
    Func = function()
        local assetData = "=== GF GAME SCANNER - ASSETS ===\n\n"
        
        assetData = assetData .. "SOUNDS (" .. #scanResults.Sounds .. "):\n"
        for _, sound in pairs(scanResults.Sounds) do
            assetData = assetData .. "- " .. sound.Name .. " | ID: " .. sound.SoundId .. "\n"
        end
        
        assetData = assetData .. "\nANIMATIONS (" .. #scanResults.Animations .. "):\n"
        for _, anim in pairs(scanResults.Animations) do
            assetData = assetData .. "- " .. anim.Name .. " | ID: " .. anim.AnimationId .. "\n"
        end
        
        assetData = assetData .. "\nMESHES (" .. #scanResults.MeshParts .. "):\n"
        for _, mesh in pairs(scanResults.MeshParts) do
            assetData = assetData .. "- " .. mesh.Name .. " | ID: " .. mesh.MeshId .. "\n"
        end
        
        setclipboard(assetData)
        Library:Notify('Asset data copied!', 2)
    end
})

local ToolsBox = Tabs.Assets:AddRightGroupbox('Tools & Items')
local toolsList = ToolsBox:AddLabel('No tools found')

-- ═══════════════════════════════════════
-- 🛡️ SECURITY TAB
-- ═══════════════════════════════════════
local SecurityBox = Tabs.Security:AddLeftGroupbox('Security Analysis')

local antiCheatLabel = SecurityBox:AddLabel('Anti-Cheat: Not detected')
local suspiciousLabel = SecurityBox:AddLabel('Suspicious Objects: 0')

SecurityBox:AddDivider()

local securityList = SecurityBox:AddLabel('Security findings will appear here...')

local TipsBox = Tabs.Security:AddRightGroupbox('Security Tips')
TipsBox:AddLabel('Common Anti-Cheat Names:')
TipsBox:AddLabel('• AntiCheat, AC, Security')
TipsBox:AddLabel('• Detect, Monitor, Check')
TipsBox:AddLabel('• Anti, Ban, Kick')
TipsBox:AddDivider()
TipsBox:AddLabel('Suspicious Patterns:')
TipsBox:AddLabel('• Scripts checking speed/position')
TipsBox:AddLabel('• Remote spam detection')
TipsBox:AddLabel('• Hidden/obfuscated code')

-- ═══════════════════════════════════════
-- 📊 RESULTS TAB
-- ═══════════════════════════════════════
local StatsBox = Tabs.Results:AddLeftGroupbox('Scan Statistics')

local totalObjectsLabel = StatsBox:AddLabel('Total Objects: 0')
local scriptsFoundLabel = StatsBox:AddLabel('Scripts Found: 0')
local remotesFoundLabel = StatsBox:AddLabel('Remotes Found: 0')
local assetsFoundLabel = StatsBox:AddLabel('Assets Found: 0')
local importantLabel = StatsBox:AddLabel('Important: 0')

StatsBox:AddDivider()

StatsBox:AddButton({
    Text = '📄 Export Full Report',
    Func = function()
        exportFullReport()
    end
})

local ImportantBox = Tabs.Results:AddRightGroupbox('Important Findings')
local importantList = ImportantBox:AddLabel('Important objects will be listed here')

-- ═══════════════════════════════════════
-- 🔍 SCANNING FUNCTIONS
-- ═══════════════════════════════════════

local function getPath(obj)
    local path = obj.Name
    local current = obj.Parent
    while current and current ~= game do
        path = current.Name .. "." .. path
        current = current.Parent
    end
    return path
end

local function isAntiCheatName(name)
    local keywords = {
        "anticheat", "anti", "cheat", "detect", "ban", "kick", "monitor",
        "security", "check", "exploit", "hack", "guard", "protect", "ac"
    }
    local lowerName = name:lower()
    for _, keyword in pairs(keywords) do
        if lowerName:find(keyword) then
            return true
        end
    end
    return false
end

local function scanObject(obj)
    scanStats.scannedObjects = scanStats.scannedObjects + 1
    
    -- Update progress
    local progress = math.floor((scanStats.scannedObjects / scanStats.totalObjects) * 100)
    scanProgress:SetText('Scanning: ' .. progress .. '%')
    
    -- Scan based on object type
    if obj:IsA("LocalScript") then
        table.insert(scanResults.LocalScripts, {
            Name = obj.Name,
            Path = getPath(obj),
            Parent = obj.Parent.Name,
            Disabled = obj.Disabled
        })
        if isAntiCheatName(obj.Name) then
            table.insert(scanResults.AntiCheats, {Type = "LocalScript", Name = obj.Name, Path = getPath(obj)})
            scanStats.suspiciousObjects = scanStats.suspiciousObjects + 1
        end
        
    elseif obj:IsA("Script") then
        table.insert(scanResults.Scripts, {
            Name = obj.Name,
            Path = getPath(obj),
            Parent = obj.Parent.Name,
            Disabled = obj.Disabled
        })
        if isAntiCheatName(obj.Name) then
            table.insert(scanResults.AntiCheats, {Type = "Script", Name = obj.Name, Path = getPath(obj)})
            scanStats.suspiciousObjects = scanStats.suspiciousObjects + 1
        end
        
    elseif obj:IsA("ModuleScript") then
        table.insert(scanResults.ModuleScripts, {
            Name = obj.Name,
            Path = getPath(obj),
            Parent = obj.Parent.Name
        })
        if isAntiCheatName(obj.Name) then
            table.insert(scanResults.AntiCheats, {Type = "ModuleScript", Name = obj.Name, Path = getPath(obj)})
            scanStats.suspiciousObjects = scanStats.suspiciousObjects + 1
        end
        
    elseif obj:IsA("RemoteEvent") then
        table.insert(scanResults.RemoteEvents, {
            Name = obj.Name,
            Path = getPath(obj)
        })
        table.insert(scanResults.Important, {Type = "RemoteEvent", Name = obj.Name, Path = getPath(obj)})
        
    elseif obj:IsA("RemoteFunction") then
        table.insert(scanResults.RemoteFunctions, {
            Name = obj.Name,
            Path = getPath(obj)
        })
        table.insert(scanResults.Important, {Type = "RemoteFunction", Name = obj.Name, Path = getPath(obj)})
        
    elseif obj:IsA("BindableEvent") then
        table.insert(scanResults.BindableEvents, {
            Name = obj.Name,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("BindableFunction") then
        table.insert(scanResults.BindableFunctions, {
            Name = obj.Name,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("Tool") then
        table.insert(scanResults.Tools, {
            Name = obj.Name,
            Path = getPath(obj)
        })
        table.insert(scanResults.Important, {Type = "Tool", Name = obj.Name, Path = getPath(obj)})
        
    elseif obj:IsA("Sound") then
        table.insert(scanResults.Sounds, {
            Name = obj.Name,
            SoundId = obj.SoundId,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("Animation") then
        table.insert(scanResults.Animations, {
            Name = obj.Name,
            AnimationId = obj.AnimationId,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("MeshPart") then
        table.insert(scanResults.MeshParts, {
            Name = obj.Name,
            MeshId = obj.MeshId,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("SpecialMesh") then
        table.insert(scanResults.SpecialMeshes, {
            Name = obj.Name,
            MeshId = obj.MeshId,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("Decal") then
        table.insert(scanResults.Decals, {
            Name = obj.Name,
            Texture = obj.Texture,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("Texture") then
        table.insert(scanResults.Textures, {
            Name = obj.Name,
            Texture = obj.Texture,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("ParticleEmitter") then
        table.insert(scanResults.ParticleEmitters, {
            Name = obj.Name,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("Light") then
        table.insert(scanResults.Lights, {
            Name = obj.Name,
            Type = obj.ClassName,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("ScreenGui") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
        table.insert(scanResults.GUIs, {
            Name = obj.Name,
            Type = obj.ClassName,
            Path = getPath(obj)
        })
        
    elseif obj:IsA("ValueBase") then
        table.insert(scanResults.ValueObjects, {
            Name = obj.Name,
            Type = obj.ClassName,
            Path = getPath(obj)
        })
    end
end

local function countAllObjects(parent)
    local count = 0
    for _, obj in pairs(parent:GetDescendants()) do
        count = count + 1
    end
    return count
end

function performFullScan()
    -- Count total objects
    scanStats.totalObjects = 
        countAllObjects(Workspace) +
        countAllObjects(ReplicatedStorage) +
        countAllObjects(Lighting) +
        countAllObjects(StarterGui) +
        countAllObjects(StarterPlayer) +
        countAllObjects(player.PlayerGui) +
        countAllObjects(player.Character or Instance.new("Folder"))
    
    -- Scan all locations
    local locations = {
        Workspace,
        ReplicatedStorage,
        Lighting,
        StarterGui,
        StarterPlayer,
        player.PlayerGui
    }
    
    if player.Character then
        table.insert(locations, player.Character)
    end
    
    for _, location in pairs(locations) do
        for _, obj in pairs(location:GetDescendants()) do
            scanObject(obj)
        end
    end
    
    -- Update UI with results
    updateResultsUI()
end

function scanScriptsOnly()
    for _, location in pairs({Workspace, ReplicatedStorage, StarterGui, StarterPlayer, player.PlayerGui}) do
        for _, obj in pairs(location:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("ModuleScript") then
                scanObject(obj)
            end
        end
    end
    updateResultsUI()
end

function scanRemotesOnly()
    for _, location in pairs({ReplicatedStorage, Workspace}) do
        for _, obj in pairs(location:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                scanObject(obj)
            end
        end
    end
    updateResultsUI()
end

function detectAntiCheat()
    scanResults.AntiCheats = {}
    for _, location in pairs({Workspace, ReplicatedStorage, StarterPlayer}) do
        for _, obj in pairs(location:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                if isAntiCheatName(obj.Name) then
                    table.insert(scanResults.AntiCheats, {
                        Type = obj.ClassName,
                        Name = obj.Name,
                        Path = getPath(obj)
                    })
                end
            end
        end
    end
    
    if #scanResults.AntiCheats > 0 then
        antiCheatLabel:SetText('⚠️ Anti-Cheat DETECTED: ' .. #scanResults.AntiCheats .. ' instances')
        local acList = "Detected:\n"
        for _, ac in pairs(scanResults.AntiCheats) do
            acList = acList .. "• " .. ac.Name .. " (" .. ac.Type .. ")\n"
        end
        securityList:SetText(acList)
        Library:Notify('⚠️ Anti-cheat detected!', 4)
    else
        antiCheatLabel:SetText('✅ No Anti-Cheat detected')
        securityList:SetText('No obvious anti-cheat found')
        Library:Notify('No anti-cheat detected', 3)
    end
end

function updateResultsUI()
    -- Scripts Tab
    local scriptCount = #scanResults.LocalScripts + #scanResults.Scripts
    scriptsCount:SetText('Total Scripts: ' .. scriptCount)
    
    local scriptText = "LocalScripts: " .. #scanResults.LocalScripts .. "\n"
    scriptText = scriptText .. "Server Scripts: " .. #scanResults.Scripts .. "\n"
    scriptText = scriptText .. "\nRecent LocalScripts:\n"
    for i = 1, math.min(10, #scanResults.LocalScripts) do
        scriptText = scriptText .. "• " .. scanResults.LocalScripts[i].Name .. "\n"
    end
    scriptsList:SetText(scriptText)
    
    modulesList:SetText("Module Scripts: " .. #scanResults.ModuleScripts)
    
    -- Remotes Tab
    remotesCount:SetText('Total Remotes: ' .. (#scanResults.RemoteEvents + #scanResults.RemoteFunctions))
    
    local remoteText = "RemoteEvents:\n"
    for i = 1, math.min(15, #scanResults.RemoteEvents) do
        remoteText = remoteText .. "• " .. scanResults.RemoteEvents[i].Name .. "\n"
    end
    remotesList:SetText(remoteText)
    
    local funcText = "RemoteFunctions:\n"
    for i = 1, math.min(10, #scanResults.RemoteFunctions) do
        funcText = funcText .. "• " .. scanResults.RemoteFunctions[i].Name .. "\n"
    end
    functionsList:SetText(funcText)
    
    -- Assets Tab
    soundsLabel:SetText('🔊 Sounds: ' .. #scanResults.Sounds)
    meshesLabel:SetText('🗿 Meshes: ' .. #scanResults.MeshParts)
    texturesLabel:SetText('🖼️ Textures: ' .. #scanResults.Textures)
    animationsLabel:SetText('🎬 Animations: ' .. #scanResults.Animations)
    particlesLabel:SetText('✨ Particles: ' .. #scanResults.ParticleEmitters)
    lightsLabel:SetText('💡 Lights: ' .. #scanResults.Lights)
    
    local toolText = "Tools Found: " .. #scanResults.Tools .. "\n"
    for i = 1, math.min(10, #scanResults.Tools) do
        toolText = toolText .. "• " .. scanResults.Tools[i].Name .. "\n"
    end
    toolsList:SetText(toolText)
    
    -- Security Tab
    suspiciousLabel:SetText('Suspicious Objects: ' .. scanStats.suspiciousObjects)
    
    -- Results Tab
    totalObjectsLabel:SetText('Total Objects Scanned: ' .. scanStats.scannedObjects)
    scriptsFoundLabel:SetText('Scripts Found: ' .. scriptCount)
    remotesFoundLabel:SetText('Remotes Found: ' .. (#scanResults.RemoteEvents + #scanResults.RemoteFunctions))
    assetsFoundLabel:SetText('Assets Found: ' .. (#scanResults.Sounds + #scanResults.Animations + #scanResults.MeshParts))
    importantLabel:SetText('Important Objects: ' .. #scanResults.Important)
    
    local impText = "Important Findings:\n"
    for i = 1, math.min(15, #scanResults.Important) do
        impText = impText .. "• [" .. scanResults.Important[i].Type .. "] " .. scanResults.Important[i].Name .. "\n"
    end
    importantList:SetText(impText)
end

function exportFullReport()
    local report = "═══════════════════════════════════════\n"
    report = report .. "🔍 GF GAME SCANNER - FULL REPORT\n"
    report = report .. "═══════════════════════════════════════\n\n"
    
    report = report .. "📊 STATISTICS:\n"
    report = report .. "Total Objects Scanned: " .. scanStats.scannedObjects .. "\n"
    report = report .. "Suspicious Objects: " .. scanStats.suspiciousObjects .. "\n\n"
    
    report = report .. "📜 SCRIPTS (" .. (#scanResults.LocalScripts + #scanResults.Scripts) .. "):\n"
    report = report .. "LocalScripts: " .. #scanResults.LocalScripts .. "\n"
    report = report .. "Server Scripts: " .. #scanResults.Scripts .. "\n"
    report = report .. "Module Scripts: " .. #scanResults.ModuleScripts .. "\n\n"
    
    report = report .. "📡 REMOTES (" .. (#scanResults.RemoteEvents + #scanResults.RemoteFunctions) .. "):\n"
    for _, remote in pairs(scanResults.RemoteEvents) do
        report = report .. "• [Event] " .. remote.Name .. " - " .. remote.Path .. "\n"
    end
    for _, remote in pairs(scanResults.RemoteFunctions) do
        report = report .. "• [Function] " .. remote.Name .. " - " .. remote.Path .. "\n"
    end
    report = report .. "\n"
    
    report = report .. "🎨 ASSETS:\n"
    report = report .. "Sounds: " .. #scanResults.Sounds .. "\n"
    report = report .. "Animations: " .. #scanResults.Animations .. "\n"
    report = report .. "Meshes: " .. #scanResults.MeshParts .. "\n"
    report = report .. "Particles: " .. #scanResults.ParticleEmitters .. "\n"
    report = report .. "Lights: " .. #scanResults.Lights .. "\n\n"
    
    report = report .. "🛡️ SECURITY:\n"
    if #scanResults.AntiCheats > 0 then
        report = report .. "⚠️ ANTI-CHEAT DETECTED:\n"
        for _, ac in pairs(scanResults.AntiCheats) do
            report = report .. "• " .. ac.Name .. " (" .. ac.Type .. ") - " .. ac.Path .. "\n"
        end
    else
        report = report .. "✅ No obvious anti-cheat detected\n"
    end
    
    report = report .. "\n═══════════════════════════════════════\n"
    report = report .. "Report generated by GF Game Scanner\n"
    report = report .. "Created by: Gael Fonzar\n"
    report = report .. "═══════════════════════════════════════"
    
    setclipboard(report)
    Library:Notify('Full report copied to clipboard!', 4)
end

-- ═══════════════════════════════════════
-- ⚙️ SETTINGS
-- ═══════════════════════════════════════
local MenuGroup = Tabs.Scanner:AddRightGroupbox('Menu Settings')
MenuGroup:AddButton('Unload Scanner', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('GFHub')
ThemeManager:ApplyToTab(Tabs.Scanner)

-- Startup
Library:Notify('🔍 GF Game Scanner loaded!', 3)
Library:Notify('Press START FULL SCAN to begin', 4)

print("═══════════════════════════════════")
print("🔍 GF Game Scanner Loaded!")
print("Created by: Gael Fonzar")
print("═══════════════════════════════════")
