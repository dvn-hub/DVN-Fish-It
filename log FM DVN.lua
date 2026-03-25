-- [[ 🕵️ DIVINE PTPT CCTV - REAL NUMBER TRACKING ]] --

-- Script ini membaca Value Asli (1644659) bukan Teks Layar (1.6M)

-- v2.0 - Single Embed Edition

-- ⚙️ SETTING WEBHOOK

getgenv().WebhookURL = "https://discord.com/api/webhooks/1466009680785707252/qnk1X9psg-APYBNQznH57QjvOKQN6iiPA5s6GldDeZuCXUS-HJf4GrPjBkN2RfAUEBHf"

-- [FIX] ID Global disimpan biar gak kirim pesan baru kalau re-execute

-- ✅ CONFIG OTOMATIS (Berdasarkan hasil scan abang)

getgenv().FolderName = "leaderstats" 

getgenv().StatName = "Caught" 
getgenv().WarningEnabled = false -- Default OFF (Diatur lewat GUI)
getgenv().WarningThreshold = 13


-- 🛑 HENTIKAN LOOP LAMA JIKA RE-EXECUTE
if getgenv().DVN_CCTV_Loop then
    task.cancel(getgenv().DVN_CCTV_Loop)
end

-- 📊 VARIABLES SYSTEM

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LuckStatus = "Inactive" -- Status Server Luck

local HttpService = game:GetService("HttpService")

local Request = (syn and syn.request) or (http and http.request) or http_request or request

-- Konstanta Webhook
local WEBHOOK_NAME = "Babu DVN"
local WEBHOOK_AVATAR = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png?ex=697ae13b&is=69798fbb&hm=d517522cd951f1992b4268d1291fe2b4be0d624109090934772ac5e33a456d8b&"

-- 📨 FUNGSI LAPOR KE DISCORD

local SessionData = {} -- { [PlayerName] = { StartTime, StartCount, CurrentValue, FM } }

-- 🍀 FUNGSI DETEKSI SERVER LUCK
local function GetLuckDuration()
    local success, text, seconds = pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not pGui then return nil end
        
        local gui = pGui:FindFirstChild("!!! Server Luck")
        if not gui then return nil end
        
        -- Path: Frame["Server Luck"].Inside.Toggles.Timer
        local timer = gui.Frame["Server Luck"].Inside.Toggles.Timer
        if not timer or not timer.Visible then return nil end
        
        local rawText = timer.Text -- "Ends: 52m 39s"
        local cleanText = rawText:gsub("Ends: ", "")
        
        local h = tonumber(cleanText:match("(%d+)h")) or 0
        local m = tonumber(cleanText:match("(%d+)m")) or 0
        local s = tonumber(cleanText:match("(%d+)s")) or 0
        
        return cleanText, (h * 3600) + (m * 60) + s
    end)
    
    return (success and text) or "Inactive", (success and seconds) or 0
end

-- [REVISI] Sistem Antrian untuk Webhook (Anti BAC-9226)
local WebhookQueue = {}
local IsSendingWebhook = false

