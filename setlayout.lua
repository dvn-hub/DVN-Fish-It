-- ==============================================================================
-- SCRIPT: UNIVERSAL ROBLOX CLONE GRID MANAGER (LUA PORT)
-- VERSION: 4.1 (Dynamic Portrait 1-Column Update)
-- ==============================================================================

local ACTIVITY = "com.roblox.client.startup.ActivitySplash"
local OFFSET_TOP = 80
local STABILIZE_DELAY = 5

-- UI COLORS
local CYAN = "\27[0;36m"
local GREEN = "\27[0;32m"
local YELLOW = "\27[1;33m"
local RED = "\27[0;31m"
local NC = "\27[0m"

-- HELPER FUNCTIONS
local function log_status(msg) print(string.format("%s[*]%s %s", CYAN, NC, msg)) end
local function log_success(msg) print(string.format("%s[+]%s %s", GREEN, NC, msg)) end
local function log_error(msg) print(string.format("%s[!]%s %s", RED, NC, msg)) end

local function exec(cmd)
    local handle = io.popen(cmd)
    if not handle then return "" end
    local result = handle:read("*a")
    handle:close()
    return result or ""
end

local function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

-- 1. SCANNING PACKAGES
log_status("Memindai semua package com.roblox.* ...")
local raw_list = exec("pm list packages | grep 'com.roblox.*' | cut -d':' -f2 | sort")
local all_clones = {}
for line in raw_list:gmatch("[^\r\n]+") do
    table.insert(all_clones, line)
end

if #all_clones == 0 then
    log_error("Tidak ada package Roblox ditemukan!")
    os.exit(1)
end

-- 2. SELECTION MENU
print(string.format("%sDitemukan %d Package:%s", YELLOW, #all_clones, NC))
print("---------------------------------------------------")
for i, pkg in ipairs(all_clones) do
    print(string.format("  [%2d] %s", i, pkg))
end
print("---------------------------------------------------")
io.write(string.format("%sPilih nomor (contoh: 1,3,4) atau 'all': %s", CYAN, NC))
local user_input = io.read() or ""

local selected_packages = {}
if user_input == "all" then
    selected_packages = all_clones
else
    for num in user_input:gmatch("%d+") do
        local idx = tonumber(num)
        if all_clones[idx] then
            table.insert(selected_packages, all_clones[idx])
        end
    end
end

if #selected_packages == 0 then
    log_error("Pilihan kosong.")
    os.exit(1)
end

-- 3. SMART ORIENTATION & GRID LOGIC
local wm_out = exec("/system/bin/wm size | awk '{print $3}'")
local w_str, h_str = wm_out:match("(%d+)x(%d+)")
local W, H = tonumber(w_str), tonumber(h_str)

if not W or not H then
    log_error("Gagal mendeteksi resolusi layar.")
    os.exit(1)
end

local count = #selected_packages
local COLS, ROWS
local SW, SH = W, H

if W < H then
    -- PORTRAIT
    log_status("Mode Terdeteksi: PORTRAIT")
    if count <= 5 then
        COLS = 1
        ROWS = count
    else
        COLS = 2
        ROWS = math.ceil(count / COLS)
        if count > 10 then
            log_error("Mode Portrait maksimal 10 akun (2x5).")
            print(string.format("%sGunakan mode LANDSCAPE untuk akun > 10!%s", YELLOW, NC))
            os.exit(1)
        end
    end
    if ROWS > 5 then ROWS = 5 end
else
    -- LANDSCAPE
    log_status("Mode Terdeteksi: LANDSCAPE")
    if count <= 4 then COLS = 2
    elseif count <= 9 then COLS = 3
    else COLS = 4 end
    ROWS = math.ceil(count / COLS)
end

local GW = math.floor(SW / COLS)
local GH = math.floor((SH - OFFSET_TOP) / ROWS)

log_status(string.format("Grid: %dx%d | Stabilizer: %ds", COLS, ROWS, STABILIZE_DELAY))

-- 4. EXECUTION
local function update_xml(pref_path, key, val)
    -- Construct sed command carefully to match shell script logic
    local pattern = string.format('name=\\"%s\\" value=\\"[^\\"]*\\"', key)
    local replacement = string.format('name=\\"%s\\" value=\\"%d\\"', key, val)
    local cmd = string.format("sed -i 's/%s/%s/g' %s", pattern, replacement, pref_path)
    os.execute(string.format("su -c \"%s\"", cmd))
end

for idx, pkg in ipairs(selected_packages) do
    local i = idx - 1 -- 0-based index for math
    local row = math.floor(i / COLS)
    local col = i % COLS
    
    local L = col * GW
    local T = (row * GH) + OFFSET_TOP
    local R = L + GW
    local B = T + GH
    
    local pref = string.format("/data/data/%s/shared_prefs/%s_preferences.xml", pkg, pkg)
    
    print(string.format("%s[%d/%d]%s Setup Layout -> %s", GREEN, idx, count, NC, pkg))
    
    os.execute(string.format("su -c 'am force-stop %s' > /dev/null 2>&1", pkg))
    os.execute(string.format("su -c 'chmod 666 %s' > /dev/null 2>&1", pref))
    
    update_xml(pref, "app_cloner_current_window_left", L)
    update_xml(pref, "app_cloner_current_window_top", T)
    update_xml(pref, "app_cloner_current_window_right", R)
    update_xml(pref, "app_cloner_current_window_bottom", B)
    
    os.execute(string.format("su -c 'chmod 444 %s' > /dev/null 2>&1", pref))
    os.execute(string.format("su -c 'am start --user 0 -n %s/%s' > /dev/null 2>&1", pkg, ACTIVITY))
    
    sleep(STABILIZE_DELAY)
    
    os.execute(string.format("su -c 'am force-stop %s' > /dev/null 2>&1", pkg))
    log_status(string.format("   Posisi terkunci. Menutup %s...", pkg))
end

print("---------------------------------------------------")
log_success("PROSES SELESAI! Grid telah dikunci.")
