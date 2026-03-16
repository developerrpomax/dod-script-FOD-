--  PART 1: Load Rayfield + ESP + Speed Settings + Auto Block
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
    Killer   = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(255,0,0),   OutlineColor=Color3.fromRGB(255,0,0),   FillTransparency=0.5, OutlineTransparency=0},
    Ghost    = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,255), OutlineColor=Color3.fromRGB(0,255,255), FillTransparency=0.5, OutlineTransparency=0},
}
local DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
local TextStrokeColor = Color3.fromRGB(0,0,0)

local oldGui = CoreGui:FindFirstChild("Rayfield")
if oldGui then pcall(function() oldGui:Destroy() end) end

local function makeFallbackRayfield()
    local DummyParagraph = { Set=function() end }
    local DummyTab = {
        CreateToggle=function() end, CreateSlider=function() end, CreateButton=function() end,
        CreateParagraph=function() return DummyParagraph end, CreateDropdown=function() end,
        CreateInput=function() end, CreateColorPicker=function() end,
    }
    return { CreateWindow=function() return { CreateTab=function() return DummyTab end } end }
end

local Rayfield
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    Rayfield = (ok and lib and lib.CreateWindow) and lib or makeFallbackRayfield()
    if Rayfield.Notify then Rayfield.Notify = function() end end
end

local Window = Rayfield:CreateWindow({
    Name = "HUB (D OF D) MODIFIED TY @maxiedsu/gonnered",
    LoadingTitle = "Loading...TY @maxiedsu/gonnered",
    LoadingSubtitle = "by cutotoite_10",
    ConfigurationSaving = {Enabled = false}
})

-- ========== ESP ==========
local function createLabel(name,parent,posY)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,0.5,0)
    label.Position = UDim2.new(0,0,posY,0)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.TextStrokeColor3 = TextStrokeColor
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.fromRGB(255,255,255)
    return label
end

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
    update()  -- Gọi lần đầu
    connections[plr] = connections[plr] or {}
    if connections[plr].HealthChanged then
        pcall(function() connections[plr].HealthChanged:Disconnect() end)
    end
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
            nameLabel.Text = plr.Name  -- Set name nếu chưa có
        end
        if healthLabel then 
            healthLabel.Visible = cfg.Enabled and cfg.HP
            -- Health sẽ update qua event riêng
        end
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

    -- Cleanup trước nếu có ESP cũ
    cleanupESP(plr)

    -- Tạo mới
    local highlight = Instance.new("Highlight")
    highlight.Name = plr.Name.."_Highlight"
    highlight.DepthMode = DepthMode
    highlight.Adornee = char
    highlight.Parent = Storage

    if not hrp then return end

    local nametag = Instance.new("BillboardGui")
    nametag.Name = plr.Name.."_Nametag"
    nametag.Size = UDim2.new(0,120,0,40)
    nametag.StudsOffset = Vector3.new(0,2.5,0)
    nametag.AlwaysOnTop = true
    nametag.Adornee = hrp
    nametag.Parent = Storage
    local nameLabel = createLabel("PlayerName", nametag, 0)
    nameLabel.Text = plr.Name
    local healthLabel = createLabel("HealthLabel", nametag, 0.5)

    -- Update config
    updateESPConfig(plr)

    -- Setup health
    setupHealthDisplay(plr, humanoid, healthLabel)

    -- Thêm connection cho Died để cleanup
    connections[plr].Died = humanoid.Died:Connect(function()
        cleanupESP(plr)
    end)

    -- Thêm connection cho CharacterRemoving (nếu character destroyed)
    connections[plr].CharacterRemoving = plr.CharacterRemoving:Connect(function()
        cleanupESP(plr)
    end)
end

local function onPlayerAdded(plr)
    if plr == lp then return end
    connections[plr] = connections[plr] or {}
    connections[plr].CharacterAdded = plr.CharacterAdded:Connect(function(char)
        task.wait(2.5)
        createOrUpdateESP(plr, char)
    end)
    if plr.Character then createOrUpdateESP(plr, plr.Character) end
