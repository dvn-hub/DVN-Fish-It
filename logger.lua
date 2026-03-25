--[[ 
    💎 DVN LOGGER v9.2 — SPECIAL TARGET EDITION
    Features:
    - FOCUS: Added "Sacred Guardian Squid" & "GEMSTONE Ruby" detection by NAME.
    - CLEAN: Removed Common, Uncommon, Rare filters.
    - DEFAULT: All toggles start OFF (Silent Start).
    - UI: Integrated Focus Menu into Settings.
]]

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local WEBHOOK_NAME = "Babu DVN"
local WEBHOOK_AVATAR = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png?ex=69724f7b&is=6970fdfb&hm=a5c01f6fd791c0c8e58ca6732eba77b1a21256f63329654d99d4b24498e9bc6d&"

-- [UPDATE] Removed Common/Uncommon/Rare. All Default OFF.
local RARITY_CONFIG = {
    Epic      = { Enabled = false, Color = 0xB373F8, Icon = "🟣" },
    Legendary = { Enabled = false, Color = 0xFFB92B, Icon = "🟡" },
    Mythic    = { Enabled = false, Color = 0xFF1919, Icon = "🔴" },
    Secret    = { Enabled = false, Color = 0x18FF98, Icon = "💎" },
    Forgotten = { Enabled = true,  Color = 0x808080, Icon = "⬜" },
}

-- [NEW] FOCUS FISH CONFIG (Default OFF)
local FOCUS_FISH = {
    ["Sacred Guardian Squid"] = { Enabled = false, Color = 0x00FBFF }, -- Cyan
    ["GEMSTONE Ruby"]         = { Enabled = false, Color = 0xFF0040 }, -- Ruby Red
    ["GEMSTONE Shiny Ruby"]   = { Enabled = false, Color = 0xFF0040 }, -- Ruby Red
    ["GEMSTONE Big Ruby"]     = { Enabled = false, Color = 0xFF0040 }  -- Ruby Red
}

local RGB_RARITY = {
    ["179,115,248"] = "Epic", ["255,185,43"] = "Legendary",
    ["255,25,25"] = "Mythic", ["24,255,152"] = "Secret",
    ["255,255,255"] = "Forgotten"
}

-- [NEW] FISH IMAGE DATA
local fishImages = {}
local fishImagesTokens = {}
local thumbnailCache = {}

-- UTIL FUNCTIONS
local function normalize(str)
    if type(str) ~= "string" then return "" end
    return str:lower():gsub("%W", "")
end

local function tokenKey(str)
    if type(str) ~= "string" then return "" end
    local tokens = {}
    for token in str:lower():gmatch("%w+") do
        table.insert(tokens, token)
    end
    table.sort(tokens)
    return table.concat(tokens, "")
end

local function lowerString(value)
    if value == nil then return "" end
    local t = type(value)
    if t == "string" then return value:lower() end
    if t == "table" then
        if type(value.Name) == "string" then return value.Name:lower() end
        if type(value.Type) == "string" then return value.Type:lower() end
    end
    return tostring(value):lower()
end

local function resolveIcon(iconValue)
    if typeof and typeof(iconValue) == "Instance" then
        if iconValue:IsA("Decal") then return iconValue.Texture end
        if iconValue:IsA("ImageLabel") or iconValue:IsA("ImageButton") then
            return iconValue.Image
        end
    end
    return iconValue
end

local function isFishData(data, moduleRef)
    if not data then return false end
    local typeStr = lowerString(data.Type or data.Category or data.ItemType)
    if typeStr:find("fish") then return true end
    if data.IsFish == true or data.Fish == true then return true end
    if data.Rarity or data.Weight or data.CatchChance or data.Chance then return true end
    if moduleRef and type(moduleRef.Name) == "string" and moduleRef.Name:lower():find("fish") then
        return true
    end
    return false
end

