--[[ 
    💎 DVN LOGGER v11 — GUI INPUT EDITION
    Fitur: Input Webhook Manual + God Mode Anti-Spoof
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local req = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
local GUI_PARENT = (typeof(gethui) == "function" and gethui()) or CoreGui

-- ====================================================================
-- 1. FUNGSI LOGGER UTAMA (Jalan setelah tombol diklik)
-- ====================================================================
local function StartLogger(userWebhook)
    -- KONFIGURASI
    local WEBHOOK_URL = userWebhook
    local WEBHOOK_AVATAR = "https://cdn.discordapp.com/attachments/1452251463337377902/1456009509632737417/DVN_New.png"
    local WEBHOOK_NAME = "DVN Logger"

    local RGB_RARITY = {
        ["179,115,248"] = "Epic", ["255,185,43"] = "Legendary", 
        ["255,25,25"] = "Mythic", ["24,255,152"] = "Secret"
    }

    -- HELPER FUNCTIONS
    local function stripRichText(t) return t:gsub("<.->", "") end
    local function detectRarity(text)
        local r,g,b = text:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)")
        return r and (RGB_RARITY[r..","..g..","..b] or "Other") or "Other"
    end
    local function detectFish(text)
        local clean = stripRichText(text)
        return clean:match("obtained%s+a[n]?%s+(.+)%s*%(") or clean:match("obtained%s+a[n]?%s+(.+)") or "Unknown Fish"
    end
    local function detectPlayer(text)
        local clean = stripRichText(text)
        return clean:match("^(.-)%s*obtained") or "Unknown"
    end

    -- SEND FUNCTION
    local function send(payload)
        if not req then return end
        pcall(function()
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end

    -- MAIN LISTENER (GOD MODE)
    TextChatService.OnIncomingMessage = function(msg)
        if msg.TextSource then return end -- Anti Spoof (Tolak input manusia)
        if not msg.Text:find("obtained") then return end -- Filter kata kunci

        local rarity = detectRarity(msg.Text)
        
        -- Filter: Hanya Secret, Mythic, Legendary (Biar webhook gak spam sampah)
        if rarity == "Secret" or rarity == "Mythic" or rarity == "Legendary" then
            local fishName = detectFish(msg.Text)
            local playerName = detectPlayer(msg.Text)
            
            local color = 0xFFFFFF
            if rarity == "Secret" then color = 0x18FF98
            elseif rarity == "Mythic" then color = 0xFF1919
            elseif rarity == "Legendary" then color = 0xFFB92B end

            send({
                username = WEBHOOK_NAME,
                avatar_url = WEBHOOK_AVATAR,
                embeds = {{
                    title = "🎣 " .. rarity .. " Catch!",
                    description = "**" .. fishName .. "**",
                    color = color,
                    fields = {
                        {name = "Player", value = "`"..playerName.."`", inline = true},
                        {name = "Server Job", value = "`"..game.JobId.."`", inline = true}
                    },
                    footer = {text = "DVN HUB • Public Logger"},
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            })
        end
    end

    -- NOTIFIKASI BERHASIL
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "✅ DVN LOGGER",
        Text = "System Activated! Menunggu ikan...",
        Duration = 5
    })
    
    -- Test Webhook (Optional)
    send({
        username = WEBHOOK_NAME,
        avatar_url = WEBHOOK_AVATAR,
        embeds = {{
            title = "💎 DVN SYSTEM ONLINE",
            description = "Logger berhasil diaktifkan oleh: **" .. LocalPlayer.DisplayName .. "**",
            color = 0x2B2D31
        }}
    })
end

-- ====================================================================
-- 2. GUI INPUT (TAMPILAN AWAL)
-- ====================================================================
if GUI_PARENT:FindFirstChild("DVN_Input") then GUI_PARENT.DVN_Input:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_Input"
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "DVN HUB LOGGER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18.000

local InputBox = Instance.new("TextBox")
InputBox.Parent = Frame
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
InputBox.BorderSizePixel = 0
InputBox.Position = UDim2.new(0.1, 0, 0.35, 0)
InputBox.Size = UDim2.new(0.8, 0, 0, 35)
InputBox.Font = Enum.Font.Gotham
InputBox.PlaceholderText = "Paste Webhook Link Here..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 14.000

local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim.new(0, 6)
UICorner_2.Parent = InputBox

local StartBtn = Instance.new("TextButton")
StartBtn.Parent = Frame
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
StartBtn.BorderSizePixel = 0
StartBtn.Position = UDim2.new(0.25, 0, 0.7, 0)
StartBtn.Size = UDim2.new(0.5, 0, 0, 35)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.Text = "START LOGGER"
StartBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
StartBtn.TextSize = 14.000

local UICorner_3 = Instance.new("UICorner")
UICorner_3.CornerRadius = UDim.new(0, 6)
UICorner_3.Parent = StartBtn

-- ====================================================================
-- 3. LOGIKA TOMBOL
-- ====================================================================
StartBtn.MouseButton1Click:Connect(function()
    local url = InputBox.Text
    
    -- Validasi sederhana: Harus ada tulisan "http"
    if url:find("http") then
        StartBtn.Text = "Connecting..."
        wait(1)
        ScreenGui:Destroy() -- Hapus GUI Input
        StartLogger(url) -- Jalankan Script Utama
    else
        StartBtn.Text = "INVALID LINK!"
        StartBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        wait(1)
        StartBtn.Text = "START LOGGER"
        StartBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
    end
end)