end

local function onPlayerRemoving(plr)
    cleanupESP(plr)
    if connections[plr] then
        for _, conn in pairs(connections[plr]) do
            if typeof(conn) == "RBXScriptConnection" then
                pcall(function() conn:Disconnect() end)
            end
        end
        connections[plr] = nil
    end
end

mainConns.playersAdded = Players.PlayerAdded:Connect(onPlayerAdded)
mainConns.playersRemoving = Players.PlayerRemoving:Connect(onPlayerRemoving)
for _,v in ipairs(Players:GetPlayers()) do onPlayerAdded(v) end

-- UI với callbacks update ESP
local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then updateESPConfig(plr) end
    end
end

for teamName, cfg in pairs(espConfigs) do
    local tab = Window:CreateTab(teamName.." ESP", 4483362458)
    tab:CreateToggle({
        Name="Enable ESP", 
        CurrentValue=cfg.Enabled, 
        Callback=function(v) 
            cfg.Enabled = v 
            updateAllESP()
        end
    })
    tab:CreateToggle({
        Name="Show Name", 
        CurrentValue=cfg.Name, 
        Callback=function(v) 
            cfg.Name = v 
            updateAllESP()
        end
    })
    tab:CreateToggle({
        Name="Show HP", 
        CurrentValue=cfg.HP, 
        Callback=function(v) 
            cfg.HP = v 
            updateAllESP()
        end
    })
    tab:CreateToggle({
        Name="Show Fill", 
        CurrentValue=cfg.Fill, 
        Callback=function(v) 
            cfg.Fill = v 
            updateAllESP()
        end
    })
    tab:CreateColorPicker({
        Name="Fill Color", 
        Color=cfg.FillColor, 
        Callback=function(c) 
            cfg.FillColor = c 
            updateAllESP()
        end
    })
    tab:CreateSlider({
        Name="Fill Transparency", 
        Range={0,1}, 
        Increment=0.05, 
        CurrentValue=cfg.FillTransparency, 
        Callback=function(v) 
            cfg.FillTransparency = v 
            updateAllESP()
        end
    })
    tab:CreateToggle({
        Name="Show Outline", 
        CurrentValue=cfg.Outline, 
        Callback=function(v) 
            cfg.Outline = v 
            updateAllESP()
        end
    })
    tab:CreateColorPicker({
        Name="Outline Color", 
        Color=cfg.OutlineColor, 
        Callback=function(c) 
            cfg.OutlineColor = c 
            updateAllESP()
        end
    })
    tab:CreateSlider({
        Name="Outline Transparency", 
        Range={0,1}, 
        Increment=0.05, 
        CurrentValue=cfg.OutlineTransparency, 
        Callback=function(v) 
            cfg.OutlineTransparency = v 
            updateAllESP()
        end
    })
end

-- ========== Auto-Detect & Fix ESP (Mobile Resume Fix) ==========
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local lastEspCheck = 0
local ESP_CHECK_INTERVAL = 3  -- 3 giây (thấp lag)