local function addFishImage(name, icon)
    if type(name) ~= "string" or name == "" or icon == nil then return end
    fishImages[normalize(name)] = icon
    fishImagesTokens[tokenKey(name)] = icon

    local before, inside = name:match("^(.-)%s*%((.-)%)%s*$")
    if before and inside then
        local swapped = inside .. " " .. before
        fishImages[normalize(swapped)] = icon
        fishImagesTokens[tokenKey(swapped)] = icon
        fishImages[normalize(before)] = icon
        fishImagesTokens[tokenKey(before)] = icon
    end
end

local function fetchThumbnailUrl(assetId)
    local id = tostring(assetId or ""):match("%d+")
    if not id then return nil end
    if thumbnailCache[id] ~= nil then
        return thumbnailCache[id] or nil
    end
    if not req then
        thumbnailCache[id] = false
        return nil
    end

    local ok, res = pcall(function()
        return req({
            Url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. id .. "&size=420x420&format=Png&isCircular=false",
            Method = "GET",
            Headers = { ["User-Agent"] = "Roblox/1.0.0" }
        })
    end)

    local bodyText = ok and res and (res.Body or res.body) or nil
    if bodyText then
        local decodeOk, decoded = pcall(function()
            return HttpService:JSONDecode(bodyText)
        end)
        local url = decodeOk and decoded and decoded.data and decoded.data[1] and decoded.data[1].imageUrl or nil
        if url and url ~= "" then
            thumbnailCache[id] = url
            return url
        end
    end

    thumbnailCache[id] = false
    return nil
end

local function toURL(assetId)
    if not assetId then return nil end
    local asString = tostring(assetId)
    if asString:match("^https?://") then return asString end
    local thumbUrl = fetchThumbnailUrl(asString)
    if thumbUrl then return thumbUrl end
    local id = asString:match("%d+") -- Ambil angkanya saja, format apapun bisa
    if not id then return nil end
    return "https://www.roblox.com/asset-thumbnail/image?assetId=" .. id .. "&width=420&height=420&format=png"
end

local function stripVariants(name)
    -- Remove Shiny/Big/Shiny Big/Big Shiny prefixes for image lookup
    local stripped = name
        :gsub("^[Ss]hiny%s+[Bb]ig%s+", "")
        :gsub("^[Bb]ig%s+[Ss]hiny%s+", "")
        :gsub("^[Ss]hiny%s+", "")
        :gsub("^[Bb]ig%s+", "")
        :gsub("^[A-Z][A-Z]+%s+", "") -- Strip ALL-CAPS mutation prefix (e.g. GHOST, ZOMBIE)
        :gsub("^[A-Z][A-Z]+%s+", "") -- Strip second mutation prefix if stacked
    return stripped
end

local function getFishImage(fishName)
    if not fishName or next(fishImages) == nil then return nil end
    local baseName = stripVariants(fishName)
    local normalizedName = normalize(baseName)
    -- Also keep original normalized for fallback
    local normalizedOrig = normalize(fishName)
    
    if fishImages[normalizedName] then
        return fishImages[normalizedName]
    end
    if normalizedOrig ~= normalizedName and fishImages[normalizedOrig] then
        return fishImages[normalizedOrig]
    end

    local before, inside = tostring(baseName):match("^(.-)%s*%((.-)%)%s*$")
    if before and inside then
        local swapped = inside .. " " .. before
        local swappedKey = normalize(swapped)
        if fishImages[swappedKey] then
            return fishImages[swappedKey]
        end
        local beforeKey = normalize(before)
        if fishImages[beforeKey] then
            return fishImages[beforeKey]
        end
    end

    local tokenLookup = fishImagesTokens[tokenKey(baseName)]
    if tokenLookup then
        return tokenLookup
    end
    if baseName ~= fishName then
        local tokenLookupOrig = fishImagesTokens[tokenKey(fishName)]
        if tokenLookupOrig then
            return tokenLookupOrig
        end
    end

    -- Prefer longest matching name (e.g. "skeleton narwhal" beats "narwhal" for "GHOST Skeleton Narwhal")
    local bestMatch = nil
    local bestLen = 0
    for name, id in pairs(fishImages) do
        if normalizedName:find(name, 1, true) or name:find(normalizedName, 1, true) then
            if #name > bestLen then
                bestLen = #name
                bestMatch = id
            end
        end
    end
    if bestMatch then return bestMatch end

    return nil
