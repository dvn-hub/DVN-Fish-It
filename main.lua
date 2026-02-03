--[[ 
    DVN HUB - KING'S EDITION (FINAL FIXED)
    Based on: The Verified "Working" Script (50% Line UI).
    Updates:
    - BAIT SHOP: Now uses Dropdown (Floral, Midnight, Topwater, Luck).
    - LOGIC: Fixed Bait Purchase (Sends Quantity 1).
    - UI: 100% Original Logic Restored (Drag & Minimize Fixed).
]]

print("🚀 STARTING DVN HUB...")
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")

-- ====================================================================
-- [SYSTEM] SMART REMOTE FINDER
-- ====================================================================
local CachedRemotes = {}

local function GetRemote(remoteName)
    if CachedRemotes[remoteName] then return CachedRemotes[remoteName] end
    
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        for _, v in pairs(packages:GetDescendants()) do
            if v:IsA("RemoteFunction") then
                if v.Name == remoteName or v.Name == "RF/" .. remoteName then
                    print("✅ REMOTE CONNECTED:", v.Name)
                    CachedRemotes[remoteName] = v
                    return v
                end
            end
        end
    end
    return nil
end

local function InvokeShop(remoteName, itemId)
    local remote = GetRemote(remoteName)
    
    if remote and itemId then
        print("🛒 PROCESSING ID:", itemId)
        
        task.spawn(function()
            local success, res = pcall(function()
                -- [FIX] Logic khusus Bait harus kirim jumlah 1
                if remoteName == "PurchaseBait" or remoteName == "RF/PurchaseBait" then
                    return remote:InvokeServer(tonumber(itemId), 1) 
                else
                    return remote:InvokeServer(tonumber(itemId))
                end
            end)
            
            if success and res == true then
                print("✅ SUKSES TERBELI!")
            elseif success then
                warn("⚠️ DITOLAK SERVER (Cek Uang/Stok):", tostring(res))
            else
                warn("❌ ERROR SCRIPT:", res)
            end
        end)
    else
        warn("❌ Remote belum siap.")
    end
end
-- ====================================================================

-- GUI PARENT SAFE
local GUI_PARENT
if typeof(gethui) == "function" then
    GUI_PARENT = gethui()
else
    GUI_PARENT = LocalPlayer:WaitForChild("PlayerGui")
end

-- 1. SETUP GUI (ORIGINAL USER UI)
if GUI_PARENT:FindFirstChild("DVN_HUB_MAIN") then
    GUI_PARENT.DVN_HUB_MAIN:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_HUB_MAIN"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false

-- KONFIGURASI TAMPILAN
local Viewport = Camera.ViewportSize
local StartWidth = math.clamp(Viewport.X * 0.65, 400, 800)
local StartHeight = math.clamp(Viewport.Y * 0.65, 280, 600)

local DEFAULT_SIZE = UDim2.new(0, StartWidth, 0, StartHeight)
local MIN_SIZE = Vector2.new(350, 240)
local MINIMIZED_SIZE = UDim2.new(0, 200, 0, 32)

-- Palette
local MAIN_BG = Color3.fromRGB(15, 15, 15)
local ELEMENT_BG = Color3.fromRGB(30, 30, 30)
local ACCENT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local TEXT_DIM = Color3.fromRGB(120, 120, 120)

-- 2. MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = MAIN_BG
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ACCENT_COLOR
MainStroke.Transparency = 0.5
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- [AESTHETIC] Main Gradient
local MainGradient = Instance.new("UIGradient")
MainGradient.Rotation = 45
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(150, 150, 150))
}
MainGradient.Parent = MainFrame