task.spawn(function()
    while not unloaded do
        local now = tick()
        if now - lastEspCheck < ESP_CHECK_INTERVAL then
            task.wait(0.1)
            continue
        end
        lastEspCheck = now
        
        -- Chỉ poll trên mobile hoặc nếu enabled
        if not isMobile then task.wait(ESP_CHECK_INTERVAL); continue end
        
        -- Scan và fix ESP mismatch
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == lp or not plr.Character then continue end
            local char = plr.Character
            local team = char.Parent and char.Parent.Name
            local cfg = espConfigs[team]
            if not cfg or not cfg.Enabled then continue end
            
            -- Check Highlight
            local highlight = Storage:FindFirstChild(plr.Name.."_Highlight")
            if highlight and not highlight.Enabled then
                updateESPConfig(plr)  -- Fix properties
                print("[ESP Fix] Re-enabled Highlight for " .. plr.Name)
            end
            
            -- Check Nametag
            local nametag = Storage:FindFirstChild(plr.Name.."_Nametag")
            if nametag then
                local nameLabel = nametag:FindFirstChild("PlayerName")
                local healthLabel = nametag:FindFirstChild("HealthLabel")
                if (cfg.Name and nameLabel and not nameLabel.Visible) or (cfg.HP and healthLabel and not healthLabel.Visible) then
                    updateESPConfig(plr)  -- Fix visible
                    print("[ESP Fix] Re-showed labels for " .. plr.Name)
                end
            end
            
            -- Nếu object mất hẳn, recreate
            if not highlight and not nametag then
                createOrUpdateESP(plr, char)
                print("[ESP Fix] Recreated ESP for " .. plr.Name)
            end
        end
        
        task.wait(ESP_CHECK_INTERVAL)
    end
end)
-- ========== Speed & Stamina (Optimized) ==========
local character = lp.Character or lp.CharacterAdded:Wait()
if character:GetAttribute("WalkSpeed") == nil then character:SetAttribute("WalkSpeed", 10) end
if character:GetAttribute("SprintSpeed") == nil then character:SetAttribute("SprintSpeed", 27) end

local walkSpeedValue = character:GetAttribute("WalkSpeed") or 10
local sprintSpeedValue = character:GetAttribute("SprintSpeed") or 27
local walkSpeedEnabled = false
local sprintEnabled = false

-- Cache cho current values để tránh set thừa
local currentWalkSpeed = walkSpeedValue
local currentSprintSpeed = sprintSpeedValue

local speedConnection = nil  -- Để disconnect khi off

local function updateSpeeds()
    if unloaded or not character then return end
    local currentWS = character:GetAttribute("WalkSpeed") or 10
    local currentSS = character:GetAttribute("SprintSpeed") or 27
    
    if walkSpeedEnabled and currentWS ~= walkSpeedValue then
        character:SetAttribute("WalkSpeed", walkSpeedValue)
        currentWalkSpeed = walkSpeedValue
    end
    if sprintEnabled and currentSS ~= sprintSpeedValue then
        character:SetAttribute("SprintSpeed", sprintSpeedValue)
        currentSprintSpeed = sprintSpeedValue
    end
end

local function startSpeedLoop()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.Heartbeat:Connect(updateSpeeds)  -- Heartbeat thay vì RenderStepped
end

local function stopSpeedLoop()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
end

local tabSpeed = Window:CreateTab("Speed & Stamina", 4483362458)
tabSpeed:CreateSlider({
    Name="WalkSpeed", 
    Range={8,200}, 
    Increment=1, 
    CurrentValue=walkSpeedValue, 
    Callback=function(val) 
        walkSpeedValue = val 
        if walkSpeedEnabled then updateSpeeds() end  -- Update ngay nếu đang on
    end
})
tabSpeed:CreateToggle({
    Name="Enable WalkSpeed", 
    CurrentValue=walkSpeedEnabled, 
    Callback=function(v) 
        walkSpeedEnabled = v
        if v then 
            startSpeedLoop()
            updateSpeeds()  -- Set ngay
        else 
            if character then character:SetAttribute("WalkSpeed", 10) end
            stopSpeedLoop()
        end
    end
})
tabSpeed:CreateSlider({
    Name="SprintSpeed", 
    Range={16,300}, 
    Increment=1, 
    CurrentValue=sprintSpeedValue, 
    Callback=function(val) 
        sprintSpeedValue = val 
        if sprintEnabled then updateSpeeds() end  -- Update ngay nếu đang on
    end
})
tabSpeed:CreateToggle({
    Name="Enable Sprint", 
    CurrentValue=sprintEnabled, 
    Callback=function(v) 
        sprintEnabled = v
        if v then 
            startSpeedLoop()
            updateSpeeds()  -- Set ngay
        else 
            if character then character:SetAttribute("SprintSpeed", 27) end
            stopSpeedLoop()
        end
    end
})