end

local function loadFishDataLegacy()
    pcall(function()
        local itemsFolder = ReplicatedStorage:WaitForChild("Items", 60)
        local count = 0
        if not itemsFolder then return warn("DVN Logger: Items folder not found.") end
        for _, itemModule in ipairs(itemsFolder:GetDescendants()) do
            if itemModule:IsA("ModuleScript") then
                local s, d = pcall(require, itemModule)
                if s and type(d) == "table" and d.Data and d.Data.Type and d.Data.Name and d.Data.Icon and d.Data.Type:lower():find("fish") then
                    fishImages[normalize(d.Data.Name)] = d.Data.Icon
                    count = count + 1
                end
            end
        end
        print("🐟 DVN Logger: Loaded " .. count .. " fish images.")
    end)
end

local function loadFishData()
    local count = 0

    local function scan(container)
        for _, itemModule in ipairs(container:GetDescendants()) do
            if itemModule:IsA("ModuleScript") then
                local ok, d = pcall(require, itemModule)
                if ok and type(d) == "table" then
                    local data = d.Data or d
                    local name = data and (data.Name or data.ItemName or data.FishName)
                    local icon = data and resolveIcon(data.Icon or data.Image or data.Thumbnail or data.IconId)
                    if name and icon and isFishData(data, itemModule) then
                        addFishImage(name, icon)
                        count = count + 1
                    end
                end
            end
        end
    end

    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if itemsFolder then
        scan(itemsFolder)
    else
        warn("DVN Logger: Items folder not found, trying full ReplicatedStorage scan.")
    end

    if count == 0 then
        scan(ReplicatedStorage)
    end

    print("🐟 DVN Logger: Loaded " .. count .. " fish images.")
end

local function stripRichText(t) return t:gsub("<.->", "") end

local function extractDisplayName(text)
    local clean = stripRichText(text)
    return clean:match("^%[Server%]:%s*(.-)%s*obtained") or clean:match("^(.-)%s*obtained") or "Unknown"
end

local function detectChance(t) return t:match("1 in ([%dKMB]+)") or "?" end

local function detectRarity(text)
    local r,g,b = text:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)")
    -- Jika warna tidak ada di list (misal Common/Uncommon), kembalikan nil atau Other
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
    -- Trim trailing spaces
    return (fish and fish:gsub("%s+$", "") or "Unknown Fish"), (weight or "-")
end

-- WEBHOOK FUNCTIONS
local Queue = {}
local IsSending = false

local function ProcessQueue()
    if IsSending then return end
    IsSending = true
    task.spawn(function()
        while #Queue > 0 do
            local data = table.remove(Queue, 1)
            pcall(function()
                req({ 
                    Url = data.Url, 
                    Method = "POST", 
                    Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Roblox/1.0.0" }, 
                    Body = HttpService:JSONEncode(data.Payload) 
                })
            end)
            task.wait(2)
        end
        IsSending = false
    end)
end

local function send(payload)
    if SETTINGS.WebhookURL == "" then
        warn("⚠️ Webhook URL is empty! Check Settings.")
        return
    end
    if not req then return end

    -- [FIX] Gunakan URL asli untuk mencegah BAC-10227
    local finalURL = SETTINGS.WebhookURL

    table.insert(Queue, {Url = finalURL, Payload = payload})
    ProcessQueue()
end

