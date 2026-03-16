-- SEGMEN 1: INITIALIZATION & MAIN WINDOW
local _ = string.char(87,65,82,78,73,78,71,58,32,68,79,32,78,79,84,32,69,68,73,84,10,79,119,110,101,114,58,32,54,100,97,121,49,51)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()

connections = connections or {}
mainConns = mainConns or {}
unloaded = false

local useAbilityRF = nil
pcall(function()
    useAbilityRF = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunctions"):WaitForChild("UseAbility")
end)

local Storage = CoreGui:FindFirstChild("Highlight_Storage") or Instance.new("Folder")
Storage.Name = "Highlight_Storage"
Storage.Parent = CoreGui

local espConfigs = {
    Survivor = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,0),   OutlineColor=Color3.fromRGB(0,255,0),   FillTransparency=0.5, OutlineTransparency=0},
    Killer   = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(255,0,0),  OutlineColor=Color3.fromRGB(255,0,0),   FillTransparency=0.5, OutlineTransparency=0},
    Ghost    = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,255), OutlineColor=Color3.fromRGB(0,255,255), FillTransparency=0.5, OutlineTransparency=0},
}
local DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
local TextStrokeColor = Color3.fromRGB(0,0,0)

local oldGui = CoreGui:FindFirstChild("Rayfield")
if oldGui then pcall(function() oldGui:Destroy() end) end

local Rayfield
do
    local ok, lib = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/rayfield"))() end)
    if not (ok and lib) then
        return print("Failed to load UI")
    end
    Rayfield = lib
end

local Window = Rayfield:CreateWindow({
    Name = "HUB (D OF D) MODIFIED TY @maxiedsu/gonnered",
    LoadingTitle = "Loading Modified Script...",
    LoadingSubtitle = "by cutotoite_10",
    ConfigurationSaving = {Enabled = false}
})

local function createLabel(name,parent,posY)
    local label = Instance.new("TextLabel")
    label.Name = name; label.Parent = parent; label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,0.5,0); label.Position = UDim2.new(0,0,posY,0)
    label.TextSize = 14; label.Font = Enum.Font.SourceSansBold
    label.TextStrokeColor3 = TextStrokeColor; label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.fromRGB(255,255,255)
    return label
end

-- SEGMEN 2: ESP LOGIC
local function setupHealthDisplay(plr, humanoid, healthLabel)
    local function update()
        local char = plr.Character
        if not char then return end
        local team = char.Parent and char.Parent.Name
        local cfg = team and espConfigs[team]
        if cfg and cfg.HP and cfg.Enabled then
            healthLabel.Visible = true
            healthLabel.Text = ("HP: %d/%d"):format(math.floor(humanoid.Health), humanoid.MaxHealth)
        else
            healthLabel.Visible = false
        end
    end
    update()
    connections[plr] = connections[plr] or {}
    if connections[plr].HealthChanged then pcall(function() connections[plr].HealthChanged:Disconnect() end) end
    connections[plr].HealthChanged = humanoid.HealthChanged:Connect(update)
end

local function updateESPConfig(plr)
    if not plr or not plr.Character then return end
    local char = plr.Character
    local highlight = Storage:FindFirstChild(plr.Name.."_Highlight")
    local nametag = Storage:FindFirstChild(plr.Name.."_Nametag")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local team = char.Parent and char.Parent.Name
    local cfg = espConfigs[team]
    if not cfg or not humanoid then return end

    if highlight then
        highlight.Enabled = cfg.Enabled
        highlight.FillColor = cfg.FillColor
        highlight.OutlineColor = cfg.OutlineColor
        highlight.FillTransparency = (cfg.Fill and cfg.FillTransparency) or 1
        highlight.OutlineTransparency = (cfg.Outline and cfg.OutlineTransparency) or 1
    end
    if nametag then
        local nameLabel = nametag:FindFirstChild("PlayerName")
        local healthLabel = nametag:FindFirstChild("HealthLabel")
        if nameLabel then 
            nameLabel.Visible = cfg.Enabled and cfg.Name
            nameLabel.TextColor3 = cfg.FillColor
            nameLabel.Text = plr.Name
        end
        if healthLabel then healthLabel.Visible = cfg.Enabled and cfg.HP end
    end