local function ProcessWebhookQueue()
    if IsSendingWebhook then return end
    IsSendingWebhook = true
    
    task.spawn(function()
        while #WebhookQueue > 0 do
            local requestData = table.remove(WebhookQueue, 1)
            
            local success, Response = pcall(function()
                return Request({
                    Url = requestData.Url, -- [FIX] Revert to original URL (BAC-10227 Fix)
                    Method = requestData.Method,
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "Roblox/1.0.0" -- Standard UA to prevent block
                    },
                    Body = HttpService:JSONEncode(requestData.Payload)
                })
            end)

            if success and Response then
                if Response.Body then
                    local decodeSuccess, Body = pcall(function() return HttpService:JSONDecode(Response.Body) end)
                    if decodeSuccess and Body and Body.id and requestData.Method == "POST" and requestData.IsMaster then
                        -- Hanya set MasterMessageID jika itu adalah laporan utama
                        getgenv().MasterMessageID = Body.id
                    end
                end
                -- [FIX REVISI] Hanya reset ID jika pesan benar-benar hilang (404). Jangan reset jika 429 (Rate Limit) atau error server.
                if requestData.Method == "PATCH" and Response.StatusCode == 404 then
                    getgenv().MasterMessageID = nil
                    table.insert(WebhookQueue, 1, { Url = getgenv().WebhookURL .. "?wait=true", Method = "POST", Payload = requestData.Payload, IsMaster = true })
                elseif requestData.Method == "PATCH" and Response.StatusCode >= 400 then
                    warn("[DVN CCTV] Patch Gagal (Status: " .. tostring(Response.StatusCode) .. ") - Menunggu loop berikutnya.")
                end
            elseif not success then
                warn("[DVN CCTV] Webhook request failed (BAC-SAFE): " .. tostring(Response))
                -- [FIX] Jangan reset ID jika gagal koneksi (timeout/network error). Biarkan loop selanjutnya mencoba lagi.
            end
            
            task.wait(2) -- Jeda aman untuk mencegah rate limit
        end
        IsSendingWebhook = false
    end)
end

