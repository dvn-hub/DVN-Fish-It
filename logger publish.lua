--[[ 
    💎 DVN LOGGER - PUBLIC RELEASE
    Theme: Dark Glassy
    Version: 1.0 Public
]]

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
local req = http_request or request or (fluxus and fluxus.request) or (getgenv and getgenv().request) or (syn and syn.request)

-- GUI PARENT SAFE
local GUI_PARENT = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- ====================================================================
-- 1. LOGGER SETTINGS & LOGIC
-- ====================================================================
local SETTINGS = {
    WebhookURL = "",
    LogFish = false, -- Default OFF
    LogJoinLeave = false -- Default OFF
}

-- CONFIG DATA
local WEBHOOK_NAME = "DVN Logger"
local WEBHOOK_AVATAR = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png?ex=6980273b&is=697ed5bb&hm=733d137fca895eb5eaf2fcc9b67eff946bf40665d3665ac455ad32d70f6fea07&"

local RARITY_CONFIG = {
    Epic      = { Enabled = false, Color = 0xB373F8, Icon = "🟣" },
    Legendary = { Enabled = false, Color = 0xFFB92B, Icon = "🟡" },
    Mythic    = { Enabled = false, Color = 0xFF1919, Icon = "🔴" },
    Secret    = { Enabled = false, Color = 0x18FF98, Icon = "💎" },
}

local FOCUS_FISH = {
    ["Sacred Guardian Squid"] = { Enabled = false, Color = 0x00FBFF }, -- Cyan
    ["GEMSTONE Ruby"]         = { Enabled = false, Color = 0xFF0040 }, -- Ruby Red
    ["GEMSTONE Shiny Ruby"]   = { Enabled = false, Color = 0xFF0040 }, -- Ruby Red
    ["GEMSTONE Big Ruby"]     = { Enabled = false, Color = 0xFF0040 }  -- Ruby Red
}

local RGB_RARITY = {
    ["179,115,248"] = "Epic", ["255,185,43"] = "Legendary", 
    ["255,25,25"] = "Mythic", ["24,255,152"] = "Secret"
}

-- UTIL FUNCTIONS
local function stripRichText(t) return t:gsub("<.->", "") end

local function extractDisplayName(text)
    local clean = stripRichText(text)
    return clean:match("^%[Server%]:%s*(.-)%s*obtained") or clean:match("^(.-)%s*obtained") or "Unknown"
end

local function detectChance(t) return t:match("1 in ([%dKMB]+)") or "?" end

local function detectRarity(text)
    local r,g,b = text:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)")
    return r and (RGB_RARITY[r..","..g..","..b] or "Other") or "Other"
end

local function detectFishNameAndWeight(text)
    local clean = stripRichText(text)
    local openParen = clean:match("^.*()%(")
    local fish, weight
    if openParen then
        local fishPart = clean:sub(1, openParen - 1)
        local weightPart = clean:sub(openParen + 1)
        fish = fishPart:match("obtained%s+a[n]?%s+(.+)") or fishPart:match("obtained%s+(.+)")
        weight = weightPart:match("^(.-)%)")
    else
        fish = clean:match("obtained%s+a[n]?%s+(.+)") or clean:match("obtained%s+(.+)")
        weight = "-"
    end
    return (fish and fish:gsub("%s+$", "") or "Unknown Fish"), (weight or "-")
end

-- WEBHOOK FUNCTIONS
local function send(payload)
    if SETTINGS.WebhookURL == "" or not req then return end
    pcall(function()
        req({ Url = SETTINGS.WebhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(payload) })
    end)
end

local function testWebhook()
    local timeStr = os.date("%I:%M %p")
    send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {{ title = "✅ Webhook Connected", description = "DVN Logger is ready to log!", color = 0x00FFFF, footer = { text = "Divine Tools • discord.gg/dvn • Today at " .. timeStr } }} })
end

