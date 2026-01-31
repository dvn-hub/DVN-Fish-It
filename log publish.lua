--[[
    💎 DIVINE LOGGER - PUBLIC EDITION
    Created by Divine Tools
    
    Features:
    - Premium Modern UI (Sidebar Layout)
    - Universal Executor Support (Fluxus/Delta/Hydrogen/etc)
    - Legacy Domain Support (Fixes 429 Errors)
    - Fully Configurable
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local CoreGui = game:GetService("CoreGui")

-- Safe GUI Parent
local GUI_PARENT = LocalPlayer:WaitForChild("PlayerGui")

-- Request Handler
local req = http_request or request or (fluxus and fluxus.request) or (getgenv and getgenv().request) or (syn and syn.request)

-- Theme Colors
local THEME = {
    Background = Color3.fromHex("1a1a1a"),
    Element    = Color3.fromHex("252525"),
    Accent     = Color3.fromHex("3b82f6"),
    Text       = Color3.fromRGB(240, 240, 240),
    TextDim    = Color3.fromRGB(160, 160, 160)
}

-- Configuration
local SETTINGS = {
    WebhookURL = "",
    LogFish = false,
    TrackRuby = false,
    TrackSacred = false,
    Rarities = {
        Epic = false,
        Legendary = false,
        Mythic = false,
        Secret = false
    }
}

local RARITY_DATA = {
    Epic      = { Color = 0xB373F8, Icon = "🟣" },
    Legendary = { Color = 0xFFB92B, Icon = "🟡" },
    Mythic    = { Color = 0xFF1919, Icon = "🔴" },
    Secret    = { Color = 0x18FF98, Icon = "💎" },
}

local RGB_RARITY = {
    ["179,115,248"] = "Epic", ["255,185,43"] = "Legendary", 
    ["255,25,25"] = "Mythic", ["24,255,152"] = "Secret"
}

-- Logic Functions
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

-- Webhook Sender
local function send(payload)
    if SETTINGS.WebhookURL == "" or not req then return end
    
    -- Fix: Use discordapp.com for better compatibility
    local finalURL = SETTINGS.WebhookURL:gsub("discord.com", "discordapp.com")
    
    task.spawn(function()
        pcall(function()
            req({
                Url = finalURL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["User-Agent"] = "Roblox/Linux"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end

local function GetFooter()
    return { text = "Divine Tools • discord.gg/dvn • Today at " .. os.date("%I:%M %p") }
end

local function TestWebhook()
    if SETTINGS.WebhookURL == "" then return end
    send({
        username = "Divine Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png",
        embeds = {{
            title = "💎 DIVINE TOOLS CONNECTED",
            description = "Webhook is working perfectly!",
            color = 0x3b82f6,
            footer = GetFooter(),
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })
end

local function SendFishLog(data)
    -- Priority Check: Special Fish
    local isSpecial = false
    local specialColor = 0xFFFFFF

    if SETTINGS.TrackSacred and data.Fish == "Sacred Guardian Squid" then
        isSpecial = true
        specialColor = 0x00FBFF
    elseif SETTINGS.TrackRuby and (data.Fish:find("Ruby") and data.Fish:find("Gemstone")) then
        isSpecial = true
        specialColor = 0xFF0040
    end

    if isSpecial then
        send({
            username = "Divine Logger",
            avatar_url = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png",
            embeds = {{
                title = "🚨 SPECIAL TARGET CAUGHT!",
                description = "**" .. data.Fish .. "**",
                color = specialColor,
                fields = {
                    { name = "👤 Player", value = data.Player, inline = true },
                    { name = "⚖️ Weight", value = data.Weight, inline = true },
                    { name = "🎲 Chance", value = "1 in " .. data.Chance, inline = true }
                },
                footer = GetFooter(),
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
        return
    end

    -- Normal Rarity Check
    local cfg = RARITY_DATA[data.Rarity]
    if not cfg then return end -- Only log configured rarities
    if not SETTINGS.Rarities[data.Rarity] then return end -- Check if enabled

    send({
        username = "Divine Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png",
        embeds = {{
            title = cfg.Icon .. " " .. data.Rarity .. " Catch!",
            color = cfg.Color,
            fields = {
                { name = "🐟 Fish", value = "**" .. data.Fish .. "**", inline = true },
                { name = "⚖️ Weight", value = data.Weight, inline = true },
                { name = "👤 Player", value = data.Player, inline = true },
                { name = "🎲 Chance", value = "1 in " .. data.Chance, inline = true }
            },
            footer = GetFooter(),
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })
end

-- Listeners
TextChatService.OnIncomingMessage = function(msg)
    if not SETTINGS.LogFish then return end
    if not msg.Text or msg.TextSource then return end -- System messages only
    if not msg.Text:find("obtained") then return end

    local fishName, weight = detectFishNameAndWeight(msg.Text)
    local rarity = detectRarity(msg.Text)
    
    SendFishLog({
        Player = extractDisplayName(msg.Text),
        Fish = fishName,
        Weight = weight,
        Chance = detectChance(msg.Text),
        Rarity = rarity
    })
end

-- UI Construction
if GUI_PARENT:FindFirstChild("DivineLoggerUI") then GUI_PARENT.DivineLoggerUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DivineLoggerUI"
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- UI CONFIG
local DEFAULT_SIZE = UDim2.new(0, 500, 0, 350)
local MINIMIZED_SIZE = UDim2.new(0, 500, 0, 32)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = UDim2.new(0.5, 0, 0.5, -175)
MainFrame.AnchorPoint = Vector2.new(0.5, 0) -- Top Center Pivot for Roll-Up
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true -- CRITICAL: Hides content when minimized
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Text = "DVN LOGGER"
HeaderTitle.Size = UDim2.new(0, 200, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.TextColor3 = THEME.Accent
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextSize = 16
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 32, 1, 0)
MinBtn.Position = UDim2.new(1, -32, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = THEME.TextDim
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = THEME.Accent
HeaderLine.BackgroundTransparency = 0.8
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

-- BODY
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, 0, 1, -32)
Body.Position = UDim2.new(0, 0, 0, 32)
Body.BackgroundTransparency = 1
Body.ClipsDescendants = true
Body.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = THEME.Element
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 2)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -130, 1, 0)
Content.Position = UDim2.new(0, 130, 0, 0)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Body

-- TABS SYSTEM
local TabFrames = {}
local TabButtons = {}

local function SwitchTab(activeName)
    for name, frame in pairs(TabFrames) do
        frame.Visible = (name == activeName)
    end
    for name, btn in pairs(TabButtons) do
        if name == activeName then
            btn.TextColor3 = THEME.Text
            btn.BackgroundTransparency = 0.9
        else
            btn.TextColor3 = THEME.TextDim
            btn.BackgroundTransparency = 1
        end
    end
end

local function CreateTab(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = THEME.Accent
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
    Btn.Size = UDim2.new(1, -16, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextColor3 = THEME.TextDim
    Btn.Parent = Sidebar
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = Btn
    
    return Page
end

-- HELPER FUNCTIONS
local function GetOrder(parent) return #parent:GetChildren() end

local function CreateSection(parent, text)
    local Lab = Instance.new("TextLabel")
    Lab.LayoutOrder = GetOrder(parent)
    Lab.Text = text:upper()
    Lab.Size = UDim2.new(1, 0, 0, 24)
    Lab.BackgroundTransparency = 1
    Lab.TextColor3 = THEME.Accent
    Lab.TextTransparency = 0.2
    Lab.Font = Enum.Font.GothamBold
    Lab.TextSize = 12
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.Parent = parent
end

local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.LayoutOrder = GetOrder(parent)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = THEME.Element
    Btn.Text = text
    Btn.TextColor3 = THEME.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function CreateToggle(parent, text, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.LayoutOrder = GetOrder(parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = THEME.Element
    Frame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Lab.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = THEME.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -40, 0.5, -10)
    Btn.BackgroundColor3 = defaultVal and THEME.Accent or Color3.fromRGB(50, 50, 50)
    Btn.Text = ""
    Btn.Parent = Frame
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = Btn
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.Parent = Btn
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(1, 0)
    DCorner.Parent = Dot
    
    local on = defaultVal
    Btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        end
        pcall(callback, on)
    end)
end

local function CreateInput(parent, placeholder, defaultText, callback)
    local Frame = Instance.new("Frame")
    Frame.LayoutOrder = GetOrder(parent)
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = THEME.Element
    Frame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.BackgroundTransparency = 1
    Box.Text = defaultText or ""
    Box.PlaceholderText = placeholder
    Box.TextColor3 = THEME.Text
    Box.PlaceholderColor3 = THEME.TextDim
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 14
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    Box.Parent = Frame
    
    Box.FocusLost:Connect(function() pcall(callback, Box.Text) end)
end

-- BUILD TABS
local InfoPage = CreateTab("Info")
local LoggerPage = CreateTab("Logger")

-- [INFO TAB]
local WelcomeHeader = Instance.new("TextLabel")
WelcomeHeader.LayoutOrder = GetOrder(InfoPage)
WelcomeHeader.Text = "Welcome to Divine Tools"
WelcomeHeader.Size = UDim2.new(1, 0, 0, 30)
WelcomeHeader.BackgroundTransparency = 1
WelcomeHeader.TextColor3 = THEME.Text
WelcomeHeader.Font = Enum.Font.GothamBold
WelcomeHeader.TextSize = 20
WelcomeHeader.TextXAlignment = Enum.TextXAlignment.Left
WelcomeHeader.Parent = InfoPage

local DescText = Instance.new("TextLabel")
DescText.LayoutOrder = GetOrder(InfoPage)
DescText.Text = "Empower your fishing journey with the ultimate utility tool. Tracking your rarest catches has never been easier."
DescText.Size = UDim2.new(1, 0, 0, 60)
DescText.BackgroundTransparency = 1
DescText.TextColor3 = THEME.TextDim
DescText.Font = Enum.Font.Gotham
DescText.TextSize = 14
DescText.TextXAlignment = Enum.TextXAlignment.Left
DescText.TextWrapped = true
DescText.Parent = InfoPage

CreateButton(InfoPage, "Join Divine Discord", Color3.fromRGB(88, 101, 242), function()
    setclipboard("https://discord.gg/dvn")
end)

-- === POPULATE LOGGER PAGE ===
local WebhookBox = CreateInput(LoggerPage, "Paste Webhook URL Here...")
WebhookBox.FocusLost:Connect(function()
    SETTINGS.WebhookURL = WebhookBox.Text
end)

CreateButton(LoggerPage, "Test Webhook", THEME.Element, TestWebhook)

CreateToggle(LoggerPage, "Enable Fish Logger", function(v) SETTINGS.LogFish = v end)
CreateToggle(LoggerPage, "Track Ruby Gemstone", function(v) SETTINGS.TrackRuby = v end)
CreateToggle(LoggerPage, "Track Sacred Guardian Squid", function(v) SETTINGS.TrackSacred = v end)

-- Rarity Section
local RarityLabel = Instance.new("TextLabel")
RarityLabel.Text = "RARITY FILTER"
RarityLabel.Size = UDim2.new(1, 0, 0, 20)
RarityLabel.BackgroundTransparency = 1
RarityLabel.TextColor3 = THEME.TextDim
RarityLabel.Font = Enum.Font.GothamBold
RarityLabel.TextSize = 12
RarityLabel.TextXAlignment = Enum.TextXAlignment.Left
RarityLabel.Parent = LoggerPage

local RarityContainer = Instance.new("Frame")
RarityContainer.Size = UDim2.new(1, 0, 0, 30)
RarityContainer.BackgroundTransparency = 1
RarityContainer.Parent = LoggerPage

local RLayout = Instance.new("UIListLayout")
RLayout.FillDirection = Enum.FillDirection.Horizontal
RLayout.Padding = UDim.new(0, 5)
RLayout.Parent = RarityContainer

local function CreateRarityCheck(name, color)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.23, 0, 1, 0)
    Btn.BackgroundColor3 = THEME.Element
    Btn.Text = name
    Btn.TextColor3 = THEME.TextDim
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = RarityContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(color)
    Instance.new("UIStroke", Btn).Transparency = 0.8
    
    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        SETTINGS.Rarities[name] = on
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(color) or THEME.Element, TextColor3 = on and Color3.black or THEME.TextDim}):Play()
    end)
end

CreateRarityCheck("Epic", 0xB373F8)
CreateRarityCheck("Legendary", 0xFFB92B)
CreateRarityCheck("Mythic", 0xFF1919)
CreateRarityCheck("Secret", 0x18FF98)

-- Create Sidebar Buttons
local InfoBtn = CreateTabBtn("Info", "🏠", InfoPage)
local LoggerBtn = CreateTabBtn("Logger", "⚙️", LoggerPage)

-- Set Default Tab (Info)
InfoBtn.BackgroundTransparency = 0.9
InfoBtn.BackgroundColor3 = THEME.Accent
InfoBtn.TextColor3 = Color3.white

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

print("💎 DIVINE LOGGER UI LOADED")