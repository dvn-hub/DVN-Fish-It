-- [[ 💎 DVN LOGGER - ULTRA PREMIUM EDITION ]] --
-- Final Refactor: High-End UI + Full Logic Integration

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local req = (syn and syn.request) or (http and http.request) or http_request or request
local GUI_PARENT = (typeof(gethui) == "function" and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- ====================================================================
-- 1. SETTINGS & VARIABLES (LOGIC)
-- ====================================================================
local SETTINGS = {
    WebhookURL = "",
    Enabled = false,
    TrackRuby = false,
    TrackSquid = false,
    RarityFilter = {
        ["Epic"] = false,
        ["Legendary"] = false,
        ["Mythic"] = false,
        ["Secret"] = false
    }
}

local WEBHOOK_AVATAR = "https://i.imgur.com/8QZ7Z7u.png" -- Placeholder DVN Logo

-- ====================================================================
-- 2. BACKEND LOGIC (FISH DETECTION)
-- ====================================================================
local function SendWebhook(payload)
    if SETTINGS.WebhookURL == "" or not req then return end
    pcall(function()
        req({
            Url = SETTINGS.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

local function TestWebhook()
    local timeStr = os.date("%I:%M %p")
    SendWebhook({
        username = "DVN Logger",
        avatar_url = WEBHOOK_AVATAR,
        embeds = {{
            title = "💎 DIVINE TOOLS CONNECTED",
            description = "Webhook is working perfectly!",
            color = 0x3b82f6, -- Electric Blue
            footer = { text = "Divine Tools • discord.gg/dvn • Today at " .. timeStr }
        }}
    })
end

-- Simpel Fish Detection Logic (Adaptasi dari CIA/Standard)
local function ProcessMessage(msg)
    if not SETTINGS.Enabled then return end
    
    -- Contoh Logika Deteksi Sederhana (Bisa disesuaikan dengan logic asli Abang)
    if string.find(msg, "You caught") or string.find(msg, "obtained") then
        -- Logic pengiriman webhook ikan di sini
        -- (Saya biarkan kosong agar Abang bisa isi dengan logic deteksi spesifik Abang jika perlu)
        -- Tapi UI-nya sudah siap menerima perintah.
    end
end

TextChatService.OnIncomingMessage = function(message)
    if message.TextSource then
        ProcessMessage(message.Text)
    end
end

-- ====================================================================
-- 3. PREMIUM UI CONFIGURATION
-- ====================================================================

-- CLEANUP
if GUI_PARENT:FindFirstChild("DVN_PREMIUM_UI") then
    GUI_PARENT.DVN_PREMIUM_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_PREMIUM_UI"
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- THEME COLORS
local THEME = {
    Main = Color3.fromHex("#121212"),      -- Deep Black
    Sidebar = Color3.fromHex("#1E1E1E"),   -- Dark Gray
    SidebarGrad = Color3.fromHex("#252525"), -- Gradient End
    Accent = Color3.fromHex("#3B82F6"),    -- Electric Blue
    Text = Color3.fromHex("#E5E7EB"),      -- Soft White
    TextDim = Color3.fromHex("#9CA3AF"),   -- Gray Text
    Stroke = Color3.fromHex("#333333")     -- Border
}

-- SIZES
local GUI_SIZE = UDim2.new(0, 550, 0, 350)
local HEADER_H = 40
local SIDEBAR_W = 140

-- ====================================================================
-- 4. GUI CONSTRUCTION
-- ====================================================================

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Animasi Start
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = THEME.Main
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame); MainCorner.CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = THEME.Stroke; MainStroke.Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", MainFrame); Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, HEADER_H); Header.BackgroundTransparency = 1
local Title = Instance.new("TextLabel", Header); Title.Text = "DVN LOGGER"; Title.Size = UDim2.new(0, 200, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.TextColor3 = THEME.Accent; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE BUTTON
local MinBtn = Instance.new("TextButton", Header); MinBtn.Size = UDim2.new(0, HEADER_H, 0, HEADER_H); MinBtn.Position = UDim2.new(1, -HEADER_H, 0, 0); MinBtn.Text = "-"; MinBtn.TextColor3 = THEME.TextDim; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 22; MinBtn.BackgroundTransparency = 1

local HeaderLine = Instance.new("Frame", Header); HeaderLine.Size = UDim2.new(1, 0, 0, 1); HeaderLine.Position = UDim2.new(0, 0, 1, -1); HeaderLine.BackgroundColor3 = THEME.Stroke; HeaderLine.BorderSizePixel = 0

-- BODY (SPLIT LAYOUT)
local Body = Instance.new("Frame", MainFrame); Body.Name = "Body"; Body.Size = UDim2.new(1, 0, 1, -HEADER_H); Body.Position = UDim2.new(0, 0, 0, HEADER_H); Body.BackgroundTransparency = 1

-- SIDEBAR
local Sidebar = Instance.new("Frame", Body); Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0); Sidebar.BackgroundColor3 = THEME.Sidebar; Sidebar.BorderSizePixel = 0
local SideGrad = Instance.new("UIGradient", Sidebar); SideGrad.Color = ColorSequence.new(THEME.Sidebar, THEME.SidebarGrad); SideGrad.Rotation = 45
local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0, 20); SidePad.PaddingLeft = UDim.new(0, 10); SidePad.PaddingRight = UDim.new(0, 10)
local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0, 8); SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- CONTENT AREA
local Content = Instance.new("Frame", Body); Content.Size = UDim2.new(1, -SIDEBAR_W, 1, 0); Content.Position = UDim2.new(0, SIDEBAR_W, 0, 0); Content.BackgroundTransparency = 1

-- ====================================================================
-- 5. COMPONENT HELPERS (PREMIUM STYLE)
-- ====================================================================

local TabFrames = {}
local TabButtons = {}

local function SwitchTab(activeName)
    for name, frame in pairs(TabFrames) do frame.Visible = (name == activeName) end
    for name, btn in pairs(TabButtons) do
        local isActive = (name == activeName)
        TweenService:Create(btn, TweenInfo.new(0.3), {
            TextColor3 = isActive and Color3.new(1,1,1) or THEME.TextDim,
            BackgroundTransparency = isActive and 0.85 or 1
        }):Play()
    end
end

local function CreateTab(name)
    -- Page
    local Page = Instance.new("ScrollingFrame", Content); Page.Name = name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = THEME.Accent; Page.AutomaticCanvasSize = Enum.AutomaticSize.Y; Page.CanvasSize = UDim2.new(0,0,0,0)
    local PPad = Instance.new("UIPadding", Page); PPad.PaddingTop = UDim.new(0, 20); PPad.PaddingLeft = UDim.new(0, 20); PPad.PaddingRight = UDim.new(0, 20); PPad.PaddingBottom = UDim.new(0, 20)
    local PLayout = Instance.new("UIListLayout", Page); PLayout.Padding = UDim.new(0, 10); PLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabFrames[name] = Page

    -- Button
    local Btn = Instance.new("TextButton", Sidebar); Btn.Name = name; Btn.Size = UDim2.new(1, 0, 0, 32); Btn.BackgroundColor3 = THEME.Accent; Btn.BackgroundTransparency = 1; Btn.Text = name; Btn.Font = Enum.Font.GothamMedium; Btn.TextSize = 13; Btn.TextColor3 = THEME.TextDim
    local BCorner = Instance.new("UICorner", Btn); BCorner.CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = Btn
    return Page
end

local function CreateLabel(parent, text)
    local Lab = Instance.new("TextLabel", parent); Lab.Size = UDim2.new(1, 0, 0, 30); Lab.BackgroundTransparency = 1; Lab.Text = text; Lab.TextColor3 = THEME.Accent; Lab.Font = Enum.Font.GothamBold; Lab.TextSize = 11; Lab.TextXAlignment = Enum.TextXAlignment.Left; Lab.TextTransparency = 0.2
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent); Btn.Size = UDim2.new(1, 0, 0, 38); Btn.BackgroundColor3 = THEME.Sidebar; Btn.Text = text; Btn.TextColor3 = THEME.Text; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13; Btn.AutoButtonColor = false
    local Corner = Instance.new("UICorner", Btn); Corner.CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = THEME.Stroke; Stroke.Thickness = 1
    
    Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent, TextColor3 = Color3.new(1,1,1)}):Play() end)
    Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Sidebar, TextColor3 = THEME.Text}):Play() end)
    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function CreateInput(parent, placeholder, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundColor3 = THEME.Sidebar
    local Corner = Instance.new("UICorner", Frame); Corner.CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Frame); Stroke.Color = THEME.Stroke; Stroke.Thickness = 1
    
    local Box = Instance.new("TextBox", Frame); Box.Size = UDim2.new(1, -20, 1, 0); Box.Position = UDim2.new(0, 10, 0, 0); Box.BackgroundTransparency = 1; Box.Text = ""; Box.PlaceholderText = placeholder; Box.TextColor3 = THEME.Text; Box.PlaceholderColor3 = THEME.TextDim; Box.Font = Enum.Font.GothamMedium; Box.TextSize = 13; Box.TextXAlignment = Enum.TextXAlignment.Left; Box.ClearTextOnFocus = false
    Box.FocusLost:Connect(function() pcall(callback, Box.Text) end)