-- Handle CharacterAdded cho speed
mainConns.charAdded_speed = lp.CharacterAdded:Connect(function(char)
    character = char
    task.wait(0.5)  -- Đợi load đầy đủ
    if character:GetAttribute("WalkSpeed") == nil then character:SetAttribute("WalkSpeed", walkSpeedValue) end
    if character:GetAttribute("SprintSpeed") == nil then character:SetAttribute("SprintSpeed", sprintSpeedValue) end
    currentWalkSpeed = walkSpeedValue
    currentSprintSpeed = sprintSpeedValue
    -- Restart loop nếu đang enabled
    if walkSpeedEnabled or sprintEnabled then
        startSpeedLoop()
    end
end)

--// Auto Block+
--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

-- ================= AutoBlock Settings =================
local BLOCK_DISTANCE = 15
local watcherEnabled = true
local Logged = {}

-- Remote
local UseAbility = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunctions"):WaitForChild("UseAbility")

-- Killer Configs
-- Biáº¿n tráº¡ng thĂ¡i riĂªng cho Badware
local badwareState = {
    active = false,
    startTime = 0,
    lastWS = nil
}

local KillerConfigs = {
    ["Pursuer"] = {
        enabled = true,
        check = function(_, ws)
            local valid = {4,6,7,8,10,12,14,16,20}
            for _, v in ipairs(valid) do
                if ws == v then return true end
            end
            return false
        end
    },

    ["Artful"] = {
        enabled = true,
        check = function(_, ws)
            local valid = {4,7,8,12,16,20,9,13,17,21}
            for _, v in ipairs(valid) do
                if ws == v then return true end
            end
            return false
        end
    },

    
    ["Harken"] = {
    enabled = true,
    check = function(playerFolder, ws)
        local enraged = playerFolder:GetAttribute("Enraged")
        local seq = enraged and {7.5,10,5,13.5,17.5,21.5,25.5} or {4,8,12,16,20}

        -- Náº¿u AgitationCooldown báº­t thĂ¬ block luĂ´n
        if playerFolder:GetAttribute("AgitationCooldown") then
            return true
        end

        for _, v in ipairs(seq) do
            if ws == v then return true end
        end
        return false
    end
},
    ["Badware"] = {
    enabled = true,
    check = function(_, ws)
        local valid = {4,8,12,16,20}
        local function isValid(val)
            for _, v in ipairs(valid) do
                if val == v then return true end
            end
            return false
        end

        local now = tick()
        if isValid(ws) then
            -- Náº¿u báº¯t Ä‘áº§u theo dĂµi
            if not badwareState.active then
                badwareState.startTime = now
                badwareState.active = true
                badwareState.lastWS = ws
                return false
            else
                -- Náº¿u Ä‘á»•i tá»« giĂ¡ trá»‡ há»£p lá»‡ nĂ y sang giĂ¡ trá»‡ há»£p lá»‡ khĂ¡c -> tiáº¿p tá»¥c, khĂ´ng reset
                badwareState.lastWS = ws
                return false
            end
        else
            -- Náº¿u Ä‘ang active mĂ  bá»‹ tá»¥t ra ngoĂ i dĂ£y há»£p lá»‡
            if badwareState.active then
                local duration = now - badwareState.startTime
                badwareState.active = false
                badwareState.lastWS = nil
                badwareState.startTime = nil

                if duration < 0.3 then
                    return true   -- block vĂ¬ tá»¥t quĂ¡ sá»›m
                else
                    return false  -- khĂ´ng block vĂ¬ giá»¯ Ä‘á»§ lĂ¢u
                end
            end
        end
        return false
    end
},
    ["Killdroid"] = {
        enabled = true,
        check = function(_, ws)
            local valid = {-4,0,4,12,16,20}
            for _, v in ipairs(valid) do
                if ws == v then return true end
            end
            return false
        end
    }
}