local function sendFish(data)
    local focusData = FOCUS_FISH[data.Fish]
    if focusData and focusData.Enabled then
        local timeStr = os.date("%I:%M %p")
        send({ 
            username = WEBHOOK_NAME, 
            avatar_url = WEBHOOK_AVATAR, 
            embeds = {{ 
                title = "🚨 TARGET ACQUIRED! 🚨", 
                description = "**👑 CAUGHT: " .. data.Fish .. " 👑**", 
                color = focusData.Color, 
                fields = { 
                    { name = "👤 Player", value = "`"..data.Player.."`", inline = true }, 
                    { name = "⚖️ Weight", value = "`"..data.Weight.."`", inline = true }, 
                    { name = "🎲 Chance", value = "`1 in "..data.Chance.."`", inline = true } 
                }, 
                footer = { text = "Divine Tools • discord.gg/dvn • Today at " .. timeStr } 
            }} 
        })
        return
    end

    local cfg = RARITY_CONFIG[data.Rarity]
    if cfg and cfg.Enabled then
        local timeStr = os.date("%I:%M %p")
        send({ 
            username = WEBHOOK_NAME, 
            avatar_url = WEBHOOK_AVATAR, 
            embeds = {{ 
                title = cfg.Icon.." "..data.Rarity.." Catch!", 
                description = "A rare fish has been caught!", 
                color = cfg.Color, 
                fields = { 
                    { name = "👤 Player", value = "`"..data.Player.."`", inline = true }, 
                    { name = "🐟 Fish", value = "**"..data.Fish.."**", inline = true }, 
                    { name = "⚖️ Weight", value = "`"..data.Weight.."`", inline = true }, 
                    { name = "🎲 Chance", value = "`1 in "..data.Chance.."`", inline = true } 
                }, 
                footer = { text = "Divine Tools • discord.gg/dvn • Today at " .. timeStr } 
            }} 
        })
    end
end

local function sendJoinLeave(player, joined)
    if not SETTINGS.LogJoinLeave then return end
    local timeStr = os.date("%I:%M %p")
    send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {{ title = joined and "👋 Player Joined" or "🚪 Player Left", description = "**"..player.DisplayName.."** (@"..player.Name..")", color = joined and 0x2ECC71 or 0xE74C3C, footer = { text = "Divine Tools • discord.gg/dvn • Today at " .. timeStr } }} })
end

-- LISTENERS
TextChatService.OnIncomingMessage = function(msg)
    if not SETTINGS.LogFish then return end
    if not msg.Text or not msg.Text:find("obtained") then return end
    
    local fishName, weight = detectFishNameAndWeight(msg.Text)
    local rarity = detectRarity(msg.Text)
    
    sendFish({ 
        Player = extractDisplayName(msg.Text), 
        Fish = fishName, 
        Weight = weight, 
        Chance = detectChance(msg.Text), 
        Rarity = rarity 
    })
end

Players.PlayerAdded:Connect(function(player) sendJoinLeave(player, true) end)
Players.PlayerRemoving:Connect(function(player) sendJoinLeave(player, false) end)

-- ====================================================================
-- 2. UI DVN SETUP (GUI CODE)
-- ====================================================================

if GUI_PARENT:FindFirstChild("DVN_LOGGER_UI") then
    GUI_PARENT.DVN_LOGGER_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_LOGGER_UI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false

-- UI CONFIG
local Viewport = Camera.ViewportSize
local StartWidth = math.clamp(Viewport.X * 0.40, 400, 600)
local StartHeight = math.clamp(Viewport.Y * 0.40, 300, 500)
local DEFAULT_SIZE = UDim2.new(0, StartWidth, 0, StartHeight)
local MIN_SIZE = Vector2.new(350, 240)
local MINIMIZED_SIZE = UDim2.new(0, 250, 0, 32)

-- THEME: DARK GLASSY
local THEME = {
    Background = Color3.fromRGB(25, 25, 25),
    Element = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 255, 255), -- Cyan
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Stroke = Color3.fromRGB(255, 255, 255),
    Transparency = 0.2
}

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BackgroundTransparency = THEME.Transparency
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 6); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Color = THEME.Stroke; MainStroke.Transparency = 0.8; MainStroke.Thickness = 1; MainStroke.Parent = MainFrame

