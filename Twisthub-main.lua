-- Twist Hub is the best
local _ = string.char(87,65,82,78,73,78,71,58,32,68,79,32,78,79,84,32,69,68,73,84,10,79,119,110,101,114,58,32,54,100,97,121,49,51)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()

connections = connections or {}
mainConns = mainConns or {}
unloaded = false

-- Variabel Global
local noclipEnabled = false
local noFogEnabled = false
local antiArtfulEnabled = false
local fastArtfulEnabled = false

local Storage = CoreGui:FindFirstChild("Highlight_Storage") or Instance.new("Folder")
Storage.Name = "Highlight_Storage"
Storage.Parent = CoreGui

local espConfigs = {
    Survivor = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,0),   OutlineColor=Color3.fromRGB(0,255,0),   FillTransparency=0.5, OutlineTransparency=0},
    Killer   = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(255,0,0),   OutlineColor=Color3.fromRGB(255,0,0),   FillTransparency=0.5, OutlineTransparency=0},
    Ghost    = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,255), OutlineColor=Color3.fromRGB(0,255,255), FillTransparency=0.5, OutlineTransparency=0},
}

local Rayfield
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    Rayfield = (ok and lib and lib.CreateWindow) and lib or nil
end

local Window = Rayfield:CreateWindow({
    Name = "Twist Hub",
    LoadingTitle = "Use this at ur own risk",
    LoadingSubtitle = "by twist",
    ConfigurationSaving = {Enabled = false},
    KeySystem = true,
    KeySettings = {
        Title = "Twist Hub | Key System",
        Subtitle = "Enter key to continue",
        Note = "Key is: twist-key-2026",
        FileName = "TwistKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"twist-key-2026"}
    }
})

-- ========== TAB ESP ==========
local tabEsp = Window:CreateTab("Esp", 4483362458)
tabEsp:CreateSection("Survivor ESP")
tabEsp:CreateToggle({Name = "Survivor Enabled", CurrentValue = espConfigs.Survivor.Enabled, Callback = function(v) espConfigs.Survivor.Enabled = v end})
tabEsp:CreateToggle({Name = "Survivor Name", CurrentValue = espConfigs.Survivor.Name, Callback = function(v) espConfigs.Survivor.Name = v end})
tabEsp:CreateToggle({Name = "Survivor HP", CurrentValue = espConfigs.Survivor.HP, Callback = function(v) espConfigs.Survivor.HP = v end})

tabEsp:CreateSection("Killer ESP")
tabEsp:CreateToggle({Name = "Killer Enabled", CurrentValue = espConfigs.Killer.Enabled, Callback = function(v) espConfigs.Killer.Enabled = v end})
tabEsp:CreateToggle({Name = "Killer Name", CurrentValue = espConfigs.Killer.Name, Callback = function(v) espConfigs.Killer.Name = v end})
tabEsp:CreateToggle({Name = "Killer HP", CurrentValue = espConfigs.Killer.HP, Callback = function(v) espConfigs.Killer.HP = v end})

-- ========== TAB AUTO BLOCK ==========
local tabAutoBlock = Window:CreateTab("Auto Block", 4483362458)
local BLOCK_DISTANCE = 15
local noM1Blocking = false

tabAutoBlock:CreateToggle({Name = "No m1 blocking (you killer)", CurrentValue = noM1Blocking, Callback = function(v) noM1Blocking = v end})
tabAutoBlock:CreateSlider({Name = "Blocking detect range", Range = {0, 50}, Increment = 1, CurrentValue = BLOCK_DISTANCE, Callback = function(v) BLOCK_DISTANCE = v end})

-- ========== TAB SPEED & STAMINA ==========
local character = lp.Character or lp.CharacterAdded:Wait()
local walkSpeedValue, sprintSpeedValue, maxStaminaValue = 10, 27, 100
local walkSpeedEnabled, sprintEnabled, staminaEnabled = false, false, false
local loopConnection = nil

local function updateAttributes()
    if unloaded or not character then return end
    if walkSpeedEnabled then character:SetAttribute("WalkSpeed", walkSpeedValue) end
    if sprintEnabled then character:SetAttribute("SprintSpeed", sprintSpeedValue) end
    if staminaEnabled then character:SetAttribute("MaxStamina", maxStaminaValue) end
    
    if noclipEnabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if noFogEnabled then
        Lighting.FogEnd = 999999
        Lighting.FogStart = 999999
        if Lighting:FindFirstChildOfClass("Atmosphere") then
            Lighting:FindFirstChildOfClass("Atmosphere").Parent = nil
        end
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    end
end

local function startLoop()
    if loopConnection then loopConnection:Disconnect() end
    loopConnection = RunService.Heartbeat:Connect(updateAttributes)
end

local tabSpeed = Window:CreateTab("Speed", 4483362458)
tabSpeed:CreateToggle({Name="Enable WalkSpeed", CurrentValue=false, Callback=function(v) walkSpeedEnabled = v; startLoop() end})
tabSpeed:CreateSlider({Name="WalkSpeed", Range={8,200}, Increment=1, CurrentValue=10, Callback=function(val) walkSpeedValue = val end})
tabSpeed:CreateToggle({Name="Enable Sprint", CurrentValue=false, Callback=function(v) sprintEnabled = v; startLoop() end})
tabSpeed:CreateSlider({Name="SprintSpeed", Range={16,300}, Increment=1, CurrentValue=27, Callback=function(val) sprintSpeedValue = val end})