-- 3. HEADER
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "DVN HUB"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = TEXT_COLOR
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 32, 1, 0)
MinBtn.Position = UDim2.new(1, -32, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = TEXT_COLOR
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = ACCENT_COLOR
HeaderLine.BackgroundTransparency = 0.8
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

-- [AESTHETIC] Line Gradient
local LineGradient = Instance.new("UIGradient")
LineGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0.0, 1),
    NumberSequenceKeypoint.new(0.5, 0.2),
    NumberSequenceKeypoint.new(1.0, 1)
}
LineGradient.Parent = HeaderLine

-- 4. BODY & CONTENT
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, 0, 1, -32)
Body.Position = UDim2.new(0, 0, 0, 32)
Body.BackgroundTransparency = 1
Body.ClipsDescendants = true
Body.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0.28, 0, 1, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Body

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 2)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.Parent = Sidebar

local SepLine = Instance.new("Frame")
SepLine.Size = UDim2.new(0, 1, 1, 0)
SepLine.Position = UDim2.new(0.28, 0, 0, 0)
SepLine.BackgroundColor3 = ACCENT_COLOR
SepLine.BackgroundTransparency = 0.8
SepLine.BorderSizePixel = 0
SepLine.Parent = Body

local Content = Instance.new("Frame")
Content.Size = UDim2.new(0.72, 0, 1, 0)
Content.Position = UDim2.new(0.28, 0, 0, 0)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Body

-- 5. TAB SYSTEM
local Tabs = {"Info", "Fishing", "Shop", "Teleport", "Config", "Misc"}
local TabFrames = {}
local TabButtons = {}

local function SwitchTab(activeName)
    for name, frame in pairs(TabFrames) do
        frame.Visible = (name == activeName)
    end
    for name, btn in pairs(TabButtons) do
        if name == activeName then
            btn.TextColor3 = TEXT_COLOR
            btn.BackgroundTransparency = 0.9
        else
            btn.TextColor3 = TEXT_DIM
            btn.BackgroundTransparency = 1
        end
    end
end

for i, name in ipairs(Tabs) do
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = ACCENT_COLOR
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.Parent = Content
    
    local PLayout = Instance.new("UIListLayout")
    PLayout.Padding = UDim.new(0, 5)
    PLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PLayout.Parent = Page
    
    local PPad = Instance.new("UIPadding")
    PPad.PaddingTop = UDim.new(0, 5)
    PPad.PaddingLeft = UDim.new(0, 5)
    PPad.PaddingRight = UDim.new(0, 5)
    PPad.Parent = Page
    
    TabFrames[name] = Page
    
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.LayoutOrder = i
    Btn.Size = UDim2.new(1, -16, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextColor3 = TEXT_DIM
    Btn.Parent = Sidebar
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = Btn
end

-- 6. HELPER COMPONENTS
local function GetOrder(parent) return #parent:GetChildren() end

function CreateSection(parent, text)
    local Lab = Instance.new("TextLabel")
    Lab.LayoutOrder = GetOrder(parent)
    Lab.Text = text:upper()
    Lab.Size = UDim2.new(1, 0, 0, 24)
    Lab.BackgroundTransparency = 1
    Lab.TextColor3 = ACCENT_COLOR
    Lab.TextTransparency = 0.4
    Lab.Font = Enum.Font.GothamBold
    Lab.TextSize = 12
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.Parent = parent
end

function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.LayoutOrder = GetOrder(parent)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = ELEMENT_BG
    Btn.Text = text
    Btn.TextColor3 = TEXT_COLOR
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.LayoutOrder = GetOrder(parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = ELEMENT_BG
    Frame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame
    local Lab = Instance.new("TextLabel")
    Lab.Text = text
    Lab.Size = UDim2.new(0.7, 0, 1, 0)
    Lab.Position = UDim2.new(0, 10, 0, 0)
    Lab.BackgroundTransparency = 1
    Lab.TextColor3 = TEXT_COLOR
    Lab.Font = Enum.Font.GothamBold
    Lab.TextSize = 14
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.Parent = Frame
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 36, 0, 18)
    ToggleBtn.Position = UDim2.new(1, -42, 0.5, -9)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = ToggleBtn
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Dot.Parent = ToggleBtn
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(1, 0)
    DCorner.Parent = Dot
    local on = false
    ToggleBtn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
        pcall(callback, on)
    end)