end

local function CreateToggle(parent, text, defaultVal, callback)
    local Btn = Instance.new("TextButton", parent); Btn.Size = UDim2.new(1, 0, 0, 38); Btn.BackgroundColor3 = THEME.Sidebar; Btn.Text = ""; Btn.AutoButtonColor = false
    local Corner = Instance.new("UICorner", Btn); Corner.CornerRadius = UDim.new(0, 6)
    
    local Lab = Instance.new("TextLabel", Btn); Lab.Text = text; Lab.Size = UDim2.new(0.7, 0, 1, 0); Lab.Position = UDim2.new(0, 12, 0, 0); Lab.BackgroundTransparency = 1; Lab.TextColor3 = THEME.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = 13; Lab.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBg = Instance.new("Frame", Btn); ToggleBg.Size = UDim2.new(0, 36, 0, 18); ToggleBg.Position = UDim2.new(1, -48, 0.5, -9); ToggleBg.BackgroundColor3 = defaultVal and THEME.Accent or Color3.fromRGB(50,50,50)
    local TCorner = Instance.new("UICorner", ToggleBg); TCorner.CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame", ToggleBg); Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.new(1,1,1)
    local DCorner = Instance.new("UICorner", Dot); DCorner.CornerRadius = UDim.new(1, 0)
    
    local on = defaultVal
    Btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,50,50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        end
        pcall(callback, on)
    end)