-- Helpers
local function sendBlock()
    UseAbility:InvokeServer("Block")
end

local function getWalkSpeedModifier(killer)
    return killer:GetAttribute("WalkSpeedModifier") or 0
end

local function getDistanceFromPlayer(killer)
    if killer:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        return (killer.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function checkAndBlock(killer)
    if not watcherEnabled or not killer then return end
    local ws = getWalkSpeedModifier(killer)
    local name = killer:GetAttribute("KillerName")
    if not name then return end
    local config = KillerConfigs[name]
    if not config or not config.enabled then return end
    if getDistanceFromPlayer(killer) > BLOCK_DISTANCE then return end
    if config.check(killer, ws) then
        sendBlock()
        Logged[killer] = Logged[killer] or {}
        if not Logged[killer][ws] then
            print("[AutoBlock] "..name.." ("..killer.Name..") WalkSpeedModifier = "..ws.." -> blocked")
            Logged[killer][ws] = true
            task.delay(3, function() Logged[killer][ws] = nil end)
        end
    end
end

local function monitorKiller(killer)
    if not killer then return end
    checkAndBlock(killer)
    if not killer:GetAttribute("__AB_CONNECTED") then
        killer:SetAttribute("__AB_CONNECTED", true)
        killer.AttributeChanged:Connect(function(attr)
            if attr == "WalkSpeedModifier" or attr == "KillerName" or attr == "Enraged" then
                checkAndBlock(killer)
            end
        end)
    end
end

-- Monitor existing and new killers
local killersFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")
for _, killer in pairs(killersFolder:GetChildren()) do monitorKiller(killer) end
killersFolder.ChildAdded:Connect(monitorKiller)

-- ================= Cooldown GUI =================
-- Tạo GUI Cooldown (chỉ 1 lần)
local CooldownGUI = Instance.new("ScreenGui")
CooldownGUI.Name = "AutoBlockCooldown"
CooldownGUI.ResetOnSpawn = false
CooldownGUI.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local CooldownFrame = Instance.new("Frame")
CooldownFrame.Size = UDim2.new(0,65,0,25)
CooldownFrame.Position = UDim2.new(1,-5,0,-50)
CooldownFrame.AnchorPoint = Vector2.new(1,0)
CooldownFrame.BackgroundTransparency = 1
CooldownFrame.Parent = CooldownGUI

local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Size = UDim2.new(1,0,1,0)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.TextColor3 = Color3.fromRGB(0,255,0)
cooldownLabel.Font = Enum.Font.SourceSansBold
cooldownLabel.TextScaled = true
cooldownLabel.Text = "Ready"
cooldownLabel.Parent = CooldownFrame


-- ================= Kéo Thả GUI Cooldown (Ready / On Cooldown) =================
local UserInputService = game:GetService("UserInputService")
-- Biến hỗ trợ drag
local dragging = false
local dragInput, startPos, frameStart

-- Hàm cập nhật vị trí frame
local function updatePosition(delta)
    if frameStart then
        CooldownFrame.Position = UDim2.new(
            frameStart.X.Scale,
            frameStart.X.Offset + delta.X,
            frameStart.Y.Scale,
            frameStart.Y.Offset + delta.Y
        )
    end
end

-- Bắt đầu kéo (Mouse hoặc Touch)
local function inputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragInput = input
        startPos = input.Position
        frameStart = CooldownFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragInput = nil
            end
        end)
    end
end

-- Cập nhật khi di chuyển chuột atau touch
local function inputChanged(input)
    if input == dragInput and dragging then
        local delta = input.Position - startPos
        updatePosition(delta)
    end
end

-- Kết nối sự kiện
CooldownFrame.InputBegan:Connect(inputBegan)
CooldownFrame.InputChanged:Connect(inputChanged)

-- ================= Logic Cooldown AutoBlock =================
local isCooldown = false
local cooldownDuration = 2.5 -- 2.5 giây cooldown cho Block