end

function CreateDropdown(parent, text, options, defaultOption, callback)
    local Frame = Instance.new("Frame")
    Frame.LayoutOrder = GetOrder(parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = ELEMENT_BG
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame
    local Lab = Instance.new("TextLabel")
    Lab.Text = defaultOption and (text .. ": " .. defaultOption) or text
    Lab.Size = UDim2.new(0.6, 0, 0, 30)
    Lab.Position = UDim2.new(0, 10, 0, 0)
    Lab.BackgroundTransparency = 1
    Lab.TextColor3 = defaultOption and Color3.fromRGB(255, 255, 255) or TEXT_COLOR
    Lab.Font = Enum.Font.GothamBold
    Lab.TextSize = 14
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.Parent = Frame
    local Arrow = Instance.new("TextLabel")
    Arrow.Text = "▼"
    Arrow.Size = UDim2.new(0, 30, 0, 30)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.TextColor3 = TEXT_DIM
    Arrow.TextSize = 12
    Arrow.Parent = Frame
    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 0, 0, 30)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = Frame
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "DropScroll"
    Container.Size = UDim2.new(1, -4, 0, 0)
    Container.Position = UDim2.new(0, 2, 0, 32)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = ACCENT_COLOR
    Container.Parent = Frame
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 2)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Container
    local itemHeight = 24
    local maxVisibleItems = 5
    local contentHeight = #options * (itemHeight + 2)
    local viewHeight = math.min(contentHeight, maxVisibleItems * (itemHeight + 2))
    Container.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    local isOpen = false
    local currentSelection = defaultOption
    for _, opt in ipairs(options) do
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(1, -4, 0, itemHeight)
        B.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        B.Text = opt
        B.TextColor3 = TEXT_COLOR
        B.Font = Enum.Font.GothamBold
        B.TextSize = 13
        B.Parent = Container
        local C = Instance.new("UICorner")
        C.CornerRadius = UDim.new(0, 3)
        C.Parent = B
        B.MouseButton1Click:Connect(function()
            if currentSelection == opt then
                currentSelection = nil
                Lab.Text = text
                Lab.TextColor3 = TEXT_COLOR
                pcall(callback, nil)
            else
                currentSelection = opt
                Lab.Text = text .. ": " .. opt
                Lab.TextColor3 = Color3.fromRGB(255, 255, 255)
                pcall(callback, opt)
            end
            isOpen = false
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
            TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, -4, 0, 0)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
        end)
    end
    Trigger.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30 + viewHeight + 4)}):Play()
            TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, -4, 0, viewHeight)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
            TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, -4, 0, 0)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
        end
    end)
    
    -- Set Default Value Logic
    if defaultOption then
        pcall(callback, defaultOption)
    end
end

-- 7. KONTEN

-- [INFO]
CreateSection(TabFrames["Info"], "About")
local InfoTxt = Instance.new("TextLabel")
InfoTxt.LayoutOrder = GetOrder(TabFrames["Info"])
InfoTxt.Text = "Thank you for using DVN Hub!\nThis tool is created to enhance your experience and make your gameplay easier.\n\nUse this tool at your own risk. DVN Team is not responsible for any misuse or consequences.\n\nBrought to you with care by DVN.\nEnjoy and have fun!"
InfoTxt.Size = UDim2.new(1, 0, 0, 120)
InfoTxt.BackgroundTransparency = 1
InfoTxt.TextColor3 = TEXT_DIM
InfoTxt.Font = Enum.Font.GothamBold
InfoTxt.TextSize = 13
InfoTxt.TextXAlignment = Enum.TextXAlignment.Left
InfoTxt.TextWrapped = true
InfoTxt.Parent = TabFrames["Info"]

