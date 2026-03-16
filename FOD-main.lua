local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "fuck of death",
   LoadingTitle = "Stealth Bypass Active",
   LoadingSubtitle = "by Gemini | Forsaken Hub",
   ConfigurationSaving = { Enabled = true, FolderName = "FoD_Settings" }
})

local ESP_Killer, ESP_Survivor, ESP_Normal = true, true, false
local SpeedEnabled = false
local WalkSpeedValue = 0 
local Killers_List = {"Pursuer", "Harken", "Artful", "Badware", "Killdroid"}

local VisualTab = Window:CreateTab("Visuals", 4483362458)

VisualTab:CreateToggle({
   Name = "Killer ESP (Red)",
   CurrentValue = false,
   Flag = "K_ESP",
   Callback = function(Value) ESP_Killer = Value end,
})

VisualTab:CreateToggle({
   Name = "Survivor ESP (Green)",
   CurrentValue = true,
   Flag = "S_ESP",
   Callback = function(Value) ESP_Survivor = Value end,
})

VisualTab:CreateToggle({
   Name = "Normal Player ESP (Blue)",
   CurrentValue = false,
   Flag = "N_ESP",
   Callback = function(Value) ESP_Normal = Value end,
})

local MovementTab = Window:CreateTab("Movement", 4483362458)

MovementTab:CreateToggle({
   Name = "Enable Stealth Speed",
   CurrentValue = false,
   Flag = "S_Toggle",
   Callback = function(Value) SpeedEnabled = Value end,
})

MovementTab:CreateSlider({
   Name = "Speed Multiplier",
   Range = {0, 100}, 
   Increment = 0.1,
   CurrentValue = 0,
   Flag = "S_Slider",
   Callback = function(Value) WalkSpeedValue = Value end,
})

task.spawn(function()
    game:GetService("RunService").Heartbeat:Connect(function()
        if SpeedEnabled then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (WalkSpeedValue / 10))
                end
            end)
        end
    end)
end)

local function GetPlayerRole(Player)
    local Character = Player.Character
    local Team = Player.Team
    if Character then
        for _, name in pairs(Killers_List) do
            if string.find(Character.Name, name) or (Team and string.find(Team.Name, "Killer")) then
                return "Killer", Color3.fromRGB(255, 0, 0)
            end
        end
    end
    if Team and (Team.Name == "Civilian" or Team.Name == "Survivor") then
        return "Survivor", Color3.fromRGB(0, 255, 0)
    end
    return "Normal", Color3.fromRGB(0, 0, 255)
end

local function CreateESP(Player)
    if Player == game.Players.LocalPlayer then return end
    local function SetupHighlight()
        if not Player.Character then return end
        local Highlight = Player.Character:FindFirstChild("FoD_HL") or Instance.new("Highlight")
        Highlight.Name = "FoD_HL"
        Highlight.Parent = Player.Character
        Highlight.FillTransparency = 0.4
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        task.spawn(function()
            while Player.Character and Player.Character:FindFirstChild("FoD_HL") do
                local role, color = GetPlayerRole(Player)
                Highlight.FillColor = color
                if role == "Killer" then Highlight.Enabled = ESP_Killer
                elseif role == "Survivor" then Highlight.Enabled = ESP_Survivor
                elseif role == "Normal" then Highlight.Enabled = ESP_Normal
                else Highlight.Enabled = false end
                task.wait(0.5)
            end
        end)
    end
    Player.CharacterAdded:Connect(SetupHighlight)
    if Player.Character then SetupHighlight() end
end

for _, p in pairs(game.Players:GetPlayers()) do CreateESP(p) end
game.Players.PlayerAdded:Connect(CreateESP)

Rayfield:Notify({Title = "fuck of death", Content = "Loaded Successfully", Duration = 4})