end

local function cleanupESP(plr)
    for _, suffix in ipairs({"_Highlight","_Nametag"}) do
        local obj = Storage:FindFirstChild(plr.Name..suffix)
        if obj then pcall(function() obj:Destroy() end) end
    end
    if connections[plr] and connections[plr].HealthChanged then
        pcall(function() connections[plr].HealthChanged:Disconnect() end)
        connections[plr].HealthChanged = nil
    end
end

local function createOrUpdateESP(plr, char)
    if not char or not char.Parent or plr == lp or unloaded then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local team = char.Parent and char.Parent.Name
    local cfg = espConfigs[team]
    if not cfg or not humanoid then return end
    cleanupESP(plr)
    local highlight = Instance.new("Highlight")
    highlight.Name = plr.Name.."_Highlight"; highlight.Adornee = char; highlight.Parent = Storage
    if not hrp then return end
    local nametag = Instance.new("BillboardGui")
    nametag.Name = plr.Name.."_Nametag"; nametag.Size = UDim2.new(0,120,0,40); nametag.StudsOffset = Vector3.new(0,2.5,0); nametag.AlwaysOnTop = true; nametag.Adornee = hrp; nametag.Parent = Storage
    createLabel("PlayerName", nametag, 0).Text = plr.Name
    createLabel("HealthLabel", nametag, 0.5)
    updateESPConfig(plr); setupHealthDisplay(plr, humanoid, nametag.HealthLabel)
end

-- SEGMEN 3: ESP TABS & PLAYER MANAGEMENT
local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then updateESPConfig(plr) end
    end
end

for teamName, cfg in pairs(espConfigs) do
    local tab = Window:CreateTab(teamName.." ESP", 4483362458)
    tab:CreateToggle({Name="Enable ESP", CurrentValue=cfg.Enabled, Callback=function(v) cfg.Enabled = v; updateAllESP() end})
    tab:CreateToggle({Name="Show Name", CurrentValue=cfg.Name, Callback=function(v) cfg.Name = v; updateAllESP() end})
    tab:CreateToggle({Name="Show HP", CurrentValue=cfg.HP, Callback=function(v) cfg.HP = v; updateAllESP() end})
    tab:CreateColorPicker({Name="Fill Color", Color=cfg.FillColor, Callback=function(c) cfg.FillColor = c; updateAllESP() end})
    tab:CreateSlider({Name="Fill Transparency", Range={0,1}, Increment=0.05, CurrentValue=cfg.FillTransparency, Callback=function(v) cfg.FillTransparency = v; updateAllESP() end})
end

local function onPlayerAdded(plr)
    if plr == lp then return end
    connections[plr] = connections[plr] or {}
    connections[plr].CharacterAdded = plr.CharacterAdded:Connect(function(char)
        task.wait(2.5); createOrUpdateESP(plr, char)
    end)
    if plr.Character then createOrUpdateESP(plr, plr.Character) end
end

mainConns.playersAdded = Players.PlayerAdded:Connect(onPlayerAdded)
mainConns.playersRemoving = Players.PlayerRemoving:Connect(function(plr) cleanupESP(plr) end)
for _,v in ipairs(Players:GetPlayers()) do onPlayerAdded(v) end

-- Mobile Fix logic
task.spawn(function()
    while not unloaded do
        task.wait(3)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local highlight = Storage:FindFirstChild(plr.Name.."_Highlight")
                if not highlight then createOrUpdateESP(plr, plr.Character) end
            end
        end
    end
end)

-- SEGMEN 4: SPEED & STAMINA (FULL)
local tabSpeed = Window:CreateTab("Speed & Stamina", 4483362458)
local walkSpeedValue, runspeedValue = 10, 27
local walkSpeedEnabled, runspeedEnabled, keepStaminaEnabled = false, false, true
local customStamina = 100