CreateSection(TabFrames["Info"], "Official Discord DVN!")
local JoinUsTxt = Instance.new("TextLabel")
JoinUsTxt.LayoutOrder = GetOrder(TabFrames["Info"])
JoinUsTxt.Text = "Join Us!"
JoinUsTxt.Size = UDim2.new(1, 0, 0, 15)
JoinUsTxt.BackgroundTransparency = 1
JoinUsTxt.TextColor3 = TEXT_DIM
JoinUsTxt.Font = Enum.Font.GothamBold
JoinUsTxt.TextSize = 12
JoinUsTxt.TextXAlignment = Enum.TextXAlignment.Left
JoinUsTxt.Parent = TabFrames["Info"]

CreateButton(TabFrames["Info"], "Copy Discord Link", function()
    setclipboard("https://discord.gg/YOUR_DISCORD_LINK") 
end)

-- [FISHING & SHOP]
CreateSection(TabFrames["Fishing"], "Main")
CreateToggle(TabFrames["Fishing"], "Auto Fish", function(v) end)

-- === SHOP SECTION (ROD) ===
CreateSection(TabFrames["Shop"], "Rod Shop")

local RodsDB = {
    {Name = "Luck Rod", Price = 225, Id = 79},
    {Name = "Carbon Rod", Price = 750, Id = 76},
    {Name = "Grass Rod", Price = 1500, Id = 85},
    {Name = "Demascus Rod", Price = 3000, Id = 77},
    {Name = "Ice Rod", Price = 5000, Id = 78},
    {Name = "Lucky Rod", Price = 15000, Id = 4},
    {Name = "Midnight Rod", Price = 50000, Id = 80},
    {Name = "Steampunk Rod", Price = 215000, Id = 6},
    {Name = "Chrome Rod", Price = 437000, Id = 7},
    {Name = "Astral Rod", Price = 1000000, Id = 5},
    {Name = "Ares Rod", Price = 3000000, Id = 126},
    {Name = "Angler Rod", Price = 8000000, Id = 168},
    {Name = "Bamboo Rod", Price = 12000000, Id = 258}
}

local RodOptions = {}
local RodLookup = {}

local function FormatPrice(n)
    local formatted = tostring(n)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return formatted
end

for _, rod in ipairs(RodsDB) do
    local label = rod.Name .. " ($" .. FormatPrice(rod.Price) .. ")"
    table.insert(RodOptions, label)
    RodLookup[label] = rod.Id
end

local selectedRodLabel = nil

CreateDropdown(TabFrames["Shop"], "Select Rod", RodOptions, nil, function(val)
    selectedRodLabel = val
end)

CreateButton(TabFrames["Shop"], "Buy Selected Rod", function()
    local id = RodLookup[selectedRodLabel]
    if id then
        InvokeShop("PurchaseFishingRod", id)
    else
        warn("⚠️ Pilih rod dulu!")
    end
end)

-- === BAIT SHOP (UPDATED: DROPDOWN) ===
CreateSection(TabFrames["Shop"], "Bait Shop")

local BaitsDB = {
    {Name = "Topwater Bait", Price = 100, Id = 10},
    {Name = "Luck Bait", Price = 1000, Id = 2},
    {Name = "Midnight Bait", Price = 3000, Id = 3},
    {Name = "Nature Bait", Price = 83500, Id = 17},
    {Name = "Chroma Bait", Price = 290000, Id = 6},
    {Name = "Dark Matter Bait", Price = 630000, Id = 8},
    {Name = "Corrupt Bait", Price = 1148484, Id = 15},
    {Name = "Aether Bait", Price = 3700000, Id = 16},
    {Name = "Floral Bait", Price = 4000000, Id = 20}
}

local BaitOptions = {}
local BaitLookup = {}

