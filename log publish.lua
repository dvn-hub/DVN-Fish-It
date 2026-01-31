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
local GUI_PARENT = (typeof(gethui) == "function" and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

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

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1 -- Glassy Look
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = THEME.Accent
UIStroke.Transparency = 0.6
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Text = "DVN LOGGER"
HeaderTitle.Size = UDim2.new(1, -100, 1, 0)
HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.TextColor3 = THEME.Accent
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextSize = 16
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = THEME.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Separator
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, 0, 0, 1)
Separator.Position = UDim2.new(0, 0, 0, 40)
Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Separator.BackgroundTransparency = 0.9
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -41)
Sidebar.Position = UDim2.new(0, 0, 0, 41)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local SidebarBorder = Instance.new("Frame")
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
SidebarBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SidebarBorder.BackgroundTransparency = 0.9
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

-- PageContainer
local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -140, 1, -41)
PageContainer.Position = UDim2.new(0, 140, 0, 41)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

-- Pages
local InfoPage = Instance.new("Frame")
InfoPage.Name = "InfoPage"
InfoPage.Size = UDim2.new(1, -30, 1, -30)
InfoPage.Position = UDim2.new(0, 15, 0, 15)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = true
InfoPage.Parent = PageContainer

local InfoLayout = Instance.new("UIListLayout")
InfoLayout.Padding = UDim.new(0, 10)
InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
InfoLayout.Parent = InfoPage

local LoggerPage = Instance.new("Frame")
LoggerPage.Name = "LoggerPage"
LoggerPage.Size = UDim2.new(1, -30, 1, -30)
LoggerPage.Position = UDim2.new(0, 15, 0, 15)
LoggerPage.BackgroundTransparency = 1
LoggerPage.Visible = false
LoggerPage.Parent = PageContainer

local LoggerLayout = Instance.new("UIListLayout")
LoggerLayout.Padding = UDim.new(0, 10)
LoggerLayout.SortOrder = Enum.SortOrder.LayoutOrder
LoggerLayout.Parent = LoggerPage

-- Helper Functions for UI Elements
local function CreateTabBtn(name, icon, targetPage)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Btn"
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.BackgroundTransparency = 1
    Btn.Text = "   " .. icon .. "  " .. name
    Btn.TextColor3 = THEME.TextDim
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Sidebar
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        -- Reset all buttons
        for _, child in pairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = THEME.TextDim}):Play()
            end
        end
        -- Highlight this button
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, BackgroundColor3 = THEME.Accent, TextColor3 = Color3.white}):Play()
        
        -- Switch Page
        InfoPage.Visible = false
        LoggerPage.Visible = false
        targetPage.Visible = true
    end)
    
    return Btn
end

-- Helper for UI Elements
local function CreateInput(parent, placeholder)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = THEME.Element
    Container.BackgroundTransparency = 0.5
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(60, 60, 60)
    Stroke.Thickness = 1
    Stroke.Parent = Container
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.BackgroundTransparency = 1
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = THEME.Text
    Box.PlaceholderColor3 = THEME.TextDim
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.Parent = Container
    return Box
end

local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = color
    Btn.BackgroundTransparency = 0.2
    Btn.Text = text
    Btn.TextColor3 = Color3.white
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = THEME.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -40, 0.5, -10)
    Btn.BackgroundColor3 = THEME.Element
    Btn.BackgroundTransparency = 0.5
    Btn.Text = ""
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 2, 0.5, -8)
    Dot.BackgroundColor3 = THEME.TextDim
    Dot.Parent = Btn
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    
    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        callback(on)
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = on and THEME.Accent or THEME.Element}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = on and Color3.white or THEME.TextDim}):Play()
    end)
end

-- === POPULATE INFO PAGE ===
local WelcomeHeader = Instance.new("TextLabel")
WelcomeHeader.Text = "Welcome to Divine Tools"
WelcomeHeader.Size = UDim2.new(1, 0, 0, 30)
WelcomeHeader.BackgroundTransparency = 1
WelcomeHeader.TextColor3 = THEME.Text
WelcomeHeader.Font = Enum.Font.GothamBold
WelcomeHeader.TextSize = 20
WelcomeHeader.TextXAlignment = Enum.TextXAlignment.Left
WelcomeHeader.Parent = InfoPage

local DescText = Instance.new("TextLabel")
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
    Btn.BackgroundTransparency = 0.5
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
MainFrame.InputBegan:Connect(function(input)
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