--=========================
-- Brainrot Finder Hub V6
--=========================
if _G.BrainrotFinderRunning then return end
_G.BrainrotFinderRunning = true

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- =====================
-- Charger JobIDs JSON depuis ton lien raw
-- =====================
local jobID_URL = "https://cdn.sourceb.in/bins/56dCLhcpiG/0"
local JobIDs = {}
pcall(function()
    local data = game:HttpGet(jobID_URL)
    JobIDs = HttpService:JSONDecode(data)
end)

-- =====================
-- Config persistante
-- =====================
_G.FinderConfig = _G.FinderConfig or {
    running = false,
    minRare = "",
    name = "",
    minGen = 0
}

-- =====================
-- UI HUB (modern)
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Hub = Instance.new("Frame")
Hub.Size = UDim2.new(0, 500, 0, 400)
Hub.Position = UDim2.new(0.5, -250, 0.15, 0)
Hub.BackgroundColor3 = Color3.fromRGB(15,15,15)
Hub.BorderSizePixel = 0
Hub.Parent = ScreenGui
Hub.Active = true
Hub.Draggable = true

-- Header
local header = Instance.new("Frame", Hub)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", header)
title.Text = "⚡ Brainrot Finder V6"
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left

-- Filters Section
local filters = Instance.new("TextLabel", Hub)
filters.Text = "🔎 Filters"
filters.Size = UDim2.new(1, -20, 0, 25)
filters.Position = UDim2.new(0, 10, 0, 60)
filters.BackgroundTransparency = 1
filters.TextColor3 = Color3.fromRGB(200,200,200)
filters.Font = Enum.Font.GothamBold
filters.TextSize = 18
filters.TextXAlignment = Enum.TextXAlignment.Left

local rareBox = Instance.new("TextBox", Hub)
rareBox.PlaceholderText = "Rareté min (ex: Rare)"
rareBox.Text = _G.FinderConfig.minRare
rareBox.Size = UDim2.new(0, 480, 0, 28)
rareBox.Position = UDim2.new(0, 10, 0, 90)
rareBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
rareBox.TextColor3 = Color3.fromRGB(255,255,255)
rareBox.Font = Enum.Font.Gotham
rareBox.TextSize = 16

local nameBox = Instance.new("TextBox", Hub)
nameBox.PlaceholderText = "Nom Brainrot (optionnel)"
nameBox.Text = _G.FinderConfig.name
nameBox.Size = UDim2.new(0, 480, 0, 28)
nameBox.Position = UDim2.new(0, 10, 0, 125)
nameBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
nameBox.TextColor3 = Color3.fromRGB(255,255,255)

-- Dropdown génération
local genOptions = {"100K","200K","500K","1M","10M","50M","100M"}
local genValues = {1e5,2e5,5e5,1e6,1e7,5e7,1e8}

local genBtn = Instance.new("TextButton", Hub)
genBtn.Text = "Min: "..(_G.FinderConfig.minGen > 0 and _G.FinderConfig.minGen or "0")
genBtn.Size = UDim2.new(0, 480, 0, 30)
genBtn.Position = UDim2.new(0, 10, 0, 160)
genBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
genBtn.TextColor3 = Color3.fromRGB(255,255,255)
genBtn.Font = Enum.Font.Gotham
genBtn.TextSize = 16

genBtn.MouseButton1Click:Connect(function()
    local menu = Instance.new("Frame", Hub)
    menu.Size = UDim2.new(0, 200, 0, #genOptions*28)
    menu.Position = UDim2.new(0, 10, 0, 195)
    menu.BackgroundColor3 = Color3.fromRGB(25,25,25)
    menu.BorderSizePixel = 0

    for i,opt in ipairs(genOptions) do
        local b = Instance.new("TextButton", menu)
        b.Text = opt
        b.Size = UDim2.new(1, 0, 0, 28)
        b.Position = UDim2.new(0, 0, 0, (i-1)*28)
        b.BackgroundColor3 = Color3.fromRGB(45,45,45)
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.MouseButton1Click:Connect(function()
            genBtn.Text = "Min: "..opt
            _G.FinderConfig.minGen = genValues[i]
            menu:Destroy()
        end)
    end
end)

-- Controls Section
local controls = Instance.new("TextLabel", Hub)
controls.Text = "⚙️ Controls"
controls.Size = UDim2.new(1, -20, 0, 25)
controls.Position = UDim2.new(0, 10, 0, 230)
controls.BackgroundTransparency = 1
controls.TextColor3 = Color3.fromRGB(200,200,200)
controls.Font = Enum.Font.GothamBold
controls.TextSize = 18
controls.TextXAlignment = Enum.TextXAlignment.Left

local toggleBtn = Instance.new("TextButton", Hub)
toggleBtn.Text = _G.FinderConfig.running and "🟢 ON" or "🔴 OFF"
toggleBtn.Size = UDim2.new(0, 480, 0, 35)
toggleBtn.Position = UDim2.new(0, 10, 0, 260)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20

toggleBtn.MouseButton1Click:Connect(function()
    _G.FinderConfig.running = not _G.FinderConfig.running
    toggleBtn.Text = _G.FinderConfig.running and "🟢 ON" or "🔴 OFF"
end)

-- Logs Section
local logs = Instance.new("TextLabel", Hub)
logs.Size = UDim2.new(0, 480, 0, 60)
logs.Position = UDim2.new(0, 10, 0, 310)
logs.BackgroundColor3 = Color3.fromRGB(25,25,25)
logs.TextColor3 = Color3.fromRGB(150,255,150)
logs.Font = Enum.Font.Code
logs.TextSize = 14
logs.Text = "Status: Waiting..."
logs.TextWrapped = true

local function log(msg)
    logs.Text = "Status: "..msg
end

-- =====================
-- Notification
-- =====================
local function notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Brainrot Finder",
        Text = msg,
        Duration = 4
    })
    log(msg)
end

-- =====================
-- Parse Generation
-- =====================
local function parseGen(txt)
    local v = tonumber(txt:match("[%d%.]+"))
    if not v then return 0 end
    if txt:find("K") then v*=1e3 elseif txt:find("M") then v*=1e6 end
    return v
end

-- =====================
-- Finder Loop
-- =====================
task.spawn(function()
    while task.wait(2) do
        if _G.FinderConfig.running then
            local found = false
            for _, m in pairs(Workspace:GetChildren()) do
                if m:IsA("Model") then
                    local rare = m:FindFirstChild("Rarity", true)
                    local disp = m:FindFirstChild("DisplayName", true)
                    local gen = m:FindFirstChild("Generation", true)

                    local r = rare and rare.Text:lower() or ""
                    local n = disp and disp.Text:lower() or ""
                    local g = gen and parseGen(gen.Text) or 0

                    local okRare = (_G.FinderConfig.minRare=="" or r:find(_G.FinderConfig.minRare:lower()))
                    local okName = (_G.FinderConfig.name=="" or n:find(_G.FinderConfig.name:lower()))
                    local okGen = g >= _G.FinderConfig.minGen

                    if okRare and okName and okGen then
                        found = true
                        notify("✅ Found "..(n or m.Name).." | "..(gen and gen.Text or ""))
                    end
                end
            end
            if not found then
                local randomJob = JobIDs[math.random(1,#JobIDs)]
                notify("⚠️ Nothing found, hopping...")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomJob, player)
            end
        end
    end
end)

-- =====================
-- Persistance après hop
-- =====================
player.CharacterAdded:Connect(function()
    task.wait(3)
    if not _G.BrainrotFinderRunning then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/networkchannel/hubfinder/refs/heads/main/txt.lua?t"))()
    end
end)