for _, bait in ipairs(BaitsDB) do
    local label = bait.Name .. " ($" .. FormatPrice(bait.Price) .. ")"
    table.insert(BaitOptions, label)
    BaitLookup[label] = bait.Id
end

local selectedBaitLabel = nil

CreateDropdown(TabFrames["Shop"], "Select Bait", BaitOptions, nil, function(val)
    selectedBaitLabel = val
end)

CreateButton(TabFrames["Shop"], "Buy Selected Bait", function()
    local id = BaitLookup[selectedBaitLabel]
    if id then
        InvokeShop("PurchaseBait", id)
    else
        warn("⚠️ Pilih bait dulu!")
    end
end)

-- === WEATHER SHOP (MULTI-TOGGLE) ===
CreateSection(TabFrames["Shop"], "Weather Shop")

-- [LOGIC] Weather Auto-Buy
_G.ActiveWeathers = {
    ["Cloudy"] = false,
    ["Wind"] = false,
    ["Radiant"] = false,
    ["Snow"] = false,
    ["Storm"] = false,
    ["Shark Hunt"] = false
}

local function GetWeatherRemote()
    local path = ReplicatedStorage:FindFirstChild("Packages")
    if path and path:FindFirstChild("_Index") then
        local idx = path._Index
        local netPkg = idx:FindFirstChild("sleitnick_net@0.2.0")
        if netPkg and netPkg:FindFirstChild("net") then
            return netPkg.net:FindFirstChild("RF/PurchaseWeatherEvent")
        end
    end
    return nil
end

local function IsWeatherActive(name)
    local UI = LocalPlayer.PlayerGui:FindFirstChild("Events")
    if UI and UI:FindFirstChild("Frame") and UI.Frame:FindFirstChild("Events") then
        local EventFrame = UI.Frame.Events:FindFirstChild(name)
        return EventFrame and EventFrame.Visible == true
    end
    return false
end

task.spawn(function()
    while task.wait(5) do
        if _G.ActiveWeathers then
            for name, isEnabled in pairs(_G.ActiveWeathers) do
                if isEnabled and not IsWeatherActive(name) then
                    local remote = GetWeatherRemote()
                    if remote then
                        remote:InvokeServer(name)
                    end
                end
            end
        end
    end
end)

-- [UI] Weather Dropdown (Custom Multi-Select)
local WFrame = Instance.new("Frame")
WFrame.LayoutOrder = GetOrder(TabFrames["Shop"])
WFrame.Size = UDim2.new(1, 0, 0, 30)
WFrame.BackgroundColor3 = ELEMENT_BG
WFrame.ClipsDescendants = true
WFrame.Parent = TabFrames["Shop"]

local WCorner = Instance.new("UICorner")
WCorner.CornerRadius = UDim.new(0, 4)
WCorner.Parent = WFrame

local WLabel = Instance.new("TextLabel")
WLabel.Text = "Manage Weathers"
WLabel.Size = UDim2.new(0.6, 0, 0, 30)
WLabel.Position = UDim2.new(0, 10, 0, 0)
WLabel.BackgroundTransparency = 1
WLabel.TextColor3 = TEXT_COLOR
WLabel.Font = Enum.Font.GothamBold
WLabel.TextSize = 14
WLabel.TextXAlignment = Enum.TextXAlignment.Left
WLabel.Parent = WFrame

local WArrow = Instance.new("TextLabel")
WArrow.Text = "▼"
WArrow.Size = UDim2.new(0, 30, 0, 30)
WArrow.Position = UDim2.new(1, -30, 0, 0)
WArrow.BackgroundTransparency = 1
WArrow.TextColor3 = TEXT_DIM
WArrow.TextSize = 12
WArrow.Parent = WFrame

local WTrigger = Instance.new("TextButton")
WTrigger.Size = UDim2.new(1, 0, 0, 30)
WTrigger.BackgroundTransparency = 1
WTrigger.Text = ""
WTrigger.Parent = WFrame