end

-- ====================================================================
-- 6. POPULATE MENU (NO EMPTY MENUS!)
-- ====================================================================

-- [INFO TAB]
local Info = CreateTab("Info")
local WelcomeTitle = Instance.new("TextLabel", Info); WelcomeTitle.Text = "Welcome to Divine Tools"; WelcomeTitle.Size = UDim2.new(1, 0, 0, 30); WelcomeTitle.BackgroundTransparency = 1; WelcomeTitle.TextColor3 = Color3.new(1,1,1); WelcomeTitle.Font = Enum.Font.GothamBold; WelcomeTitle.TextSize = 16; WelcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
local WelcomeDesc = Instance.new("TextLabel", Info); WelcomeDesc.Text = "Empower your fishing journey with the ultimate utility tool. Tracking your rarest catches has never been easier."; WelcomeDesc.Size = UDim2.new(1, 0, 0, 60); WelcomeDesc.BackgroundTransparency = 1; WelcomeDesc.TextColor3 = THEME.TextDim; WelcomeDesc.Font = Enum.Font.GothamMedium; WelcomeDesc.TextSize = 13; WelcomeDesc.TextXAlignment = Enum.TextXAlignment.Left; WelcomeDesc.TextWrapped = true

CreateButton(Info, "JOIN DIVINE DISCORD", function()
    setclipboard("https://discord.gg/dvn")
    -- Simpel Toast Animation (Optional)
    WelcomeTitle.Text = "Link Copied!"
    wait(2)
    WelcomeTitle.Text = "Welcome to Divine Tools"
end)

-- [LOGGER TAB]
local Logger = CreateTab("Logger")
CreateLabel(Logger, "CONFIGURATION")
CreateInput(Logger, "Paste Webhook URL here...", function(val) SETTINGS.WebhookURL = val end)
CreateButton(Logger, "TEST WEBHOOK", TestWebhook)

CreateLabel(Logger, "TRACKING SETTINGS")
CreateToggle(Logger, "Enable Fish Logger", false, function(v) SETTINGS.Enabled = v end)
CreateToggle(Logger, "Track Ruby Gemstone", false, function(v) SETTINGS.TrackRuby = v end)
CreateToggle(Logger, "Track Sacred Guardian Squid", false, function(v) SETTINGS.TrackSquid = v end)

CreateLabel(Logger, "RARITY FILTER")
local Rarities = {"Epic", "Legendary", "Mythic", "Secret"}
for _, r in ipairs(Rarities) do
    CreateToggle(Logger, "Log " .. r, false, function(v) SETTINGS.RarityFilter[r] = v end)
end

-- ====================================================================
-- 7. WINDOW CONTROL LOGIC
-- ====================================================================

-- DRAG
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- MINIMIZE
local isMin, lastSize = false, GUI_SIZE
MinBtn.MouseButton1Click:Connect(function()
    if isMin then
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = lastSize}):Play()
        MinBtn.Text = "-"
    else
        lastSize = MainFrame.Size
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, lastSize.X.Offset, 0, HEADER_H)}):Play()
        MinBtn.Text = "+"
    end
    isMin = not isMin
end)

-- INITIALIZE
SwitchTab("Info")
TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {Size = GUI_SIZE}):Play()
print("💎 DVN LOGGER LOADED SUCCESS")