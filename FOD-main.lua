local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "fuck of death",
   LoadingTitle = "Applying Stealth Bypass...",
   LoadingSubtitle = "im feel fuck | Die Of Death Hub",
   ConfigurationSaving = { Enabled = true, FolderName = "FoD_Settings" }
})

-- // Global Variables //
local ESP_Killer, ESP_Survivor, ESP_Normal = false, false, false
local SpeedEnabled = True
local WalkSpeedValue = 0 -- Default multiplier
local Killers_List = {"Pursuer", "Harken", "Artful", "Badware", "Killdroid"}

-- // VISUALS TAB //
local VisualTab = Window:CreateTab("Visuals", 4483362458)

VisualTab:CreateToggle({
   Name = "Killer ESP (Red)",
   CurrentValue = false,
   Flag = "KillerToggle",
   Callback = function(Value) ESP_Killer = Value end,
})

VisualTab:CreateToggle({
   Name = "Survivor ESP (Green
    