local function startCooldown()
    isCooldown = true
    cooldownLabel.Text = "2.5"
    cooldownLabel.TextColor3 = Color3.fromRGB(255,0,0)
    
    local timeLeft = cooldownDuration
    while timeLeft > 0 do
        task.wait(0.1)
        timeLeft = timeLeft - 0.1
        if timeLeft < 0 then timeLeft = 0 end
        cooldownLabel.Text = string.format("%.1f", timeLeft)
    end
    
    cooldownLabel.Text = "Ready"
    cooldownLabel.TextColor3 = Color3.fromRGB(0,255,0)
    isCooldown = false
end

-- Hook vào RemoteFunction Block
local oldInvokeServer
oldInvokeServer = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "InvokeServer" and self.Name == "UseAbility" and args[1] == "Block" then
        if isCooldown then return nil end -- Không cho block nếu đang cooldown
        task.spawn(startCooldown) -- Chạy timer cooldown
    end
    
    return oldInvokeServer(self, ...)
end)


-- Tab UI AutoBlock
local autoBlockTab = Window:CreateTab("AutoBlock", 4483362458)

autoBlockTab:CreateToggle({
    Name = "Enable AutoBlock", 
    CurrentValue = true, 
    Callback = function(v) 
        watcherEnabled = v 
    end
})

autoBlockTab:CreateSlider({
    Name = "Block Distance", 
    Range = {5, 30}, 
    Increment = 1, 
    CurrentValue = BLOCK_DISTANCE, 
    Callback = function(v) 
        BLOCK_DISTANCE = v 
    end
})

autoBlockTab:CreateToggle({
    Name = "Show Cooldown GUI", 
    CurrentValue = true, 
    Callback = function(v) 
        CooldownGUI.Enabled = v 
    end
})

autoBlockTab:CreateButton({
    Name = "Reset Cooldown GUI Position",
    Callback = function()
        CooldownFrame.Position = UDim2.new(1, -5, 0, -50)
    end
})

autoBlockTab:CreateParagraph({Title = "Killer Configs", Content = "Enable/Disable blocking for specific killers"})

for name, config in pairs(KillerConfigs) do
    autoBlockTab:CreateToggle({
        Name = "Block " .. name,
        CurrentValue = config.enabled,
        Callback = function(v)
            config.enabled = v
        end
    })
end

--// Part 2: Stamina + Ability & Synergy + Misc + Animations
-- ========== Ability & Synergy ==========
local character = lp.Character or lp.CharacterAdded:Wait()

-- Stamina Settings
local maxStaminaValue = 100
local staminaEnabled = true

local function updateStamina()
    if unloaded or not character then return end
    if staminaEnabled then
        local currentMax = character:GetAttribute("MaxStamina")
        if currentMax ~= maxStaminaValue then
            character:SetAttribute("MaxStamina", maxStaminaValue)
        end
    end
end

local staminaConnection = RunService.Heartbeat:Connect(updateStamina)

local tabStamina = tabSpeed -- Dùng chung tab Speed & Stamina đã đổi tên
tabStamina:CreateParagraph({Title = "Stamina Settings", Content = "Modify your maximum stamina"})

tabStamina:CreateInput({
    Name = "Custom MaxStamina",
    PlaceholderText = "Default 100",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            maxStaminaValue = num
            if character then character:SetAttribute("MaxStamina", num) end
        end
    end,
})

tabStamina:CreateToggle({
    Name = "Enable Custom MaxStamina",
    CurrentValue = staminaEnabled,
    Callback = function(v)
        staminaEnabled = v
        if not v and character then
            character:SetAttribute("MaxStamina", 100)
        end
    end
})


-- Ability & Synergy Tab
local tabSkill = Window:CreateTab("Ability & Synergy", 4483362458)
local selectedSkill1 = "Revolver"
local selectedSkill2 = "Caretaker"
local revolverSize = 1
local revolverSizeEnabled = false

