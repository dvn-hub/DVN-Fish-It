-- [[ 🕵️ DIVINE PTPT CCTV - REAL NUMBER TRACKING ]] --

-- Script ini membaca Value Asli (1644659) bukan Teks Layar (1.6M)

-- v2.0 - Single Embed Edition

-- ⚙️ SETTING WEBHOOK

getgenv().WebhookURL = "https://discord.com/api/webhooks/1466009680785707252/qnk1X9psg-APYBNQznH57QjvOKQN6iiPA5s6GldDeZuCXUS-HJf4GrPjBkN2RfAUEBHf"

-- [FIX] ID Global disimpan biar gak kirim pesan baru kalau re-execute

-- ✅ CONFIG OTOMATIS (Berdasarkan hasil scan abang)

getgenv().FolderName = "leaderstats" 

getgenv().StatName = "Caught" 


-- 🛑 HENTIKAN LOOP LAMA JIKA RE-EXECUTE
if getgenv().DVN_CCTV_Loop then
    task.cancel(getgenv().DVN_CCTV_Loop)
end

-- 📊 VARIABLES SYSTEM

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local LuckStatus = "Inactive" -- Status Server Luck

local HttpService = game:GetService("HttpService")

local Request = (syn and syn.request) or (http and http.request) or http_request or request



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

    description = description .. "```"



    local Payload = {

        ["username"] = "Babu DVN",

        ["avatar_url"] = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png?ex=697ae13b&is=69798fbb&hm=d517522cd951f1992b4268d1291fe2b4be0d624109090934772ac5e33a456d8b&",

        ["embeds"] = {{
            ["title"] = "📈 Divine Tools | Server Performance Monitor",
            ["description"] = description,
            ["color"] = 0x2B2D31,
            ["footer"] = { 
                ["text"] = "Divine Tools • discord.gg/dvn",
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png?ex=697ae13b&is=69798fbb&hm=d517522cd951f1992b4268d1291fe2b4be0d624109090934772ac5e33a456d8b&"
            },

            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")

        }}

    }

    local TargetURL = getgenv().WebhookURL
    local Method = "POST"

    if getgenv().MasterMessageID then
        TargetURL = getgenv().WebhookURL .. "/messages/" .. getgenv().MasterMessageID
        Method = "PATCH"
    else
        TargetURL = getgenv().WebhookURL .. "?wait=true"
    end

    local Response = Request({ Url = TargetURL, Method = Method, Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(Payload) })

    if Response and Response.Body then
        local Success, Body = pcall(function() return HttpService:JSONDecode(Response.Body) end)
        if Success and Body then
            if Body.id and Method == "POST" then
                getgenv().MasterMessageID = Body.id
            end
            if Response.StatusCode == 404 then
                getgenv().MasterMessageID = nil
            end
        end
    end
end



-- 🕵️ FUNGSI MATA-MATA (CCTV)

local function MonitorPlayer(Player)


    local StatsFolder = Player:WaitForChild(getgenv().FolderName, 60)

    if not StatsFolder then return end

    

    local TargetStat = StatsFolder:WaitForChild(getgenv().StatName, 60)

    if not TargetStat then return end

    SessionData[Player.Name] = { StartTime = tick(), StartCount = TargetStat.Value, CurrentValue = TargetStat.Value, FM = 0 }

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
