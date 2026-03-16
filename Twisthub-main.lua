-- [[ TWIST HUB - BEST DOD SCRIPT OAT ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TWIST HUB",
   LoadingTitle = "DOD ULTIMATE MASTERPIECE",
   LoadingSubtitle = "All Features Restored | Stability Fix",
   ConfigurationSaving = { Enabled = false }
})

-- // STATES //
local Toggles = {
    ESP_K = false, ESP_S = false, Chams = false,
    WalkSpeedOn = false, WalkPower = 0,
    RunSpeedOn = false, RunPower = 0,
    AntiSlow = false,
    InfStamK = false, InfStamS = false, StamCapK = 100, StamCapS = 100,
    AutoBlock = false, BlockDist = 15, FacingCheck = false,
    AimK = false, AimS = false, AimDist = 1000, AimMethod = "Camera",
    Invis = false, Depth = -10, NameSpoof = false,
    Fly = false, FlySpeed = 1, Noclip = false, FullBright = false
}

local Killers = {"Artful", "Badware", "Killdroid", "Pursuer", "Harken", "Stalker"}
local Items = {"Revolver", "Block", "Caretaker", "Adrenaline", "Punch", "Bonuspad", "Cloak", "Hotdog", "Taunt", "Banana"}

-- // 1. ESP TAB (Posisi Asli) //
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({Name = "Enable Chams", CurrentValue = false, Callback = function(v) Toggles.Chams = v end})
ESPTab:CreateToggle({Name = "Killer ESP + HP Check", CurrentValue = false, Callback = function(v) Toggles.ESP_K = v end})
ESPTab:CreateToggle({Name = "Survivor ESP + HP Check", CurrentValue = false, Callback = function(v) Toggles.ESP_S = v end})

-- // 2. SPEED TAB (Pemisahan Walk & Run) //
local SpeedTab = Window:CreateTab("Speed Settings", 4483362458)
SpeedTab:CreateSection("Walking Only")
SpeedTab:CreateToggle({Name = "Enable Walking Speed", CurrentValue = false, Callback = function(v) Toggles.WalkSpeedOn = v end})
SpeedTab:CreateSlider({Name = "Walk Power", Range = {0, 50}, Increment = 1, CurrentValue = 0, Callback = function(v) Toggles.WalkPower = v end})
SpeedTab:CreateSection("Running Only")
SpeedTab:CreateToggle({Name = "Enable Running Speed", CurrentValue = false, Callback = function(v) Toggles.RunSpeedOn = v end})
SpeedTab:CreateSlider({Name = "Run Power", Range = {0, 50}, Increment = 1, CurrentValue = 0, Callback = function(v) Toggles.RunPower = v end})
SpeedTab:CreateToggle({Name = "Anti-Slow (Passive)", CurrentValue = false, Callback = function(v) Toggles.AntiSlow = v end})

-- // 3. STAMINA TAB //
local StaminaTab = Window:CreateTab("Gameplay Settings", 4483362458)
StaminaTab:CreateSection("Survivor")
StaminaTab:CreateToggle({Name = "Inf Stamina Survivor", CurrentValue = false, Callback = function(v) Toggles.InfStamS = v end})
StaminaTab:CreateSlider({Name = "Survivor Capacity", Range = {100, 5000}, Increment = 50, CurrentValue = 100, Callback = function(v) Toggles.StamCapS = v end})
StaminaTab:CreateSection("Killer")
StaminaTab:CreateToggle({Name = "Inf Stamina Killer", CurrentValue = false, Callback = function(v) Toggles.InfStamK = v end})
StaminaTab:CreateSlider({Name = "Killer Capacity", Range = {100, 10000}, Increment = 50, CurrentValue = 100, Callback = function(v) Toggles.StamCapK = v end})

-- // 4. AUTO BLOCK TAB //
local BlockTab = Window:CreateTab("Auto Block", 4483362458)
BlockTab:CreateToggle({Name = "Enable Auto Block", CurrentValue = false, Callback = function(v) Toggles.AutoBlock = v end})
BlockTab:CreateToggle({Name = "Facing Check", CurrentValue = false, Callback = function(v) Toggles.FacingCheck = v end})
BlockTab:CreateSlider({Name = "Block Distance", Range = {5, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) Toggles.BlockDist = v end})

-- // 5. ABILITY TAB //
local AbilityTab = Window:CreateTab("Skills & Selector", 4483362458)
for _, item in pairs(Items) do
    AbilityTab:CreateButton({Name = "Get " .. item, Callback = function() 
        pcall(function() ReplicatedStorage:FindFirstChild(item, true):Clone().Parent = LocalPlayer.Backpack end)
    end})
end

-- // 6. AIMBOT TAB //
local AimTab = Window:CreateTab("Aimbot", 4483362458)
AimTab:CreateToggle({Name = "Lock On Killer", CurrentValue = false, Callback = function(v) Toggles.AimK = v end})
AimTab:CreateToggle({Name = "Lock On Survivor", CurrentValue = false, Callback = function(v) Toggles.AimS = v end})
AimTab:CreateSlider({Name = "Aim Distance", Range = {50, 2000}, Increment = 50, CurrentValue = 1000, Callback = function(v) Toggles.AimDist = v end})
AimTab:CreateDropdown({Name = "Aim Method", Options = {"Camera", "Character", "Both"}, CurrentOption = "Camera", Callback = function(v) Toggles.AimMethod = v end})