local abilities = {
    "Revolver", "Punch", "Block", "Caretaker", "Hotdog", 
    "Taunt", "Cloak", "Dash", "Banana", "BonusPad", "Adrenaline"
}

tabSkill:CreateDropdown({
    Name = "Select Skill 1",
    Options = abilities,
    CurrentOption = {selectedSkill1},
    MultipleOptions = false,
    Callback = function(option)
        selectedSkill1 = option[1]
    end,
})

tabSkill:CreateDropdown({
    Name = "Select Skill 2",
    Options = abilities,
    CurrentOption = {selectedSkill2},
    MultipleOptions = false,
    Callback = function(option)
        selectedSkill2 = option[1]
    end,
})

tabSkill:CreateButton({
    Name = "Equip Ability",
    Callback = function()
        local event = ReplicatedStorage:FindFirstChild("Events")
        if event then
            local remote = event:FindFirstChild("RemoteEvents") and event.RemoteEvents:FindFirstChild("AbilitySelection")
            if remote then
                remote:FireServer({selectedSkill1, selectedSkill2})
                Rayfield:Notify({
                    Title = "Ability Set",
                    Content = "Equipped " .. selectedSkill1 .. " & " .. selectedSkill2,
                    Duration = 3
                })
            end
        end
    end
})

tabSkill:CreateParagraph({Title = "Revolver Mod", Content = "Modify your revolver size"})

tabSkill:CreateSlider({
    Name = "Revolver Size",
    Range = {1, 15},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(val)
        revolverSize = val
    end
})

tabSkill:CreateToggle({
    Name = "Enable Revolver",
    CurrentValue = false,
    Callback = function(v)
        revolverSizeEnabled = v
    end
})

-- Loop Revolver Size
task.spawn(function()
    while not unloaded do
        if revolverSizeEnabled and character then
            local tool = character:FindFirstChild("Revolver")
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(revolverSize, revolverSize, revolverSize)
            end
        end
        task.wait(0.5)
    end
end)


-- Misc Tab
local tabGameplay = Window:CreateTab("Misc", 4483362458)

local lockWSM = true
local antiArtfulWalls = false
local fastArtful = false
local noM1Blocking = false

tabGameplay:CreateToggle({
    Name = "Anti Slowness",
    CurrentValue = true,
    Callback = function(v)
        lockWSM = v
    end
})

tabGameplay:CreateToggle({
    Name = "Anti-Artful Walls",
    CurrentValue = false,
    Callback = function(v)
        antiArtfulWalls = v
    end
})

tabGameplay:CreateToggle({
    Name = "Implement Fast Artful",
    CurrentValue = false,
    Callback = function(v)
        fastArtful = v
    end
})

tabGameplay:CreateToggle({
    Name = "No m1 blocking (you killer)",
    CurrentValue = false,
    Callback = function(v)
        noM1Blocking = v
    end
})

-- Misc Logic Loop
RunService.Heartbeat:Connect(function()
    if unloaded or not character then return end
    
    if lockWSM then
        character:SetAttribute("WalkSpeedModifier", 0)
    end
    
    if antiArtfulWalls then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "ArtfulWall" and obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Transparency = 0.5
            end
        end
    end
    
    if fastArtful then
        -- Fast Artful Logic here
    end
    
    if noM1Blocking then
        -- No M1 Blocking Logic here
    end
end)

-- CharacterAdded Re-setup
lp.CharacterAdded:Connect(function(newChar)
    character = newChar
end)

--// Part 3: Animations & Final
-- ============================
-- Animation Tab
-- ============================
local tabAnim = Window:CreateTab("Animation", 4483362458)

local selectedAnimation = "None"
local animations = {
    "None", "Classic", "Stylized", "Heroic", "Zombie", "Ninja", "Mage", "Pirate"
}


