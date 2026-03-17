--[[ 
    💎 DVN LOGGER v11 — LEGACY DOMAIN EDITION
    Status: ACTIVE
    System: Menggunakan jalur 'discordapp.com' (Old API)
]]

-- ====================================================================
-- 1. SERVICES & VARIABLES
-- ====================================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Executor Driver
local req = http_request or request or (fluxus and fluxus.request) or (getgenv and getgenv().request) or (syn and syn.request)

local GUI_PARENT = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- ====================================================================
-- 2. SETTINGS
-- ====================================================================
local SETTINGS = {
    -- Masukkan Link Webhook BIASA (discord.com) gapapa, nanti script yang ubah otomatis.
    WebhookURL = "https://discord.com/api/webhooks/1455188929824161914/ianT2aawksflHN7vmM0_Ptal1PSVGq81O89Y03eP81Y-00obrY4sY6nDwqGxvQPuS8zh", 
    LogFish = true, 
    LogJoinLeave = false 
}

local WEBHOOK_NAME = "Babu DVN"
local WEBHOOK_AVATAR = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png?ex=69724f7b&is=6970fdfb&hm=a5c01f6fd791c0c8e58ca6732eba77b1a21256f63329654d99d4b24498e9bc6d&"

-- Config Rarity
local RARITY_CONFIG = {
    Epic      = { Enabled = false, Color = 0xB373F8, Icon = "🟣" },
    Legendary = { Enabled = false, Color = 0xFFB92B, Icon = "🟡" },
    Mythic    = { Enabled = false, Color = 0xFF1919, Icon = "🔴" },
    Secret    = { Enabled = true, Color = 0x18FF98, Icon = "💎" },
}

local FOCUS_FISH = {
    ["Sacred Guardian Squid"] = { Enabled = true, Color = 0x00FBFF },
    ["GEMSTONE Ruby"]         = { Enabled = true, Color = 0xFF0040 },
    ["GEMSTONE Shiny Ruby"]   = { Enabled = true, Color = 0xFF0040 },
    ["GEMSTONE Big Ruby"]     = { Enabled = true, Color = 0xFF0040 }
}

local RGB_RARITY = {
    ["179,115,248"] = "Epic", ["255,185,43"] = "Legendary", 
    ["255,25,25"] = "Mythic", ["24,255,152"] = "Secret"
}

-- ====================================================================
-- 3. HELPER FUNCTIONS
-- ====================================================================
local fishImages = {}
local fishImagesTokens = {}

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

local function toURL(assetId)
    if not assetId then return nil end
    local asString = tostring(assetId)
    if asString:match("^https?://") then return asString end
    local id = asString:match("%d+") -- Fix format ID
    if not id then return nil end
    return "https://www.roblox.com/asset-thumbnail/image?assetId=" .. id .. "&width=420&height=420&format=png"
end

local function getFishImage(fishName)
    if not fishName or next(fishImages) == nil then return nil end
    local normalizedName = normalize(fishName)
    
    if fishImages[normalizedName] then
        return fishImages[normalizedName]
    end

    local before, inside = tostring(fishName):match("^(.-)%s*%((.-)%)%s*$")
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

    local tokenLookup = fishImagesTokens[tokenKey(fishName)]
    if tokenLookup then
        return tokenLookup
    end
    
    for name, id in pairs(fishImages) do
        if normalizedName:find(name, 1, true) or name:find(normalizedName, 1, true) then
            return id
        end
    end
    
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
        print("🐟 Auto Logger: Loaded " .. count .. " fish images.")
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
        warn("Auto Logger: Items folder not found, trying full ReplicatedStorage scan.")
    end

    if count == 0 then
        scan(ReplicatedStorage)
    end

    print("ðŸŸ Auto Logger: Loaded " .. count .. " fish images.")
end

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

-- ====================================================================
-- 4. SYSTEM PENGIRIM (JALUR TIKUS DISCORDAPP.COM)
-- ====================================================================
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
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "Roblox/1.0.0"
                    },
                    Body = HttpService:JSONEncode(data.Payload)
                })
            end)
            task.wait(2) -- Delay aman untuk mencegah BAC-9226
        end
        IsSending = false
    end)
end

local function send(payload)
    if SETTINGS.WebhookURL == "" then return end
    if not req then return end

    -- [FIX] Gunakan URL asli
    local finalURL = SETTINGS.WebhookURL
    
    table.insert(Queue, {Url = finalURL, Payload = payload})
    ProcessQueue()
end