local WContainer = Instance.new("ScrollingFrame")
WContainer.Size = UDim2.new(1, -4, 0, 0)
WContainer.Position = UDim2.new(0, 2, 0, 32)
WContainer.BackgroundTransparency = 1
WContainer.BorderSizePixel = 0
WContainer.ScrollBarThickness = 2
WContainer.ScrollBarImageColor3 = ACCENT_COLOR
WContainer.Parent = WFrame

local WList = Instance.new("UIListLayout")
WList.Padding = UDim.new(0, 2)
WList.SortOrder = Enum.SortOrder.LayoutOrder
WList.Parent = WContainer

local wOptions = {"Cloudy", "Wind", "Radiant", "Snow", "Storm", "Shark Hunt"}
local wItemH = 30
local wContentH = #wOptions * (wItemH + 2)
local wViewH = math.min(wContentH, 5 * (wItemH + 2))

WContainer.CanvasSize = UDim2.new(0, 0, 0, wContentH)

for _, name in ipairs(wOptions) do
    local Item = Instance.new("Frame")
    Item.Size = UDim2.new(1, -4, 0, wItemH)
    Item.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Item.Parent = WContainer
    
    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(0, 3)
    ICorner.Parent = Item
    
    local ILabel = Instance.new("TextLabel")
    ILabel.Text = name
    ILabel.Size = UDim2.new(1, -50, 1, 0)
    ILabel.Position = UDim2.new(0, 10, 0, 0)
    ILabel.BackgroundTransparency = 1
    ILabel.TextColor3 = TEXT_COLOR
    ILabel.Font = Enum.Font.GothamBold
    ILabel.TextSize = 13
    ILabel.TextXAlignment = Enum.TextXAlignment.Left
    ILabel.Parent = Item
    
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 36, 0, 18)
    Toggle.Position = UDim2.new(1, -42, 0.5, -9)
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Toggle.Text = ""
    Toggle.Parent = Item
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = Toggle
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Dot.Parent = Toggle
    
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(1, 0)
    DCorner.Parent = Dot
    
    Toggle.MouseButton1Click:Connect(function()
        _G.ActiveWeathers[name] = not _G.ActiveWeathers[name]
        local on = _G.ActiveWeathers[name]
        if on then
            TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        else
            TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end)
end

local wOpen = false
WTrigger.MouseButton1Click:Connect(function()
    wOpen = not wOpen
    if wOpen then
        TweenService:Create(WFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30 + wViewH + 4)}):Play()
        TweenService:Create(WContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, -4, 0, wViewH)}):Play()
        TweenService:Create(WArrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
    else
        TweenService:Create(WFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
        TweenService:Create(WContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, -4, 0, 0)}):Play()
        TweenService:Create(WArrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
    end
end)

-- [TELEPORT]
CreateSection(TabFrames["Teleport"], "Island")
local Locations = {
    ["Ancient Jungle"]     = Vector3.new(1472.61, 4.79, -331.18),
    ["Ancient Ruin"]       = Vector3.new(6046.77, -588.60, 4611.83),
    ["Christmas Cave"]     = Vector3.new(713.52, -487.11, 8870.00),
    ["Christmas Island"]   = Vector3.new(1178.85, 24.10, 1585.74),
    ["Coral Reefs"]        = Vector3.new(-3113.50, 2.48, 2138.63),
    ["Crater Island"]      = Vector3.new(978.00, 46.90, 5087.00),
    ["Esotoric Depths"]    = Vector3.new(3248.44, -1293.43, 1435.97),
    ["Fisherman Island"]   = Vector3.new(-65.84, 3.26, 2856.85),
    ["Kohana"]             = Vector3.new(-442.29, 17.25, 493.56),
    ["Kohana Volcano"]     = Vector3.new(-554.06, 17.08, 113.67),
    ["Sacred Temple"]      = Vector3.new(1519.95, 4.89, -671.92),
    ["Sisyphus Statue"]    = Vector3.new(-3743.65, -135.07, -1007.13),
    ["Treasure Room"]      = Vector3.new(-3649.53, -269.23, -1655.62),
    ["Tropical Grove"]     = Vector3.new(-2173.73, 53.49, 3630.97),
    ["Underground Cellar"] = Vector3.new(2139.71, -91.40, -764.99)
}