local tabStamina = Window:CreateTab("Stamina", 4483362458)
tabStamina:CreateToggle({Name="Enable Custom Max Stamina", CurrentValue=false, Callback=function(v) staminaEnabled = v; startLoop() end})
tabStamina:CreateSlider({Name="Max Stamina", Range={10, 1000}, Increment=5, CurrentValue=100, Callback=function(val) maxStaminaValue = val end})

-- ========== TAB MISC ==========
local tabMisc = Window:CreateTab("Misc", 4483362458)

tabMisc:CreateSection("Animations")
local selectedAnimation = "Old"
local animationSets = {
    Old = { Adrenaline = "77399794134778", AdrenalineEnd = "92333601998082", Banana = "95775571866935", BlockLand = "94027412516651", BlockStart = "100651795910153", Caretaker = "136588017093606", CloakEnd = "0", CloakStart = "117841747115136", Dash = "82265255195607", DynamiteHold = "137091713941325", DynamiteThrow = "99551865645121", DynamiteWindup = "133960279206605", Hotdog = "93503428349113", PadBuild = "82160380573308", Punch = "135619604085485", Revolver = "73034688541555", RevolverReload = "74813841922695", Taunt = "113732291990231" },
    New = { Adrenaline = "77399794134778", AdrenalineEnd = "92333601998082", Banana = "95775571866935", BlockLand = "94027412516651", BlockStart = "134233326423882", Caretaker = "128767098320893", CloakEnd = "120142279051418", CloakStart = "133960698072483", Dash = "78278813483757", DynamiteHold = "137091713941325", DynamiteThrow = "99551865645121", DynamiteWindup = "133960279206605", Hotdog = "78595119178919", PadBuild = "79104831518074", Punch = "124781750889573", Revolver = "74108653904830", RevolverReload = "79026181033717", Taunt = "113732291990231" }
}

local function replaceAnimations(animationSet)
    local survivorPath = workspace:FindFirstChild("GameAssets") and workspace.GameAssets:FindFirstChild("Teams") and workspace.GameAssets.Teams:FindFirstChild("Survivor") and workspace.GameAssets.Teams.Survivor:FindFirstChild(lp.Name)
    local folder = (survivorPath and survivorPath:FindFirstChild("Animations") and survivorPath.Animations:FindFirstChild("Abilities")) or (workspace:FindFirstChild(lp.Name) and workspace[lp.Name]:GetChildren()[13] and workspace[lp.Name]:GetChildren()[13]:FindFirstChild("Abilities"))
    if not folder then return end
    for name, id in pairs(animationSet) do
        local anim = folder:FindFirstChild(name)
        if anim and anim:IsA("Animation") then anim.AnimationId = "rbxassetid://" .. id end
    end
end

tabMisc:CreateButton({Name = "Anim Skill Old", Callback = function() selectedAnimation = "Old"; replaceAnimations(animationSets.Old) end})
tabMisc:CreateButton({Name = "Anim Skill New", Callback = function() selectedAnimation = "New"; replaceAnimations(animationSets.New) end})

tabMisc:CreateSection("Artful Custom")
tabMisc:CreateToggle({Name = "Anti Artful Wall", CurrentValue = false, Callback = function(v) antiArtfulEnabled = v end})
tabMisc:CreateToggle({Name = "Implement Fast Artful", CurrentValue = false, Callback = function(v) fastArtfulEnabled = v end})

tabMisc:CreateSection("Visual & Movement")
tabMisc:CreateToggle({Name = "No Fog", CurrentValue = false, Callback = function(v) noFogEnabled = v; startLoop() end})
tabMisc:CreateButton({Name = "Flip 180°", Callback = function() 
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
    end
end})

tabMisc:CreateSection("Exploits & Tools")
tabMisc:CreateToggle({Name = "No Clip", CurrentValue = false, Callback = function(v) noclipEnabled = v; startLoop() end})
tabMisc:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
tabMisc:CreateButton({Name = "Flip Script (V1)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/SHRTRYScriptMANhere/stolenahhfrotflip/refs/heads/main/Flip"))() end})
tabMisc:CreateButton({Name = "Change Animation V2", Callback = function() loadstring(game:HttpGet("https://gist.githubusercontent.com/tranvanxanh0502-afk/be6bf6dc9e3f5c2beb438418277af445/raw/d66fc9b710a26454b5eb1787f1b79bc00024ecb0/I%2520am%2520not%2520the%2520owner,%2520just%2520an%2520update"))() end})

-- ========== SETTINGS ==========
local tabSettings = Window:CreateTab("Settings", 4483362458)
tabSettings:CreateToggle({Name = "Instant ProximityPrompt", CurrentValue = false, Callback = function(v) _G.InstantPP = v end})
tabSettings:CreateButton({Name="Unload Script", Callback=function() unloaded=true; Rayfield:Destroy() end})

mainConns.charAdded = lp.CharacterAdded:Connect(function(char)
    character = char
    task.wait(1)
    startLoop()
    replaceAnimations(animationSets[selectedAnimation])
end)
startLoop()
