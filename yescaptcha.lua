-- Konfigurasi
local CLIENT_KEY = "f61b316722afae48a97e5136cd0455480861df8d94623"
local WEBSITE_KEY = "A2A14B1D-148C-4C27-9891-652186380975"
local WEBSITE_URL = "https://www.roblox.com"

-- Variabel Global untuk Dashboard ASCII
local logs = {}
local dashboard_state = {
    status = "IDLE",
    taskId = "-",
    message = "Siap dijalankan",
    instances = {} -- Menyimpan daftar PID dan statusnya
}

-- Fungsi menggambar Dashboard ASCII
function draw_dashboard()
    -- Menggunakan ANSI Escape Code untuk clear screen (lebih cepat & rapi di Termux)
    -- \27[2J = Clear Screen, \27[H = Cursor Home
    io.write("\27[2J\27[H")
    
    -- Helper untuk print dengan Carriage Return (\r) agar tidak berantakan (staircase effect)
    local function print_r(text)
        io.write(text .. "\r\n")
    end

    print_r("╔══════════════════════════════════════════╗")
    print_r("║      🚀 YESCAPTCHA SOLVER TERMUX 🚀      ║")
    print_r("╠══════════════════════════════════════════╣")
    print_r(string.format("║ STATUS  : %-30s ║", dashboard_state.status))
    print_r(string.format("║ TASK ID : %-30s ║", dashboard_state.taskId))
    print_r("╠══════════════════════════════════════════╣")
    print_r("║ DETEKSI INSTANCE ROBLOX:                 ║")
    print_r("║ PACKAGE NAME          | STATUS           ║")
    print_r("╠═══════════════════════╪══════════════════╣")
    
    local count = dashboard_state.instances and #dashboard_state.instances or 0
    if count == 0 then
        print_r("║  [ Tidak ada paket com.roblox* ]         ║")
    else
        for i, inst in ipairs(dashboard_state.instances) do
            local name = inst.name
            if #name > 21 then name = ".." .. name:sub(-19) end
            
            local status = inst.status
            if #status > 16 then status = status:sub(1, 14) .. ".." end
            
            print_r(string.format("║ %-21s | %-16s ║", name, status))
        end
    end
    
    print_r("╠══════════════════════════════════════════╣")
    print_r("║ LOG AKTIVITAS:                           ║")
    for i = 1, 5 do -- Kurangi log jadi 5 baris untuk memberi ruang
        local log_line = logs[i] or ""
        -- Potong log jika terlalu panjang agar rapi
        if #log_line > 38 then log_line = log_line:sub(1, 35) .. "..." end
        print_r(string.format("║ > %-38s ║", log_line))
    end
    print_r("╚══════════════════════════════════════════╝")
    io.flush()
end

-- Fungsi sederhana untuk mengambil nilai dari string JSON (tanpa library eksternal)
function get_json_value(json_str, key)
    -- Mencari pola "key":"value"
    local pattern = '"' .. key .. '"%s*:%s*"(.-)"'
    local value = json_str:match(pattern)
    if not value then
        -- Mencari pola "key":123 (angka)
        pattern = '"' .. key .. '"%s*:%s*(%d+)'
        value = json_str:match(pattern)
    end
    return value
end

-- Fungsi update status dan log
function update_ui(status, message, taskId)
    if status then dashboard_state.status = status end
    if taskId then dashboard_state.taskId = taskId end
    if message then
        -- Cegah spam log: Jangan tambah jika pesan sama dengan log terakhir (mengabaikan timestamp)
        local last_msg = logs[1] and logs[1]:sub(10) or "" -- Ambil pesan tanpa jam
        if last_msg ~= " " .. message then
            table.insert(logs, 1, os.date("%H:%M:%S") .. " " .. message)
            if #logs > 10 then table.remove(logs) end
        end
    end
    draw_dashboard()
end

function solve_captcha(blob_data)
    update_ui("CREATING", "Mengirim tugas ke YesCaptcha...")
    
    -- 1. Create Task
    -- Kita menyusun JSON string secara manual
    -- Menambahkan funcaptchaApiJSSubdomain yang sering dibutuhkan Roblox agar token valid
    local extra_data = ""
    if blob_data then
        extra_data = ',"data":"' .. blob_data .. '"'
    end
    
    local json_data = string.format('{"clientKey":"%s","task":{"type":"FunCaptchaTaskProxyless","websiteURL":"%s","websiteKey":"%s","funcaptchaApiJSSubdomain":"https://roblox-api.arkoselabs.com"%s}}', CLIENT_KEY, WEBSITE_URL, WEBSITE_KEY, extra_data)
    -- Escape tanda kutip ganda untuk shell command
    json_data = json_data:gsub('"', '\\"')
    
    -- Menggunakan CURL untuk request POST
    local cmd_create = 'curl -s -X POST "https://api.yescaptcha.com/createTask" -H "Content-Type: application/json" -d "' .. json_data .. '"'
    
    local handle = io.popen(cmd_create)
    local result = handle:read("*a")
    handle:close()
    
    local taskId = get_json_value(result, "taskId")
    
    if not taskId then
        update_ui("FAILED", "Gagal create task: " .. tostring(result))
        return nil
    end
    
    update_ui("POLLING", "Task dibuat, menunggu hasil...", taskId)
    
    -- 2. Polling Result (Looping cek hasil)
    for i = 1, 20 do
        os.execute("sleep 3") -- Tunggu 3 detik
        
        local json_poll = string.format('{"clientKey":"%s","taskId":"%s"}', CLIENT_KEY, taskId)
        json_poll = json_poll:gsub('"', '\\"')
        
        local cmd_poll = 'curl -s -X POST "https://api.yescaptcha.com/getTaskResult" -H "Content-Type: application/json" -d "' .. json_poll .. '"'
        
        local p_handle = io.popen(cmd_poll)
        local p_result = p_handle:read("*a")
        p_handle:close()
        
        local status = get_json_value(p_result, "status")
        
        if status == "ready" then
            local token = get_json_value(p_result, "token")
            update_ui("SOLVED", "Token berhasil didapatkan!")
            -- Otomatis salin token ke clipboard (membutuhkan paket termux-api)
            os.execute("termux-clipboard-set " .. token)
            return token
        end
        
        update_ui(nil, "Status: " .. tostring(status))
    end
    
    update_ui("TIMEOUT", "Waktu habis (Timeout)")
    return nil
end

-- Fungsi untuk mendeteksi keberadaan CAPTCHA (Simulasi)
function check_captcha_status()
    while true do
        -- 1. Ambil daftar paket terinstall yang mengandung com.roblox
        local handle = io.popen("su -c 'pm list packages | grep com.roblox'")
        local result = handle:read("*a")
        handle:close()
        
        local instances_data = {}
        local captcha_detected = false
        local found_blob = nil
        
        if result then
            for line in result:gmatch("[^\r\n]+") do
                local pkg_name = line:gsub("package:", ""):gsub("%s+", "")
                local status_text = "Belum Dibuka"
                
                -- Cek apakah proses berjalan untuk paket ini
                local h_pid = io.popen(string.format("su -c 'pidof %s'", pkg_name))
                local pid_res = h_pid:read("*a")
                h_pid:close()
                
                local pid = pid_res and pid_res:match("%d+")
                
                if pid then
                    status_text = "Sedang Dibuka"
                    
                    -- Cek logcat untuk PID ini
                    local cmd_log = string.format("su -c 'logcat -d -t 1000 | grep \"%s\"'", pid)
                    local h_log = io.popen(cmd_log)
                    local logs_pid = h_log:read("*a") or ""
                    h_log:close()
                    
                    local lower_logs = logs_pid:lower()
                    
                    if lower_logs:match("verifying") or lower_logs:match("challenge") or lower_logs:match("security") then
                        status_text = "Captcha Menunggu"
                    elseif lower_logs:match("arkose") or lower_logs:match("funcaptcha") or lower_logs:match("blob") then
                        status_text = "Terdeteksi Captcha"
                        captcha_detected = true
                        
                        -- Coba ekstrak blob data secara otomatis dari log
                        -- Mencari pola "data":"..." atau escaped \"data\":\"...\"
                        local temp_blob = logs_pid:match('"data":"([^"]+)"')
                        if not temp_blob then temp_blob = logs_pid:match('\\"data\\":\\"([^"]+)\\"') end
                        
                        -- Blob valid biasanya panjang (>50 karakter)
                        if temp_blob and #temp_blob > 50 then
                            found_blob = temp_blob
                        end
                    elseif lower_logs:match("joining") then
                        status_text = "Online Masuk Map"
                    elseif lower_logs:match("login") or lower_logs:match("webview") then
                        status_text = "Tidak Masuk Captcha"
                    end
                end
                
                table.insert(instances_data, {name = pkg_name, status = status_text})
            end
        end
        
        -- Urutkan berdasarkan nama paket
        table.sort(instances_data, function(a, b) return a.name < b.name end)
        
        dashboard_state.instances = instances_data
        
        if captcha_detected then
            update_ui("DETECTED", "Captcha ditemukan! Memulai bypass...")
            return found_blob or true
        else
            update_ui("MONITORING", "Memindai " .. #instances_data .. " paket...")
        end
        
        os.execute("sleep 2")
    end
end

-- Jalankan fungsi
local status_result = check_captcha_status()
if status_result then
    local blob_input = nil
    if type(status_result) == "string" then
        blob_input = status_result
        print("\n[INFO] Blob data berhasil diambil otomatis!")
    end
    
    local token_hasil = solve_captcha(blob_input)
    if token_hasil then
        print("\nToken Final:\n" .. token_hasil)
    else
        print("\nGagal mendapatkan token.")
    end
end