local PlaceNames = {}
for name, _ in pairs(Locations) do table.insert(PlaceNames, name) end
table.sort(PlaceNames)

local selectedPlace = nil
CreateDropdown(TabFrames["Teleport"], "Select Location", PlaceNames, nil, function(val) selectedPlace = val end)
CreateButton(TabFrames["Teleport"], "Teleport to Location", function()
    if selectedPlace and Locations[selectedPlace] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Locations[selectedPlace])
    end
end)

-- 8. CORE LOGIC (DRAG & HELPER LINE)

local HelperLine = Instance.new("TextButton")
HelperLine.Name = "HelperLine"
HelperLine.Text = ""
HelperLine.BackgroundColor3 = ACCENT_COLOR
HelperLine.BorderSizePixel = 0
HelperLine.BackgroundTransparency = 0.3
HelperLine.AnchorPoint = Vector2.new(0.5, 0)
HelperLine.Parent = ScreenGui
HelperLine.ZIndex = MainFrame.ZIndex - 1
Instance.new("UICorner", HelperLine).CornerRadius = UDim.new(1, 0)

local function UpdateHelperLine()
    if not MainFrame or not MainFrame.Parent then return end
    local mainPos = MainFrame.AbsolutePosition
    local mainSize = MainFrame.AbsoluteSize
    local centerX = mainPos.X + (mainSize.X / 2)
    local bottomY = mainPos.Y + mainSize.Y
    HelperLine.Position = UDim2.new(0, centerX, 0, bottomY + 4)
    HelperLine.Size = UDim2.new(0, mainSize.X * 0.5, 0, 5) 
end
MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateHelperLine)
MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateHelperLine)
UpdateHelperLine()

HelperLine.MouseEnter:Connect(function() TweenService:Create(HelperLine, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() end)
HelperLine.MouseLeave:Connect(function() TweenService:Create(HelperLine, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play() end)

local dragging, dragStart, startPos
local function StartDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end
Header.InputBegan:Connect(StartDrag)
HelperLine.InputBegan:Connect(StartDrag)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local isMin, lastSize = false, DEFAULT_SIZE
MinBtn.MouseButton1Click:Connect(function()
    if isMin then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = lastSize}):Play()
        Body.Visible = true; HelperLine.Visible = true; MinBtn.Text = "-"
    else
        lastSize = MainFrame.Size
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = MINIMIZED_SIZE}):Play()
        Body.Visible = false; HelperLine.Visible = false; MinBtn.Text = "+"
    end
    isMin = not isMin
end)

local ResizeBtn = Instance.new("ImageButton")
ResizeBtn.Size = UDim2.new(0, 15, 0, 15)
ResizeBtn.Position = UDim2.new(1, -15, 1, -15)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Image = "rbxassetid://3599185146"
ResizeBtn.ImageTransparency = 0.5
ResizeBtn.ImageColor3 = ACCENT_COLOR
ResizeBtn.Parent = MainFrame

local resizing, resizeStart, startSize
ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true; resizeStart = input.Position; startSize = MainFrame.AbsoluteSize
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - resizeStart
        MainFrame.Size = UDim2.new(0, math.max(MIN_SIZE.X, startSize.X + delta.X), 0, math.max(MIN_SIZE.Y, startSize.Y + delta.Y))
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

SwitchTab("Info")

-- [AESTHETIC] Startup Animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = DEFAULT_SIZE}):Play()

print("DVN HUB UI LOADED")