local function testWebhook()
    local executor = (identifyexecutor and identifyexecutor()) or "Unknown Client"
    send({ 
        username = WEBHOOK_NAME, 
        avatar_url = WEBHOOK_AVATAR, 
        embeds = {{ 
            title = "💎 DVN HUB • SYSTEM ONLINE",
            description = "```ini\n[ STATUS: CONNECTED ]\nUsing Legacy Domain (discordapp.com)```",
            color = 0x2B2D31,
            thumbnail = { url = WEBHOOK_AVATAR }, 
            fields = {
                { name = "👤 User", value = LocalPlayer.DisplayName, inline = true },
                { name = "💻 Exec", value = executor, inline = true }
            },
            footer = {
                text = "Divine Tools • discord.gg/dvn",
                icon_url = WEBHOOK_AVATAR
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") 
        }} 
    })
end

local function sendFish(data)
    local imageUrl = toURL(getFishImage(data.Fish))

    local focusData = FOCUS_FISH[data.Fish]
    if focusData and focusData.Enabled then
        local embed = {
            title = "🚨 TARGET ACQUIRED! 🚨",
            description = "**" .. data.Player .. "** has caught a focused target!",
            color = focusData.Color,
            fields = {
                { name = "👑 Fish", value = "**" .. data.Fish .. "**", inline = false },
                { name = "👤 Player", value = "`" .. data.Player .. "`", inline = true },
                { name = "⚖️ Weight", value = "`" .. data.Weight .. "`", inline = true },
                { name = "🎲 Chance", value = "`1 in " .. data.Chance .. "`", inline = true }
            },
            footer = { text = "Divine Tools • discord.gg/dvn", icon_url = WEBHOOK_AVATAR },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        -- [DEBUG] Paksa gambar muncul di thumbnail untuk tes
        if imageUrl then
            embed.thumbnail = { url = imageUrl }
            embed.image = { url = imageUrl }
        else
            embed.thumbnail = { url = WEBHOOK_AVATAR }
        end

        send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {embed} })
        return
    end

    local cfg = RARITY_CONFIG[data.Rarity]
    if cfg and cfg.Enabled then
        local embed = {
            title = cfg.Icon .. " A wild " .. data.Rarity .. " appeared!",
            description = "A rare fish has been caught on the server.",
            color = cfg.Color,
            fields = {
                { name = "🐟 Fish", value = "**" .. data.Fish .. "**", inline = false },
                { name = "👤 Player", value = "`" .. data.Player .. "`", inline = true },
                { name = "⚖️ Weight", value = "`" .. data.Weight .. "`", inline = true },
                { name = "🎲 Chance", value = "`1 in " .. data.Chance .. "`", inline = true }
            },
            footer = { text = "Divine Tools • discord.gg/dvn", icon_url = WEBHOOK_AVATAR },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        -- [DEBUG] Paksa gambar muncul di thumbnail untuk tes
        if imageUrl then
            embed.thumbnail = { url = imageUrl }
            embed.image = { url = imageUrl }
        else
            embed.thumbnail = { url = WEBHOOK_AVATAR }
        end

        send({ username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, embeds = {embed} })
    end
end

local function sendJoinLeave(player, joined)
    if not SETTINGS.LogJoinLeave then return end
    send({
        username = WEBHOOK_NAME,
        avatar_url = WEBHOOK_AVATAR,
        embeds = {{
            title = joined and "👋 Player Joined" or "🚪 Player Left",
            description = "**" .. player.DisplayName .. "** (`@" .. player.Name .. "`) has " .. (joined and "joined" or "left") .. " the server.",
            color = joined and 0x2ECC71 or 0xE74C3C,
            footer = {
                text = "Divine Tools • discord.gg/dvn",
                icon_url = WEBHOOK_AVATAR
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })
end

-- ====================================================================
-- 5. LISTENER (ANTI-SPOOF GOD MODE)
-- ====================================================================
TextChatService.OnIncomingMessage = function(msg)
    if not SETTINGS.LogFish then return end
    if not msg.Text then return end
    if msg.TextSource then return end -- Anti Spoof: Tolak jika ada pengirimnya
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

-- UI Indicator
if GUI_PARENT:FindFirstChild("DVN_HUB_LOGGER") then GUI_PARENT.DVN_HUB_LOGGER:Destroy() end
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "DVN_HUB_LOGGER"; ScreenGui.Parent = GUI_PARENT; ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 220, 0, 40); MainFrame.Position = UDim2.new(0.5, -110, 0, 5); MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true
local Corner = Instance.new("UICorner", MainFrame); Corner.CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(60,60,60); Stroke.Thickness = 1
local StatusDot = Instance.new("Frame", MainFrame); StatusDot.Size = UDim2.new(0, 10, 0, 10); StatusDot.Position = UDim2.new(0, 15, 0.5, -5); StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 128); Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1,0)
local Title = Instance.new("TextLabel", MainFrame); Title.Text = "DVN LOGGER : ACTIVE"; Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 35, 0, 0); Title.TextColor3 = Color3.fromRGB(240,240,240); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

print("✅ DVN LOGGER v11 LOADED (LEGACY MODE)")
testWebhook()