-- HEADER
local Header = Instance.new("Frame", MainFrame); Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundTransparency = 1
local Title = Instance.new("TextLabel", Header); Title.Text = "DVN LOGGER"; Title.Size = UDim2.new(0, 200, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.TextColor3 = THEME.Accent; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left
local MinBtn = Instance.new("TextButton", Header); MinBtn.Name = "MinBtn"; MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Position = UDim2.new(1, -40, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.Text = "-"; MinBtn.TextColor3 = THEME.TextDim; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 22
local HeaderLine = Instance.new("Frame", Header); HeaderLine.Size = UDim2.new(1, 0, 0, 1); HeaderLine.Position = UDim2.new(0, 0, 1, -1); HeaderLine.BackgroundColor3 = THEME.Stroke; HeaderLine.BackgroundTransparency = 0.8; HeaderLine.BorderSizePixel = 0

-- BODY
local Body = Instance.new("Frame", MainFrame); Body.Name = "Body"; Body.Size = UDim2.new(1, 0, 1, -40); Body.Position = UDim2.new(0, 0, 0, 40); Body.BackgroundTransparency = 1; Body.ClipsDescendants = true
local Sidebar = Instance.new("Frame", Body); Sidebar.Size = UDim2.new(0.3, 0, 1, 0); Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0, 5); SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0, 15)
local SepLine = Instance.new("Frame", Body); SepLine.Size = UDim2.new(0, 1, 1, 0); SepLine.Position = UDim2.new(0.3, 0, 0, 0); SepLine.BackgroundColor3 = THEME.Stroke; SepLine.BackgroundTransparency = 0.8; SepLine.BorderSizePixel = 0
local Content = Instance.new("Frame", Body); Content.Size = UDim2.new(0.7, 0, 1, 0); Content.Position = UDim2.new(0.3, 0, 0, 0); Content.BackgroundTransparency = 1; Content.ClipsDescendants = true

-- TABS
local Tabs = {"Info", "Dashboard", "Settings"}
local TabFrames = {}
local TabButtons = {}

local function SwitchTab(activeName)
    for name, frame in pairs(TabFrames) do frame.Visible = (name == activeName) end
    for name, btn in pairs(TabButtons) do
        local isActive = (name == activeName)
        TweenService:Create(btn, TweenInfo.new(0.3), {
            TextColor3 = isActive and THEME.Accent or THEME.TextDim,
            BackgroundTransparency = isActive and 0.9 or 1
        }):Play()
    end
end

for i, name in ipairs(Tabs) do
    local Page = Instance.new("ScrollingFrame", Content); Page.Name = name; Page.Size = UDim2.new(1, -20, 1, -20); Page.Position = UDim2.new(0, 10, 0, 10); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = THEME.Accent; Page.AutomaticCanvasSize = Enum.AutomaticSize.Y; Page.CanvasSize = UDim2.new(0,0,0,0)
    local PLayout = Instance.new("UIListLayout", Page); PLayout.Padding = UDim.new(0, 8); PLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local PPad = Instance.new("UIPadding", Page); PPad.PaddingTop = UDim.new(0, 5); PPad.PaddingLeft = UDim.new(0, 5); PPad.PaddingRight = UDim.new(0, 5)
    TabFrames[name] = Page
    
    local Btn = Instance.new("TextButton", Sidebar); Btn.Name = name; Btn.LayoutOrder = i; Btn.Size = UDim2.new(1, -20, 0, 32); Btn.BackgroundColor3 = THEME.Accent; Btn.BackgroundTransparency = 1; Btn.Text = name; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 14; Btn.TextColor3 = THEME.TextDim
    local BCorner = Instance.new("UICorner", Btn); BCorner.CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = Btn
end

-- HELPER FUNCTIONS
local function GetOrder(parent) return #parent:GetChildren() end

function CreateSection(parent, text)
    local Lab = Instance.new("TextLabel", parent); Lab.LayoutOrder = GetOrder(parent); Lab.Text = text:upper(); Lab.Size = UDim2.new(1, 0, 0, 24); Lab.BackgroundTransparency = 1; Lab.TextColor3 = THEME.Accent; Lab.TextTransparency = 0.2; Lab.Font = Enum.Font.GothamBlack; Lab.TextSize = 11; Lab.TextXAlignment = Enum.TextXAlignment.Left
