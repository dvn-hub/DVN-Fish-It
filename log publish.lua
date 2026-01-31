--[[
    💎 DIVINE LOGGER - PUBLIC EDITION
    Created by Divine Tools
    
    Features:
    - Premium Glassy UI (Black Elegant)
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

-- Configuration
local SETTINGS = {
    WebhookURL = "",
    LogFish = false,
    LogJoinLeave = false,
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

local function TestWebhook()
    if SETTINGS.WebhookURL == "" then return end
    send({
        username = "Divine Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png",
        embeds = {{
            title = "💎 DIVINE TOOLS CONNECTED",
            description = "Webhook is working perfectly!",
            color = 0xFFFFFF,
            footer = { text = "Divine Tools • Public Edition" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })
end

local function SendFishLog(data)
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
            footer = { text = "Divine Tools • Fish Logger" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })
end

local function SendJoinLeave(player, joined)
    if not SETTINGS.LogJoinLeave then return end
    send({
        username = "Divine Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png",
        embeds = {{
            title = joined and "👋 Player Joined" or "🚪 Player Left",
            description = "**" .. player.DisplayName .. "** (@" .. player.Name .. ")",
            color = joined and 0x2ECC71 or 0xE74C3C,
            footer = { text = "Divine Tools • Server Activity" },
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

Players.PlayerAdded:Connect(function(p) SendJoinLeave(p, true) end)
Players.PlayerRemoving:Connect(function(p) SendJoinLeave(p, false) end)

-- UI Construction
if GUI_PARENT:FindFirstChild("DivineLoggerUI") then GUI_PARENT.DivineLoggerUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DivineLoggerUI"
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.9
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "DIVINE LOGGER"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.TextSize = 24
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -30, 1, -50)
Content.Position = UDim2.new(0, 15, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Content

-- Helper for UI Elements
local function CreateInput(placeholder)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Container.Parent = Content
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Container).Color = Color3.fromRGB(40, 40, 45)
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.BackgroundTransparency = 1
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.Parent = Container
    return Box
end

local function CreateButton(text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = Content
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function CreateToggle(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Content
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -40, 0.5, -10)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Btn.Text = ""
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 2, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Dot.Parent = Btn
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    
    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        callback(on)
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 45)}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)}):Play()
    end)
end

-- Build UI Elements
local WebhookBox = CreateInput("Paste Webhook URL Here...")
WebhookBox.FocusLost:Connect(function()
    SETTINGS.WebhookURL = WebhookBox.Text
end)

CreateButton("TEST WEBHOOK", Color3.fromRGB(40, 40, 50), TestWebhook)

CreateToggle("Enable Fish Logger", function(v) SETTINGS.LogFish = v end)
CreateToggle("Enable Join/Leave Logs", function(v) SETTINGS.LogJoinLeave = v end)

-- Rarity Section
local RarityLabel = Instance.new("TextLabel")
RarityLabel.Text = "RARITY FILTER"
RarityLabel.Size = UDim2.new(1, 0, 0, 20)
RarityLabel.BackgroundTransparency = 1
RarityLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
RarityLabel.Font = Enum.Font.GothamBold
RarityLabel.TextSize = 12
RarityLabel.TextXAlignment = Enum.TextXAlignment.Left
RarityLabel.Parent = Content

local RarityContainer = Instance.new("Frame")
RarityContainer.Size = UDim2.new(1, 0, 0, 30)
RarityContainer.BackgroundTransparency = 1
RarityContainer.Parent = Content

local RLayout = Instance.new("UIListLayout")
RLayout.FillDirection = Enum.FillDirection.Horizontal
RLayout.Padding = UDim.new(0, 5)
RLayout.Parent = RarityContainer

local function CreateRarityCheck(name, color)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.23, 0, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
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
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(color) or Color3.fromRGB(30, 30, 35), TextColor3 = on and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(150, 150, 150)}):Play()
    end)
end

CreateRarityCheck("Epic", 0xB373F8)
CreateRarityCheck("Legendary", 0xFFB92B)
CreateRarityCheck("Mythic", 0xFF1919)
CreateRarityCheck("Secret", 0x18FF98)

-- Discord Button
local DiscordBtn = CreateButton("JOIN DIVINE DISCORD", Color3.fromRGB(88, 101, 242), function()
    setclipboard("https://discord.gg/dvn")
    local notif = Instance.new("TextLabel")
    notif.Text = "COPIED TO CLIPBOARD!"
    notif.Size = UDim2.new(1, 0, 1, 0)
    notif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    notif.TextColor3 = Color3.white
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 14
    notif.Parent = DiscordBtn
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    task.wait(1)
    notif:Destroy()
end)

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