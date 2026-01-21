--[[ 
    💎 DVN LOGGER v11 — PROXY EDITION (ANTI-429)
    Fitur: 
    - Auto Proxy (Bypass Discord Block/429)
    - Anti Spoof God Mode
    - Fluxus/Delta/Mobile Support
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- PILIH EXECUTOR DRIVER
local req = http_request or request or (fluxus and fluxus.request) or (getgenv and getgenv().request) or (syn and syn.request)

-- ====================================================================
-- CONFIG WEBHOOK (MASUKKAN LINK ASLI DISCORD DISINI)
-- Script akan otomatis mengubahnya jadi Proxy biar tembus.
-- ====================================================================
local SETTINGS = {
    WebhookURL = "https://discord.com/api/webhooks/1455188929824161914/ianT2aawksflHN7vmM0_Ptal1PSVGq81O89Y03eP81Y-00obrY4sY6nDwqGxvQPuS8zh", 
    LogFish = true, 
    LogJoinLeave = false 
}

local WEBHOOK_NAME = "Babu DVN"
local WEBHOOK_AVATAR = "https://cdn.discordapp.com/attachments/1452251463337377902/1456009509632737417/DVN_New.png"

-- ====================================================================
-- SISTEM PENGIRIM (DENGAN PROXY HYRA)
-- ====================================================================
local function send(payload)
    if SETTINGS.WebhookURL == "" then return end
    if not req then return end

    -- 🛡️ AUTO PROXY SWITCHER 🛡️
    -- Mengubah 'discord.com' menjadi 'hooks.hyra.io' untuk bypass blokir 429
    local proxyURL = SETTINGS.WebhookURL:gsub("discord.com", "hooks.hyra.io")
    
    task.spawn(function()
        pcall(function()
            req({
                Url = proxyURL, -- Kita pakai URL Proxy
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end

-- ====================================================================
-- LOGIC LOGGER (SAMA KAYAK KEMARIN)
-- ====================================================================
local RGB_RARITY = {
    ["179,115,248"] = "Epic", ["255,185,43"] = "Legendary", 
    ["255,25,25"] = "Mythic", ["24,255,152"] = "Secret"
}
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

local function stripRichText(t) return t:gsub("<.->", "") end
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
local function detectChance(t) return t:match("1 in ([%dKMB]+)") or "?" end
local function extractDisplayName(text)
    local clean = stripRichText(text)
    return clean:match("^%[Server%]:%s*(.-)%s*obtained") or clean:match("^(.-)%s*obtained") or "Unknown"
end

local function testWebhook()
    local executor = (identifyexecutor and identifyexecutor()) or "Unknown Client"
    send({ 
        username = WEBHOOK_NAME, 
        avatar_url = WEBHOOK_AVATAR, 
        embeds = {{ 
            title = "💎 DVN HUB • PROXY CONNECTED",
            description = "```ini\n[ STATUS: BYPASSED ]\nProxy Hyra.io Active!\nRate Limit 429 Defeated.```",
            color = 0x2B2D31, 
            fields = {
                { name = "👤 User", value = LocalPlayer.DisplayName, inline = true },
                { name = "💻 Exec", value = executor, inline = true }
            }
        }} 
    })
end

local function sendFish(data)
    local focusData = FOCUS_FISH[data.Fish]
    if focusData and focusData.Enabled then
        send({ 
            username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, 
            embeds = {{ 
                title = "🚨 TARGET ACQUIRED! 🚨", 
                description = "**👑 CAUGHT: " .. data.Fish .. " 👑**", 
                color = focusData.Color, 
                fields = { 
                    { name = "👤 Player", value = "`"..data.Player.."`", inline = true }, 
                    { name = "⚖️ Weight", value = "`"..data.Weight.."`", inline = true }, 
                    { name = "🎲 Chance", value = "`1 in "..data.Chance.."`", inline = true } 
                }, 
                footer = { text = "DVN HUB • Proxy Mode" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") 
            }} 
        })
        return
    end

    local cfg = RARITY_CONFIG[data.Rarity]
    if cfg and cfg.Enabled then
        send({ 
            username = WEBHOOK_NAME, avatar_url = WEBHOOK_AVATAR, 
            embeds = {{ 
                title = cfg.Icon.." "..data.Rarity.." Catch!", 
                color = cfg.Color, 
                fields = { 
                    { name = "👤 Player", value = "`"..data.Player.."`", inline = true }, 
                    { name = "🐟 Fish", value = "**"..data.Fish.."**", inline = true }, 
                    { name = "⚖️ Weight", value = "`"..data.Weight.."`", inline = true }, 
                    { name = "🎲 Chance", value = "`1 in "..data.Chance.."`", inline = true } 
                }, 
                footer = { text = "DVN HUB • Proxy Mode" }
            }} 
        })
    end
end

-- MAIN LISTENER
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

print("✅ DVN LOGGER: PROXY MODE ACTIVATED")
testWebhook()