-- Table ID Animation
local animationSets = {
    ["Classic"] = {
        Idle = "rbxassetid://507766666",
        Walk = "rbxassetid://507777826",
        Run = "rbxassetid://507767714",
        Jump = "rbxassetid://507765000",
        Fall = "rbxassetid://507767968"
    },
    ["Stylized"] = {
        Idle = "rbxassetid://616158929",
        Walk = "rbxassetid://616168032",
        Run = "rbxassetid://616163682",
        Jump = "rbxassetid://616157476",
        Fall = "rbxassetid://616156119"
    },
    ["Zombie"] = {
        Idle = "rbxassetid://616158929",
        Walk = "rbxassetid://616168032",
        Run = "rbxassetid://616163682",
        Jump = "rbxassetid://616157476",
        Fall = "rbxassetid://616156119"
    }
}

local function replaceAnimations(ids)
    if not character:FindFirstChild("Animate") then return end
    local animate = character.Animate
    
    if ids.Idle then
        animate.idle.Animation1.AnimationId = ids.Idle
        animate.idle.Animation2.AnimationId = ids.Idle
    end
    if ids.Walk then animate.walk.WalkAnim.AnimationId = ids.Walk end
    if ids.Run then animate.run.RunAnim.AnimationId = ids.Run end
    if ids.Jump then animate.jump.JumpAnim.AnimationId = ids.Jump end
    if ids.Fall then animate.fall.FallAnim.AnimationId = ids.Fall end
    
    -- Refresh Animation
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

tabAnim:CreateDropdown({
    Name = "Select Animation",
    Options = animations,
    CurrentOption = {selectedAnimation},
    Callback = function(option)
        selectedAnimation = option[1]
        if animationSets[selectedAnimation] then
            replaceAnimations(animationSets[selectedAnimation])
        end
    end,
})

tabAnim:CreateButton({
    Name = "Apply Animation",
    Callback = function()
        if animationSets[selectedAnimation] then
            replaceAnimations(animationSets[selectedAnimation])
        end
    end
})

-- ============================
-- Other Tab (Loadstring)
-- ============================
-- Fix êrror Http403,hey what are you doing...Diova
local _ = string.char(87,65,82,78,73,78,71,58,32,68,79,32,78,79,84,32,69,68,73,84,10,79,119,110,101,114,58,32,54,100,97,121,49,51)
local tabOther = Window:CreateTab("Other", 115233777642994)


tabOther:CreateButton({
    Name = "Change Animation V2",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://gist.githubusercontent.com/tranvanxanh0502-afk/be6bf6dc9e3f5c2beb438418277af445/raw/d66fc9b710a26454b5eb1787f1b79bc00024ecb0/I%2520am%2520not%2520the%2520owner,%2520just%2520an%2520update", true))()
        end)
        if not success then
             print("Error loading Change Animation V2: ", err)
        end
    end
})

tabOther:CreateButton({
    Name = "Flip Script",
    Callback = function()
        local success, err = pcall(function()
             loadstring(game:HttpGet("https://raw.githubusercontent.com/HazeWasTaken/Haze/main/Flip%20Script", true))()
        end)
        if not success then
             print("Error loading Flip Script: ", err)
        end
    end
})

-- ============================
-- Setting Tab (Unload)
-- ============================
local tabSetting = Window:CreateTab("Setting", 4483362458)

tabSetting:CreateButton({
    Name = "Unload Script",
    Callback = function()
        unloaded = true
        
        -- Cleanup ESP
        for _, plr in ipairs(Players:GetPlayers()) do cleanupESP(plr) end
        if Storage then Storage:Destroy() end
        if CooldownGUI then CooldownGUI:Destroy() end
        
        -- Disconnect Connections
        for _, conn in pairs(mainConns) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end
        for _, plConns in pairs(connections) do
            for _, conn in pairs(plConns) do
                if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
            end
        end
        
        -- Destroy UI
        Rayfield:Destroy()
    end
})

-- Notification
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Welcome back, Modified HUB is active!",
    Duration = 5,
    Image = 4483362458,
})