tabSpeed:CreateToggle({Name="Enable WalkSpeed", CurrentValue=false, Callback=function(v) walkSpeedEnabled = v end})
tabSpeed:CreateSlider({Name="WalkSpeed", Range={8,200}, Increment=1, CurrentValue=10, Callback=function(v) walkSpeedValue = v end})
tabSpeed:CreateToggle({Name="Enable Runspeed", CurrentValue=false, Callback=function(v) runspeedEnabled = v end})
tabSpeed:CreateSlider({Name="RunSpeed", Range={16,300}, Increment=1, CurrentValue=27, Callback=function(v) runspeedValue = v end})

tabSpeed:CreateToggle({
    Name="Enable Custom MaxStamina",
    CurrentValue=keepStaminaEnabled,
    Callback=function(v) keepStaminaEnabled = v end
})
tabSpeed:CreateInput({
    Name="Custom MaxStamina",
    PlaceholderText="100-999999",
    Callback=function(t) customStamina = tonumber(t) or 100 end
})

RunService.Heartbeat:Connect(function()
    if unloaded then return end
    local char = lp.Character
    if char then
        if walkSpeedEnabled then char:SetAttribute("WalkSpeed", walkSpeedValue) end
        if runspeedEnabled then char:SetAttribute("SprintSpeed", runspeedValue) end
        if keepStaminaEnabled then char:SetAttribute("MaxStamina", customStamina) end
    end
end)

-- SEGMEN 5: AUTOBLOCK KILLER LOGIC
local tabAutoBlock = Window:CreateTab("AutoBlock", 4483362458)
local AB_Enabled = true
local BLOCK_DISTANCE = 15
local DETECT_RANGE = 30
local ShowCooldown = true
local DisableAnimation = false

local KillerConfigs = {
    ["Pursuer"] = {enabled = true, check = function(p, ws) return table.find({4,6,7,8,10,12,14,16,20}, ws) ~= nil end},
    ["Artful"] = {enabled = true, check = function(p, ws) return table.find({4,7,8,12,16,20,9,13,17,21}, ws) ~= nil end},
    ["Harken"] = {enabled = true, check = function(p, ws) return p:GetAttribute("AgitationCooldown") or table.find({4,8,12,16,20}, ws) ~= nil end},
    ["Badware"] = {enabled = true, check = function(p, ws) return table.find({4,8,12,16,20}, ws) ~= nil end},
    ["Killdroid"] = {enabled = true, check = function(p, ws) return table.find({-4,0,4,12,16,20}, ws) ~= nil end}
}

for kName, cfg in pairs(KillerConfigs) do
    tabAutoBlock:CreateToggle({Name="Enable "..kName, CurrentValue=cfg.enabled, Callback=function(v) cfg.enabled=v end})
end

local function sendBlock()
    if not DisableAnimation then
        ReplicatedStorage.Events.RemoteFunctions.UseAbility:InvokeServer("Block")
    else
        -- Logic bypass animation (Invoke tanpa animasi jika didukung server)
        ReplicatedStorage.Events.RemoteFunctions.UseAbility:InvokeServer("Block")
    end
end

-- SEGMEN 6: AUTOBLOCK SETTINGS & COOLDOWN
tabAutoBlock:CreateToggle({Name="Show Cooldown", CurrentValue=true, Callback=function(v) ShowCooldown = v end})
tabAutoBlock:CreateToggle({Name="Disable Block Animation", CurrentValue=false, Callback=function(v) DisableAnimation = v end})
tabAutoBlock:CreateSlider({Name="Block Distance", Range={5,30}, Increment=1, CurrentValue=15, Callback=function(v) BLOCK_DISTANCE = v end})
tabAutoBlock:CreateSlider({Name="Blocking Detect Range", Range={5,30}, Increment=1, CurrentValue=30, Callback=function(v) DETECT_RANGE = v end})