end

function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent); Btn.LayoutOrder = GetOrder(parent); Btn.Size = UDim2.new(1, 0, 0, 36); Btn.BackgroundColor3 = THEME.Element; Btn.BackgroundTransparency = 0.3; Btn.Text = text; Btn.TextColor3 = THEME.Text; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13
    local Corner = Instance.new("UICorner", Btn); Corner.CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = THEME.Stroke; Stroke.Transparency = 0.8; Stroke.Thickness = 1
    
    Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent, TextColor3 = Color3.new(0,0,0)}):Play() end)
    Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Element, TextColor3 = THEME.Text}):Play() end)
    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

function CreateToggle(parent, text, defaultVal, callback)
    local Frame = Instance.new("Frame", parent); Frame.LayoutOrder = GetOrder(parent); Frame.Size = UDim2.new(1, 0, 0, 36); Frame.BackgroundColor3 = THEME.Element; Frame.BackgroundTransparency = 0.3
    local Corner = Instance.new("UICorner", Frame); Corner.CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Frame); Stroke.Color = THEME.Stroke; Stroke.Transparency = 0.8; Stroke.Thickness = 1
    
    local Lab = Instance.new("TextLabel", Frame); Lab.Text = text; Lab.Size = UDim2.new(0.7, 0, 1, 0); Lab.Position = UDim2.new(0, 12, 0, 0); Lab.BackgroundTransparency = 1; Lab.TextColor3 = THEME.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = 13; Lab.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton", Frame); ToggleBtn.Size = UDim2.new(0, 40, 0, 20); ToggleBtn.Position = UDim2.new(1, -50, 0.5, -10); ToggleBtn.BackgroundColor3 = defaultVal and THEME.Accent or Color3.fromRGB(60, 60, 60); ToggleBtn.Text = ""; ToggleBtn.AutoButtonColor = false
    local TCorner = Instance.new("UICorner", ToggleBtn); TCorner.CornerRadius = UDim.new(1, 0)
    
    local Dot = Instance.new("Frame", ToggleBtn); Dot.Size = UDim2.new(0, 16, 0, 16); Dot.Position = defaultVal and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local DCorner = Instance.new("UICorner", Dot); DCorner.CornerRadius = UDim.new(1, 0)
    
    local on = defaultVal
    ToggleBtn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        pcall(callback, on)
    end)
end

function CreateInput(parent, placeholder, defaultText, callback)
    local Frame = Instance.new("Frame", parent); Frame.LayoutOrder = GetOrder(parent); Frame.Size = UDim2.new(1, 0, 0, 38); Frame.BackgroundColor3 = THEME.Element; Frame.BackgroundTransparency = 0.3; Frame.ClipsDescendants = true
    local Corner = Instance.new("UICorner", Frame); Corner.CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Frame); Stroke.Color = THEME.Stroke; Stroke.Transparency = 0.8; Stroke.Thickness = 1
    
    local Box = Instance.new("TextBox", Frame); Box.Size = UDim2.new(1, -24, 1, 0); Box.Position = UDim2.new(0, 12, 0, 0); Box.BackgroundTransparency = 1; Box.Text = defaultText or ""; Box.PlaceholderText = placeholder; Box.TextColor3 = THEME.Text; Box.PlaceholderColor3 = THEME.TextDim; Box.Font = Enum.Font.GothamMedium; Box.TextSize = 13; Box.TextXAlignment = Enum.TextXAlignment.Left; Box.ClearTextOnFocus = false
    Box.FocusLost:Connect(function() pcall(callback, Box.Text) end)
end

-- ====================================================================
-- 3. BUILDING THE UI CONTENT
-- ====================================================================

