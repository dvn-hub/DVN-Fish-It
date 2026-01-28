-- [[ 🕵️ DIVINE PTPT CCTV - REAL NUMBER TRACKING ]] --

-- Script ini membaca Value Asli (1644659) bukan Teks Layar (1.6M)



-- ⚙️ SETTING WEBHOOK

getgenv().WebhookURL = "https://discord.com/api/webhooks/1463022024577519719/rZyVFL5-F2p5YZLgYeGevW7YVHuaToPAHfs76bvrcUf_Y-lFVslNtohcPH95DXqlAxHE"



-- ✅ CONFIG OTOMATIS (Berdasarkan hasil scan abang)

getgenv().FolderName = "leaderstats" 

getgenv().StatName = "Caught" 



-- 📊 VARIABLES SYSTEM

local Players = game:GetService("Players")

local HttpService = game:GetService("HttpService")

local Request = (syn and syn.request) or (http and http.request) or http_request or request

local SessionData = {} 



-- 📨 FUNGSI LAPOR KE DISCORD

local function ReportToDiscord(PlayerName, RealValue, FM)

    local EmbedColor = 3066993 -- Hijau (Normal)

    if FM < 1 then EmbedColor = 15158332 end -- Merah (Macet)

    if FM > 15 then EmbedColor = 3447003 end -- Biru (Ngebut)



    -- Format Angka biar ada komanya (Contoh: 1,644,659)

    local FormattedValue = tostring(RealValue):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")



    local Payload = {

        ["username"] = "Babu DVN",

        ["avatar_url"] = "https://cdn.discordapp.com/attachments/1451798194928353437/1463570214829555878/profil_bot.png?ex=697ae13b&is=69798fbb&hm=d517522cd951f1992b4268d1291fe2b4be0d624109090934772ac5e33a456d8b&",

        ["embeds"] = {{

            ["title"] = "🎣 STATUS: " .. PlayerName,

            ["color"] = EmbedColor,

            ["fields"] = {

                { ["name"] = "🚀 Kecepatan (F/M)", ["value"] = "**" .. tostring(FM) .. "** / min", ["inline"] = true },

                { ["name"] = "🔢 Total Asli", ["value"] = FormattedValue, ["inline"] = true }

            },

            ["footer"] = { ["text"] = "Divine Tools • discord.gg/dvn • " .. os.date("%X") }

        }}

    }

   -- LOGIC EDIT MODE (Supaya gak berisik)
    local Data = SessionData[PlayerName]
    local TargetURL = getgenv().WebhookURL
    local Method = "POST"

    if Data and Data.MessageID then
        TargetURL = getgenv().WebhookURL .. "/messages/" .. Data.MessageID
        Method = "PATCH"
    else
        TargetURL = getgenv().WebhookURL .. "?wait=true"
    end

      local Response = Request({

        Url = TargetURL,

        Method = Method,

        Headers = {["Content-Type"] = "application/json"},

        Body = HttpService:JSONEncode(Payload)

    })
    -- Simpan Message ID jika baru pertama kirim (POST)
    if Method == "POST" and Response and Response.Body then
        local Success, Body = pcall(function() return HttpService:JSONDecode(Response.Body) end)
        if Success and Body and Body.id then
            if SessionData[PlayerName] then
                SessionData[PlayerName].MessageID = Body.id
            end
        end
    end
end



-- 🕵️ FUNGSI MATA-MATA (CCTV)

local function MonitorPlayer(Player)

    -- Tunggu Leaderstats & Caught Muncul

    local StatsFolder = Player:WaitForChild(getgenv().FolderName, 60)

    if not StatsFolder then return end

    

    local TargetStat = StatsFolder:WaitForChild(getgenv().StatName, 60)

    if not TargetStat then return end



    -- Simpan Angka Awal (Ini ngambil angka murni 1644659)

    SessionData[Player.Name] = {

        StartTime = tick(),

        StartCount = TargetStat.Value 

    }



    -- Pasang Alat Sadap: Kalau angka berubah, lapor!

    TargetStat.Changed:Connect(function(NewValue)

        local Data = SessionData[Player.Name]

        if not Data then return end



        local TimeElapsed = tick() - Data.StartTime

        local Gained = NewValue - Data.StartCount

        

        -- Filter: Cuma lapor kalau nambah positif

        if Gained <= 0 then return end 



        local Minutes = TimeElapsed / 60

        local FM = 0

        if Minutes > 0 then 

            FM = math.floor((Gained / Minutes) * 100) / 100 

        end



        -- Lapor pakai angka asli

        ReportToDiscord(Player.Name, NewValue, FM)

    end)

end



-- 🔄 JALANKAN KE SEMUA PLAYER

print("✅ CCTV DIAKTIFKAN! Target: " .. getgenv().StatName)

for _, P in pairs(Players:GetPlayers()) do

    task.spawn(function() MonitorPlayer(P) end)

end



-- KALAU ADA YANG BARU JOIN

Players.PlayerAdded:Connect(function(P)

    task.spawn(function() MonitorPlayer(P) end)

end)