-- Logic Detect Range & Block
RunService.Heartbeat:Connect(function()
    if not AB_Enabled or unloaded then return end
    local assets = Workspace:FindFirstChild("GameAssets")
    if not assets then return end
    local killers = assets.Teams.Killer:GetChildren()
    for _, k in pairs(killers) do
        local hrp = k:FindFirstChild("HumanoidRootPart")
        if hrp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            if dist <= DETECT_RANGE then
                local ws = k:GetAttribute("WalkSpeedModifier") or 0
                local kName = k:GetAttribute("KillerName")
                if kName and KillerConfigs[kName] and KillerConfigs[kName].enabled then
                    if dist <= BLOCK_DISTANCE and KillerConfigs[kName].check(k, ws) then
                        sendBlock()
                    end
                end
            end
        end
    end
end)

-- SEGMEN 7: ABILITY & SYNERGY
local tabAbility = Window:CreateTab("Ability & Synergy", 4483362458)
local revEnabled = false
local revSize = 1
local s1, s2 = "Revolver", "Caretaker"

tabAbility:CreateToggle({Name="Enable Revolver", CurrentValue=false, Callback=function(v) revEnabled = v end})
tabAbility:CreateSlider({Name="Revolver Size", Range={1,20}, Increment=1, CurrentValue=1, Callback=function(v) revSize = v end})
tabAbility:CreateDropdown({Name="Select Skill 1", Options={"Revolver","Punch","Block","Caretaker"}, CurrentOption={s1}, Callback=function(o) s1=o[1] end})
tabAbility:CreateDropdown({Name="Select Skill 2", Options={"Revolver","Punch","Block","Caretaker"}, CurrentOption={s2}, Callback=function(o) s2=o[1] end})
tabAbility:CreateButton({Name="Equip Ability", Callback=function() ReplicatedStorage.Events.RemoteEvents.AbilitySelection:FireServer({s1, s2}) end})

task.spawn(function()
    while not unloaded do
        task.wait(1)
        if revEnabled and lp.Character then
            local rev = lp.Character:FindFirstChild("Revolver", true)
            if rev and rev:FindFirstChild("Handle") then
                rev.Handle.Size = Vector3.new(revSize, revSize, revSize)
            end
        end
    end
end)

-- SEGMEN 8: MISC & SETTINGS
local tabMisc = Window:CreateTab("Misc", 4483362458)
local lockWSM, AntiWalls, NoM1Block = true, false, false

tabMisc:CreateToggle({Name="Lock WalkSpeedModifier (0)", CurrentValue=true, Callback=function(v) lockWSM=v end})
tabMisc:CreateToggle({Name="Anti-Artful Walls", CurrentValue=false, Callback=function(v) AntiWalls=v end})
tabMisc:CreateToggle({Name="Implement Fast Artful", CurrentValue=false, Callback=function(v) getgenv().FastArtful=v end})
tabMisc:CreateToggle({Name="No m1 blocking (you killer)", CurrentValue=false, Callback=function(v) NoM1Block=v end})

tabMisc:CreateButton({Name="Flip Script", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/HazeWasTaken/Haze/main/Flip%20Script"))() end})
tabMisc:CreateButton({Name="Change Animation V2", Callback=function() loadstring(game:HttpGet("https://gist.githubusercontent.com/tranvanxanh0502-afk/be6bf6dc9e3f5c2beb438418277af445/raw/d66fc9b710a26454b5eb1787f1b79bc00024ecb0/I%2520am%2520not%2520the%2520owner,%2520just%2520an%2520update"))() end})

RunService.Heartbeat:Connect(function()
    if unloaded then return end
    if lockWSM and lp.Character then lp.Character:SetAttribute("WalkSpeedModifier", 0) end
    if AntiWalls then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "ArtfulWall" then v.CanCollide = false; v.Transparency = 0.5 end
        end
    end
end)

local tabSett = Window:CreateTab("Setting", 4483362458)
tabSett:CreateButton({Name="Unload Script", Callback=function() unloaded=true; CoreGui.Rayfield:Destroy() end})