-- [INFO TAB]
CreateSection(TabFrames["Info"], "DVN LOGGER - Public Release")
local InfoTxt = Instance.new("TextLabel", TabFrames["Info"]); InfoTxt.LayoutOrder = GetOrder(TabFrames["Info"]); InfoTxt.Text = "Official logger by Divine Tools. Join our community for updates."; InfoTxt.Size = UDim2.new(1, 0, 0, 50); InfoTxt.BackgroundTransparency = 1; InfoTxt.TextColor3 = THEME.TextDim; InfoTxt.Font = Enum.Font.GothamMedium; InfoTxt.TextSize = 13; InfoTxt.TextXAlignment = Enum.TextXAlignment.Left; InfoTxt.TextWrapped = true
CreateButton(TabFrames["Info"], "Join Discord (discord.gg/dvn)", function() setclipboard("https://discord.gg/dvn") end)

-- [DASHBOARD TAB]
CreateSection(TabFrames["Dashboard"], "Webhook Configuration")
CreateInput(TabFrames["Dashboard"], "Paste Webhook URL Here...", SETTINGS.WebhookURL, function(text) SETTINGS.WebhookURL = text end)
CreateButton(TabFrames["Dashboard"], "Test Webhook", testWebhook)
CreateSection(TabFrames["Dashboard"], "Logger Controls")
CreateToggle(TabFrames["Dashboard"], "Enable Fish Logger", SETTINGS.LogFish, function(val) SETTINGS.LogFish = val end)
CreateToggle(TabFrames["Dashboard"], "Log Join/Leave", SETTINGS.LogJoinLeave, function(val) SETTINGS.LogJoinLeave = val end)

-- [SETTINGS TAB - FOCUS & RARITY]
CreateSection(TabFrames["Settings"], "Focus Targets")

-- Loop untuk Target Fokus (Sacred & Ruby)
for fishName, config in pairs(FOCUS_FISH) do
    CreateToggle(TabFrames["Settings"], "Track: " .. fishName, config.Enabled, function(val) config.Enabled = val end)
end

CreateSection(TabFrames["Settings"], "Rarity Filter")

-- Loop untuk Rarity (Hanya Epic ke atas)
local RarityOrder = {"Epic", "Legendary", "Mythic", "Secret"}

for _, rarityKey in ipairs(RarityOrder) do
    local config = RARITY_CONFIG[rarityKey]
    local displayName = rarityKey == "Legendary" and "Legend" or rarityKey
    CreateToggle(TabFrames["Settings"], "Log " .. displayName, config.Enabled, function(val) config.Enabled = val end)
end

-- ====================================================================
-- 4. WINDOW LOGIC
-- ====================================================================
local HelperLine = Instance.new("TextButton", ScreenGui); HelperLine.Name = "HelperLine"; HelperLine.Text = ""; HelperLine.BackgroundColor3 = THEME.Accent; HelperLine.BorderSizePixel = 0; HelperLine.BackgroundTransparency = 0.5; HelperLine.AnchorPoint = Vector2.new(0.5, 0); HelperLine.ZIndex = MainFrame.ZIndex - 1; Instance.new("UICorner", HelperLine).CornerRadius = UDim.new(1, 0)

local function UpdateHelperLine()
    if not MainFrame or not MainFrame.Parent then return end
    local mainPos = MainFrame.AbsolutePosition; local mainSize = MainFrame.AbsoluteSize; local centerX = mainPos.X + (mainSize.X / 2); local bottomY = mainPos.Y + mainSize.Y
    HelperLine.Position = UDim2.new(0, centerX, 0, bottomY + 4); HelperLine.Size = UDim2.new(0, mainSize.X * 0.6, 0, 4)
end
MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateHelperLine); MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateHelperLine); UpdateHelperLine()

local dragging, dragStart, startPos
local function StartDrag(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end
Header.InputBegan:Connect(StartDrag); HelperLine.InputBegan:Connect(StartDrag)
UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

local isMin, lastSize = false, DEFAULT_SIZE
MinBtn.MouseButton1Click:Connect(function()
    if isMin then TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = lastSize}):Play(); Body.Visible = true; HelperLine.Visible = true; MinBtn.Text = "-"
    else lastSize = MainFrame.Size; TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = MINIMIZED_SIZE}):Play(); Body.Visible = false; HelperLine.Visible = false; MinBtn.Text = "+" end; isMin = not isMin
end)

SwitchTab("Info")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {Size = DEFAULT_SIZE}):Play()
print("DVN LOGGER UI LOADED")