-- // 7. MISC TAB //
local MiscTab = Window:CreateTab("Other", 4483362458)
MiscTab:CreateToggle({Name = "Name Spoofer (Client Side)", CurrentValue = false, Callback = function(v) Toggles.NameSpoof = v end})
MiscTab:CreateToggle({Name = "Underground Invis (Desync)", CurrentValue = false, Callback = function(v) Toggles.Invis = v end})
MiscTab:CreateSlider({Name = "Invis Depth", Range = {-20, -5}, Increment = 1, CurrentValue = -10, Callback = function(v) Toggles.Depth = v end})
MiscTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Toggles.Noclip = v end})
MiscTab:CreateToggle({Name = "Full Bright", CurrentValue = false, Callback = function(v) Toggles.FullBright = v end})
MiscTab:CreateSection("Flight")
MiscTab:CreateToggle({Name = "Fly Hack", CurrentValue = false, Callback = function(v) Toggles.Fly = v end})
MiscTab:CreateSlider({Name = "Fly Speed", Range = {1, 20}, Increment = 1, CurrentValue = 1, Callback = function(v) Toggles.FlySpeed = v end})
MiscTab:CreateSection("Special Controls")
MiscTab:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
MiscTab:CreateButton({Name = "Flip 180°", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(180), 0) end})
MiscTab:CreateButton({Name = "Frontflip (DOD Style)", Callback = function() 
    pcall(function()
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.AngularVelocity = hrp.CFrame.RightVector * 25
        bav.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        task.wait(0.5)
        bav:Destroy()
    end)
end})

-- // --- CORE ENGINE --- //

RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end

        if Toggles.NameSpoof then char.Humanoid.DisplayName = "User Hidden" end
        if Toggles.FullBright then Lighting.Brightness = 2 Lighting.ClockTime = 14 end
        if Toggles.Noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        
        if Toggles.Fly then
            local hrp = char.HumanoidRootPart
            local bv = hrp:FindFirstChild("T_Fly") or Instance.new("BodyVelocity", hrp)
            bv.Name = "T_Fly"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Camera.CFrame.LookVector * (char.Humanoid.MoveDirection.Magnitude > 0 and (Toggles.FlySpeed * 50) or 0)
        elseif char.HumanoidRootPart:FindFirstChild("T_Fly") then char.HumanoidRootPart.T_Fly:Destroy() end

        if Toggles.Invis then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, Toggles.Depth, 0) end
            end
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") then return end
        local hum = char.Humanoid
        
        -- Speed Logic
        if hum.MoveDirection.Magnitude > 0 then
            local isRunning = (hum.WalkSpeed > 17)
            if isRunning and Toggles.RunSpeedOn then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (hum.MoveDirection * (Toggles.RunPower / 10))
            elseif not isRunning and Toggles.WalkSpeedOn then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (hum.MoveDirection * (Toggles.WalkPower / 10))
            end
        end
        if Toggles.AntiSlow and hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
        
        -- Stamina
        local isImK = false
        for _, k in pairs(Killers) do if LocalPlayer.Name:find(k) then isImK = true break end end
        if (isImK and Toggles.InfStamK) or (not isImK and Toggles.InfStamS) then
            local s = char:FindFirstChild("Stamina") or LocalPlayer:FindFirstChild("Stamina")
            if s then s.Value = isImK and Toggles.StamCapK or Toggles.StamCapS end
        end

        -- ESP & Auto Block
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local isK = false
                for _, k in pairs(Killers) do if p.Name:find(k) then isK = true break end end
                
                if Toggles.AutoBlock and isK then
                    local dist = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist <= Toggles.BlockDist then
                        local shouldBlock = true
                        if Toggles.FacingCheck then
                            local dot = char.HumanoidRootPart.CFrame.LookVector:Dot((p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Unit)
                            if dot < 0.3 then shouldBlock = false end
                        end
                        if shouldBlock then
                            local r = ReplicatedStorage:FindFirstChild("BlockEvent", true) or ReplicatedStorage:FindFirstChild("Block", true)
                            if r then r:FireServer() end
                        end
                    end
                end
                
                if p.Character:FindFirstChild("Head") then
                    local gui = p.Character.Head:FindFirstChild("T_ESP") or Instance.new("BillboardGui", p.Character.Head)
                    gui.Name = "T_ESP"
                    gui.Size, gui.AlwaysOnTop, gui.Enabled = UDim2.new(0, 150, 0, 50), true, (isK and Toggles.ESP_K) or (not isK and Toggles.ESP_S)
                    local txt = gui:FindFirstChild("L") or Instance.new("TextLabel", gui)
                    txt.Name = "L"
                    txt.BackgroundTransparency, txt.Size, txt.TextSize = 1, UDim2.new(1, 0, 1, 0), 12
                    txt.TextColor3 = isK and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    txt.Text = p.Name .. " [" .. math.floor(p.Character.Humanoid.Health) .. " HP]"
                end
            end
        end
    end)
end)

Rayfield:Notify({Title = "TWIST HUB", Content = "Script Complete! No Tab Changes Made.", Duration = 5})