local function testWebhook()
    local executor = (identifyexecutor and identifyexecutor()) or "Unknown"
    send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {{
        title = "✅ System Online",
        description = "Logger is active and monitoring catches.",
        color = 0x57F287,
        thumbnail = { url = WEBHOOK_AVATAR },
        fields = {
            { name = "👤 Session", value = "**" .. LocalPlayer.DisplayName .. "**\n`@" .. LocalPlayer.Name .. "`", inline = true },
            { name = "💻 Client",  value = executor .. "\n`" .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms`", inline = true },
        },
        footer = { text = "Babu DVN  •  System" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }} })
end

local function sendFish(data)
    local imageUrl = toURL(getFishImage(data.Fish))

    -- 1. Check Priority: FOCUS FISH (ByName)
    local focusData = FOCUS_FISH[data.Fish]
    if focusData and focusData.Enabled then
        local embed = {
            title = "🎯 Target Acquired",
            description = "**" .. data.Fish .. "**",
            color = focusData.Color,
            fields = {
                { name = "👤 Catcher", value = data.Player,                       inline = true },
                { name = "⚖️ Weight",  value = "`" .. data.Weight .. "`",          inline = true },
                { name = "🎲 Chance",  value = "`1 in " .. data.Chance .. "`",     inline = true },
            },
            footer = { text = "Babu DVN  •  Focus Tracker" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        if imageUrl then embed.thumbnail = { url = imageUrl } end
        send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {embed} })
        return
    end

    -- 2. Check Secondary: RARITY
    local cfg = RARITY_CONFIG[data.Rarity]
    if cfg and cfg.Enabled then
        local embed = {
            title = cfg.Icon .. " " .. data.Rarity .. " Catch",
            description = "**" .. data.Fish .. "**",
            color = cfg.Color,
            fields = {
                { name = "👤 Catcher", value = data.Player,                       inline = true },
                { name = "⚖️ Weight",  value = "`" .. data.Weight .. "`",          inline = true },
                { name = "🎲 Chance",  value = "`1 in " .. data.Chance .. "`",     inline = true },
            },
            footer = { text = "Babu DVN  •  Fish Logger" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        if imageUrl then embed.thumbnail = { url = imageUrl } end
        send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {embed} })
    end
end

local function sendJoinLeave(player, joined)
    if not SETTINGS.LogJoinLeave then return end
    send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {{
        title = joined and "👋 Player Joined" or "🚪 Player Left",
        description = "**" .. player.DisplayName .. "**  `@" .. player.Name .. "`",
        color = joined and 0x2ECC71 or 0xE74C3C,
        footer = { text = "Babu DVN  •  Server Activity" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }} })
end

-- LISTENERS
TextChatService.OnIncomingMessage = function(msg)
    if not SETTINGS.LogFish then return end
    if not msg.Text then return end
    if msg.TextSource then return end -- Anti Spoof
    if not msg.Text:find("obtained") then return end
    
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

task.spawn(loadFishData)

-- ====================================================================
-- 2. UI DVN SETUP (GUI CODE)
-- ====================================================================

-- CLEANUP OLD GUI
if GUI_PARENT:FindFirstChild("DVN_HUB_LOGGER") then
    GUI_PARENT.DVN_HUB_LOGGER:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_HUB_LOGGER"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false

-- UI CONFIG
local Viewport = Camera.ViewportSize
local WIN_W = math.clamp(Viewport.X * 0.42, 320, 460)
local WIN_H = math.clamp(Viewport.Y * 0.58, 300, 520)
local DEFAULT_SIZE = UDim2.new(0, WIN_W, 0, WIN_H)
local MINIMIZED_SIZE = UDim2.new(0, WIN_W, 0, 44)
local MIN_SIZE = Vector2.new(300, 280)

local MAIN_BG    = Color3.fromRGB(12, 12, 14)
local HEADER_BG  = Color3.fromRGB(18, 18, 22)
local ELEMENT_BG = Color3.fromRGB(22, 22, 28)
local ACCENT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_COLOR = Color3.fromRGB(235, 235, 240)
local TEXT_DIM   = Color3.fromRGB(85, 85, 95)
local TOGGLE_ON  = Color3.fromRGB(88, 196, 121)
local TOGGLE_OFF = Color3.fromRGB(40, 40, 52)

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = MAIN_BG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 58)
MainStroke.Thickness = 1

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = HEADER_BG
Header.BorderSizePixel = 0
local HFill = Instance.new("Frame", Header) -- Fills rounded bottom so it joins TabBar cleanly
HFill.Size = UDim2.new(1, 0, 0, 10); HFill.Position = UDim2.new(0, 0, 1, -10); HFill.BackgroundColor3 = HEADER_BG; HFill.BorderSizePixel = 0
local Title = Instance.new("TextLabel", Header)
Title.Text = "DVN LOGGER"; Title.Size = UDim2.new(1, -90, 1, 0); Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1; Title.TextColor3 = TEXT_COLOR; Title.Font = Enum.Font.GothamBold; Title.TextSize = 15; Title.TextXAlignment = Enum.TextXAlignment.Left
local VerLabel = Instance.new("TextLabel", Header)
VerLabel.Text = "v9.2"; VerLabel.Size = UDim2.new(0, 40, 0, 16); VerLabel.Position = UDim2.new(0, 108, 0.5, -8)
VerLabel.BackgroundTransparency = 1; VerLabel.TextColor3 = TEXT_DIM; VerLabel.Font = Enum.Font.Gotham; VerLabel.TextSize = 11; VerLabel.TextXAlignment = Enum.TextXAlignment.Left
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Name = "MinBtn"; MinBtn.Size = UDim2.new(0, 44, 1, 0); MinBtn.Position = UDim2.new(1, -44, 0, 0)
MinBtn.BackgroundTransparency = 1; MinBtn.Text = "—"; MinBtn.TextColor3 = TEXT_DIM; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18
local HeaderBorder = Instance.new("Frame", Header)
HeaderBorder.Size = UDim2.new(1, 0, 0, 1); HeaderBorder.Position = UDim2.new(0, 0, 1, -1); HeaderBorder.BackgroundColor3 = Color3.fromRGB(35, 35, 48); HeaderBorder.BorderSizePixel = 0

-- TAB BAR
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Name = "TabBar"; TabBar.Size = UDim2.new(1, 0, 0, 36); TabBar.Position = UDim2.new(0, 0, 0, 44); TabBar.BackgroundTransparency = 1
local TabBarLayout = Instance.new("UIListLayout", TabBar)
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal; TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
local TabBorder = Instance.new("Frame", MainFrame)
TabBorder.Size = UDim2.new(1, 0, 0, 1); TabBorder.Position = UDim2.new(0, 0, 0, 80); TabBorder.BackgroundColor3 = Color3.fromRGB(32, 32, 42); TabBorder.BorderSizePixel = 0

-- CONTENT AREA
local Content = Instance.new("Frame", MainFrame)
Content.Name = "Content"; Content.Size = UDim2.new(1, 0, 1, -82); Content.Position = UDim2.new(0, 0, 0, 82); Content.BackgroundTransparency = 1; Content.ClipsDescendants = true

-- TABS
local Tabs = {"Info", "Dashboard", "Settings"}
local TabFrames = {}
local TabButtons = {}

local function SwitchTab(activeName)
    for name, frame in pairs(TabFrames) do frame.Visible = (name == activeName) end
    for name, btn in pairs(TabButtons) do
        btn.TextColor3 = (name == activeName) and TEXT_COLOR or TEXT_DIM
        if btn:FindFirstChild("ActiveLine") then
            btn.ActiveLine.BackgroundTransparency = (name == activeName) and 0 or 1
        end
    end
end

for i, name in ipairs(Tabs) do
    local Page = Instance.new("ScrollingFrame", Content)
    Page.Name = name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1
    Page.Visible = false; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 70)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y; Page.CanvasSize = UDim2.new(0,0,0,0)
    local PLayout = Instance.new("UIListLayout", Page); PLayout.Padding = UDim.new(0, 6); PLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local PPad = Instance.new("UIPadding", Page)
    PPad.PaddingTop = UDim.new(0, 10); PPad.PaddingLeft = UDim.new(0, 12); PPad.PaddingRight = UDim.new(0, 12); PPad.PaddingBottom = UDim.new(0, 10)
    TabFrames[name] = Page

    local Btn = Instance.new("TextButton", TabBar)
    Btn.Name = name; Btn.LayoutOrder = i; Btn.Size = UDim2.new(1/3, 0, 1, 0)
    Btn.BackgroundTransparency = 1; Btn.Text = name; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13
    Btn.TextColor3 = TEXT_DIM; Btn.AutoButtonColor = false
    local ActiveLine = Instance.new("Frame", Btn)
    ActiveLine.Name = "ActiveLine"; ActiveLine.Size = UDim2.new(0.5, 0, 0, 2); ActiveLine.Position = UDim2.new(0.25, 0, 1, -2)
    ActiveLine.BackgroundColor3 = ACCENT_COLOR; ActiveLine.BorderSizePixel = 0; ActiveLine.BackgroundTransparency = 1
    Instance.new("UICorner", ActiveLine).CornerRadius = UDim.new(1, 0)
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = Btn
end

-- HELPER FUNCTIONS
local function GetOrder(parent) return #parent:GetChildren() end

function CreateSection(parent, text)
    local Lab = Instance.new("TextLabel", parent)
    Lab.LayoutOrder = GetOrder(parent); Lab.Text = text:upper(); Lab.Size = UDim2.new(1, 0, 0, 22)
    Lab.BackgroundTransparency = 1; Lab.TextColor3 = TEXT_DIM; Lab.Font = Enum.Font.GothamBold; Lab.TextSize = 11; Lab.TextXAlignment = Enum.TextXAlignment.Left
end

function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.LayoutOrder = GetOrder(parent); Btn.Size = UDim2.new(1, 0, 0, 40); Btn.BackgroundColor3 = ELEMENT_BG
    Btn.Text = text; Btn.TextColor3 = TEXT_COLOR; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 14; Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local BStroke = Instance.new("UIStroke", Btn); BStroke.Color = Color3.fromRGB(38, 38, 50); BStroke.Thickness = 1
    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
    Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play() end)
    Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = ELEMENT_BG}):Play() end)
end

function CreateToggle(parent, text, defaultVal, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.LayoutOrder = GetOrder(parent); Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundColor3 = ELEMENT_BG; Frame.BorderSizePixel = 0
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local FStroke = Instance.new("UIStroke", Frame); FStroke.Color = Color3.fromRGB(38, 38, 50); FStroke.Thickness = 1
    local Lab = Instance.new("TextLabel", Frame)
    Lab.Text = text; Lab.Size = UDim2.new(1, -58, 1, 0); Lab.Position = UDim2.new(0, 12, 0, 0)
    Lab.BackgroundTransparency = 1; Lab.TextColor3 = TEXT_COLOR; Lab.Font = Enum.Font.GothamBold; Lab.TextSize = 13
    Lab.TextXAlignment = Enum.TextXAlignment.Left; Lab.TextTruncate = Enum.TextTruncate.AtEnd
    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 38, 0, 20); ToggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleBtn.BackgroundColor3 = defaultVal and TOGGLE_ON or TOGGLE_OFF; ToggleBtn.Text = ""; ToggleBtn.AutoButtonColor = false
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame", ToggleBtn)
    Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = defaultVal and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    local on = defaultVal
    ToggleBtn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = TOGGLE_ON}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = TOGGLE_OFF}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7)}):Play()
        end
        pcall(callback, on)
    end)
end

function CreateInput(parent, placeholder, defaultText, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.LayoutOrder = GetOrder(parent); Frame.Size = UDim2.new(1, 0, 0, 44); Frame.BackgroundColor3 = ELEMENT_BG; Frame.BorderSizePixel = 0
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local IStroke = Instance.new("UIStroke", Frame); IStroke.Color = Color3.fromRGB(38, 38, 50); IStroke.Thickness = 1
    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(1, -24, 1, 0); Box.Position = UDim2.new(0, 12, 0, 0); Box.BackgroundTransparency = 1
    Box.Text = defaultText or ""; Box.PlaceholderText = placeholder; Box.TextColor3 = TEXT_COLOR
    Box.PlaceholderColor3 = TEXT_DIM; Box.Font = Enum.Font.Gotham; Box.TextSize = 13
    Box.TextXAlignment = Enum.TextXAlignment.Left; Box.ClearTextOnFocus = false; Box.TextTruncate = Enum.TextTruncate.AtEnd
    Box.Focused:Connect(function() TweenService:Create(IStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(80, 80, 100)}):Play() end)
    Box.FocusLost:Connect(function()
        TweenService:Create(IStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(38, 38, 50)}):Play()
        pcall(callback, Box.Text)
    end)
end

-- ====================================================================
-- 3. BUILDING THE UI CONTENT
-- ====================================================================

-- [INFO TAB]
CreateSection(TabFrames["Info"], "About")
local InfoTxt = Instance.new("TextLabel", TabFrames["Info"]); InfoTxt.LayoutOrder = GetOrder(TabFrames["Info"]); InfoTxt.Text = "DVN LOGGER v9.2\n\nFocus Tracking enabled for:\n- Sacred Guardian Squid\n- GEMSTONE Ruby\n\nCommon-Rare filters removed."; InfoTxt.Size = UDim2.new(1, 0, 0, 100); InfoTxt.BackgroundTransparency = 1; InfoTxt.TextColor3 = TEXT_DIM; InfoTxt.Font = Enum.Font.GothamBold; InfoTxt.TextSize = 13; InfoTxt.TextXAlignment = Enum.TextXAlignment.Left; InfoTxt.TextWrapped = true
CreateButton(TabFrames["Info"], "Copy Discord Link", function() setclipboard("https://discord.gg/YOUR_DISCORD_LINK") end)

-- [DASHBOARD TAB]
CreateSection(TabFrames["Dashboard"], "Webhook")
CreateInput(TabFrames["Dashboard"], "Paste Webhook URL Here...", SETTINGS.WebhookURL, function(text) SETTINGS.WebhookURL = text end)
CreateButton(TabFrames["Dashboard"], "Test Webhook", testWebhook)
CreateSection(TabFrames["Dashboard"], "Controls")
CreateToggle(TabFrames["Dashboard"], "Enable Logger", SETTINGS.LogFish, function(val) SETTINGS.LogFish = val end)
CreateToggle(TabFrames["Dashboard"], "Join/Leave Logs", SETTINGS.LogJoinLeave, function(val) SETTINGS.LogJoinLeave = val end)

-- [SETTINGS TAB - FOCUS & RARITY]
CreateSection(TabFrames["Settings"], "Specific Target")

-- Loop untuk Target Fokus (Sacred & Ruby)
for fishName, config in pairs(FOCUS_FISH) do
    CreateToggle(TabFrames["Settings"], "Focus: " .. fishName, config.Enabled, function(val)
        config.Enabled = val
        print("🎯 Focus " .. fishName .. ": " .. tostring(val))
    end)
end

CreateSection(TabFrames["Settings"], "General Rarity")

-- Loop untuk Rarity (Hanya Epic ke atas)
local RarityOrder = {"Epic", "Legendary", "Mythic", "Secret", "Forgotten"}

for _, rarityKey in ipairs(RarityOrder) do
    local config = RARITY_CONFIG[rarityKey]
    local displayName = rarityKey
    if rarityKey == "Legendary" then displayName = "Legend" end

    CreateToggle(TabFrames["Settings"], "Log " .. displayName, config.Enabled, function(val)
        config.Enabled = val
    end)
end

-- ====================================================================
-- 4. WINDOW LOGIC
-- ====================================================================
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
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
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = lastSize}):Play()
        Content.Visible = true; TabBar.Visible = true; TabBorder.Visible = true; MinBtn.Text = "—"
    else
        lastSize = MainFrame.Size
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = MINIMIZED_SIZE}):Play()
        Content.Visible = false; TabBar.Visible = false; TabBorder.Visible = false; MinBtn.Text = "+"
    end
    isMin = not isMin
end)

local ResizeBtn = Instance.new("ImageButton", MainFrame)
ResizeBtn.Size = UDim2.new(0, 16, 0, 16); ResizeBtn.Position = UDim2.new(1, -16, 1, -16)
ResizeBtn.BackgroundTransparency = 1; ResizeBtn.Image = "rbxassetid://3599185146"
ResizeBtn.ImageTransparency = 0.6; ResizeBtn.ImageColor3 = Color3.fromRGB(80, 80, 100)
local resizing, resizeStart, startSize
ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true; resizeStart = input.Position; startSize = MainFrame.AbsoluteSize end
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

SwitchTab("Dashboard")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = DEFAULT_SIZE}):Play()
print("DVN LOGGER UI LOADED")