-- 📨 FUNGSI LAPOR GABUNGAN (Premium Embed)
local function SendMasterReport()
    local luckText, _ = GetLuckDuration()
    local description = "**Host:** " .. LocalPlayer.DisplayName .. " (`" .. LocalPlayer.Name .. "`)\n"
    description = description .. "**Server Luck:** " .. luckText .. "\n\n"
    description = description .. "```\n"
    description = description .. string.format("%-20s | %-12s | %-15s\n", "PLAYER", "FM (/min)", "TOTAL CAUGHT")
    description = description .. string.rep("-", 54) .. "\n"

    local playersToReport = {}
    for name, data in pairs(SessionData) do
        if data.CurrentValue then
            table.insert(playersToReport, {
                name = name,
                fm = data.FM or 0,
                value = data.CurrentValue
            })
        end
    end
    
    if #playersToReport == 0 then
        description = description .. "Menunggu data pemain...\n"
    else
        table.sort(playersToReport, function(a, b) return a.fm > b.fm end)
        for _, data in ipairs(playersToReport) do
            local formattedValue = tostring(data.value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
            description = description .. string.format("%-20s | %-12.2f | %-15s\n", data.name:sub(1, 20), data.fm, formattedValue)
        end
    end

    -- [SAFETY] Truncate description to prevent 400 Bad Request (Limit 4096)
    if #description > 4000 then description = description:sub(1, 4000) .. "\n... (Truncated)" end
    description = description .. "```"



    local Payload = {
        ["username"] = WEBHOOK_NAME,
        ["avatar_url"] = WEBHOOK_AVATAR,
        ["embeds"] = {{
            ["title"] = "📊 Server FM Monitor",
            ["description"] = description,
            ["color"] = 0x3A3B40,
            ["footer"] = {
                ["text"] = "Babu DVN  •  FM Monitor",
                ["icon_url"] = WEBHOOK_AVATAR
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local TargetURL = getgenv().WebhookURL
    local Method = "POST"
    local IsMasterReport = true

    if getgenv().MasterMessageID then
        TargetURL = getgenv().WebhookURL .. "/messages/" .. getgenv().MasterMessageID
        Method = "PATCH"
        -- [FIX BAC-6223] Jangan kirim username/avatar saat PATCH (Edit Mode)
        Payload.username = nil
        Payload.avatar_url = nil
    else
        TargetURL = getgenv().WebhookURL .. "?wait=true"
    end
    
    table.insert(WebhookQueue, { Url = TargetURL, Method = Method, Payload = Payload, IsMaster = IsMasterReport })
    ProcessWebhookQueue()
end

-- ⚠️ FUNGSI WARNING (JIKA FM > 13)
local function SendWarning(name, fm, total)
    local totalFmt = tostring(total):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    local description = "**" .. name .. "**\n"
        .. "⚡ `" .. fm .. " FM/min`  ·  📦 `" .. totalFmt .. " caught`\n\n"
        .. "*Exceeded safety threshold (" .. getgenv().WarningThreshold .. " FM/min)*"

    local Payload = {
        ["username"] = WEBHOOK_NAME,
        ["avatar_url"] = WEBHOOK_AVATAR,
        ["embeds"] = {{
            ["title"] = "⚠️ High FM Detected",
            ["description"] = description,
            ["color"] = 0xED4245,
            ["footer"] = {
                ["text"] = "Babu DVN  •  FM Monitor",
                ["icon_url"] = WEBHOOK_AVATAR
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    table.insert(WebhookQueue, { Url = getgenv().WebhookURL, Method = "POST", Payload = Payload, IsMaster = false })
    ProcessWebhookQueue()
end


-- 🕵️ FUNGSI MATA-MATA (CCTV)

local function MonitorPlayer(Player)


    local StatsFolder = Player:WaitForChild(getgenv().FolderName, 60)

    if not StatsFolder then return end

    

    local TargetStat = StatsFolder:WaitForChild(getgenv().StatName, 60)

    if not TargetStat then return end

    SessionData[Player.Name] = { StartTime = tick(), StartCount = TargetStat.Value, CurrentValue = TargetStat.Value, FM = 0, LastWarning = 0 }

    TargetStat.Changed:Connect(function(NewValue)

        local Data = SessionData[Player.Name]

        if not Data then return end
        
        -- [FIX] Update Total Asli DULUAN biar selalu akurat
        Data.CurrentValue = NewValue

        local Gained = NewValue - Data.StartCount

        local TimeElapsed = tick() - Data.StartTime

        -- [FIX v2] Anti-Glitch lebih pintar, deteksi lonjakan cepat walau angka kecil
        if (Gained > 500) or (Gained > 10 and TimeElapsed < 15) then
            Data.StartCount = NewValue
            Data.StartTime = tick()
            return
        end

        if TimeElapsed < 1 or Gained <= 0 then return end 

        local Minutes = TimeElapsed / 60

        Data.FM = (Minutes > 0) and (math.floor((Gained / Minutes) * 100) / 100) or 0

        -- [CHECK WARNING]
        if getgenv().WarningEnabled and Data.FM > getgenv().WarningThreshold then
            if not Data.LastWarning or (tick() - Data.LastWarning > 60) then -- Cooldown 60s agar tidak spam
                SendWarning(Player.Name, Data.FM, Data.CurrentValue)
                Data.LastWarning = tick()
            end
        end
    end)


end



-- 🔄 JALANKAN KE SEMUA PLAYER

print("✅ CCTV DIAKTIFKAN! Laporan gabungan setiap 60 detik.")

for _, P in pairs(Players:GetPlayers()) do

    task.spawn(function() MonitorPlayer(P) end)

end



-- KALAU ADA YANG BARU JOIN

Players.PlayerAdded:Connect(function(P)

    task.spawn(function() MonitorPlayer(P) end)

end)

Players.PlayerRemoving:Connect(function(Player)
    if SessionData[Player.Name] then
        SessionData[Player.Name] = nil
    end
end)

-- 🔄 LOOP UTAMA UNTUK MENGIRIM LAPORAN GABUNGAN
getgenv().DVN_CCTV_Loop = task.spawn(function()
    while task.wait(60) do
        pcall(SendMasterReport)
    end
end)

-- 🖥️ GUI CONTROL PANEL
local GUI_PARENT = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
if GUI_PARENT:FindFirstChild("DVN_CCTV_UI") then GUI_PARENT.DVN_CCTV_UI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_CCTV_UI"; ScreenGui.Parent = GUI_PARENT; ScreenGui.ResetOnSpawn = false

-- Colors
local C_BG     = Color3.fromRGB(12, 12, 14)
local C_HEADER = Color3.fromRGB(18, 18, 22)
local C_TEXT   = Color3.fromRGB(235, 235, 240)
local C_DIM    = Color3.fromRGB(85, 85, 95)
local C_ON     = Color3.fromRGB(88, 196, 121)
local C_OFF    = Color3.fromRGB(40, 40, 52)

local PANEL_W, PANEL_H = 270, 88

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
MainFrame.Position = UDim2.new(0.5, -PANEL_W/2, 0.08, 0)
MainFrame.BackgroundColor3 = C_BG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MStroke = Instance.new("UIStroke", MainFrame)
MStroke.Color = Color3.fromRGB(45, 45, 58); MStroke.Thickness = 1

-- Header (draggable)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 36); Header.BackgroundColor3 = C_HEADER; Header.BorderSizePixel = 0
local HFill = Instance.new("Frame", Header) -- Square bottom corners
HFill.Size = UDim2.new(1, 0, 0, 10); HFill.Position = UDim2.new(0, 0, 1, -10); HFill.BackgroundColor3 = C_HEADER; HFill.BorderSizePixel = 0
local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Text = "FM MONITOR"; TitleLbl.Size = UDim2.new(1, -50, 1, 0); TitleLbl.Position = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1; TitleLbl.TextColor3 = C_TEXT; TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextSize = 13; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
local VerLbl = Instance.new("TextLabel", Header)
VerLbl.Text = "v2.0"; VerLbl.Size = UDim2.new(0, 40, 1, 0); VerLbl.Position = UDim2.new(1, -44, 0, 0)
VerLbl.BackgroundTransparency = 1; VerLbl.TextColor3 = C_DIM; VerLbl.Font = Enum.Font.Gotham; VerLbl.TextSize = 11; VerLbl.TextXAlignment = Enum.TextXAlignment.Right
local HeaderBorder = Instance.new("Frame", Header)
HeaderBorder.Size = UDim2.new(1, 0, 0, 1); HeaderBorder.Position = UDim2.new(0, 0, 1, -1); HeaderBorder.BackgroundColor3 = Color3.fromRGB(35, 35, 48); HeaderBorder.BorderSizePixel = 0

-- Toggle Row
local RowPad = Instance.new("Frame", MainFrame)
RowPad.Size = UDim2.new(1, -24, 0, 44); RowPad.Position = UDim2.new(0, 12, 0, 40); RowPad.BackgroundTransparency = 1
local WarnLabel = Instance.new("TextLabel", RowPad)
WarnLabel.Text = "⚠️  Warning Mode"; WarnLabel.Size = UDim2.new(1, -58, 1, 0)
WarnLabel.BackgroundTransparency = 1; WarnLabel.TextColor3 = C_TEXT; WarnLabel.Font = Enum.Font.GothamBold; WarnLabel.TextSize = 13; WarnLabel.TextXAlignment = Enum.TextXAlignment.Left
local ToggleBtn = Instance.new("TextButton", RowPad)
ToggleBtn.Size = UDim2.new(0, 38, 0, 20); ToggleBtn.Position = UDim2.new(1, -38, 0.5, -10)
ToggleBtn.BackgroundColor3 = getgenv().WarningEnabled and C_ON or C_OFF
ToggleBtn.Text = ""; ToggleBtn.AutoButtonColor = false
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local Dot = Instance.new("Frame", ToggleBtn)
Dot.Size = UDim2.new(0, 14, 0, 14)
Dot.Position = getgenv().WarningEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().WarningEnabled = not getgenv().WarningEnabled
    if getgenv().WarningEnabled then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = C_ON}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = C_OFF}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7)}):Play()
    end
end)

-- Drag
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

-- Entrance animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, PANEL_W, 0, PANEL_H)}):Play()
