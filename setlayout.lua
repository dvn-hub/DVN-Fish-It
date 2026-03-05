-- =============================================================================
-- UNIVERSAL ROBLOX CLONE GRID MANAGER (LUA)
-- VERSION 4.1 - Dynamic Portrait 1 Column
-- =============================================================================

-- ================= CONFIG =================
local ACTIVITY = "com.roblox.client.startup.ActivitySplash"
local OFFSET_TOP = 80
local STABILIZE_DELAY = 30

-- ================= COLORS =================
local C = {
  CYAN   = "\27[0;36m",
  GREEN  = "\27[0;32m",
  YELLOW = "\27[1;33m",
  RED    = "\27[0;31m",
  NC     = "\27[0m"
}

local function log(tag, color, msg)
  print(string.format("%s[%s] [%s]%s %s", color, os.date("%H:%M:%S"), tag, C.NC, msg))
end

-- ================= UTIL =================
local function exec(cmd)
  local f = io.popen(cmd)
  local out = f:read("*a")
  f:close()
  return out:gsub("%s+$", "")
end

local function split(str)
  local t = {}
  for s in str:gmatch("%S+") do table.insert(t, s) end
  return t
end

-- ================= SCAN PACKAGES =================
log("＊", C.CYAN, "Memindai semua package com.roblox.* ...")

local pkgs_raw = exec("pm list packages | grep 'com.roblox.' | cut -d: -f2 | sort")
if pkgs_raw == "" then
  log("!", C.RED, "Tidak ada package Roblox ditemukan!")
  os.exit(1)
end

local ALL = split(pkgs_raw)

print(C.YELLOW .. "Ditemukan " .. #ALL .. " Package:" .. C.NC)
print("---------------------------------------------------")
for i, p in ipairs(ALL) do
  print(string.format(" [%2d] %s", i, p))
end
print("---------------------------------------------------")
io.write(C.CYAN .. "Pilih nomor (1,3,5) atau 'all': " .. C.NC)

local input = io.read()

if not input or input == "" then
  input = "all"
else
  input = input:lower()
end

local SELECTED = {}

if input == "all" then
  SELECTED = ALL
else
  for n in input:gmatch("%d+") do
    n = tonumber(n)
    if ALL[n] then table.insert(SELECTED, ALL[n]) end
  end
end

if #SELECTED == 0 then
  log("!", C.RED, "Pilihan kosong.")
  os.exit(1)
end

local COUNT = #SELECTED

-- ================= SCREEN & GRID =================
local wm = exec("su -c '/system/bin/wm size'")

local size = wm:match("Physical size:%s*(%d+x%d+)")
          or wm:match("Override size:%s*(%d+x%d+)")
          or wm:match("(%d+x%d+)")

if not size then
  error("Gagal membaca resolusi layar (wm size)")
end

local W, H = size:match("(%d+)x(%d+)")
W, H = tonumber(W), tonumber(H)
W, H = tonumber(W), tonumber(H)

local COLS, ROWS
if W < H then
  log("＊", C.CYAN, "Mode Terdeteksi: PORTRAIT")
  if COUNT <= 5 then
    COLS, ROWS = 1, COUNT
  elseif COUNT <= 10 then
    COLS = 2
    ROWS = math.ceil(COUNT / COLS)
  else
    log("!", C.RED, "Mode Portrait maksimal 10 akun.")
    os.exit(1)
  end
else
  log("＊", C.CYAN, "Mode Terdeteksi: LANDSCAPE")
  if COUNT <= 4 then COLS = 2
  elseif COUNT <= 9 then COLS = 3
  else COLS = 4 end
  ROWS = math.ceil(COUNT / COLS)
end

local GW = math.floor(W / COLS)
local GH = math.floor((H - OFFSET_TOP) / ROWS)

log("＊", C.CYAN, string.format("Grid: %dx%d | Stabilizer: %ds", COLS, ROWS, STABILIZE_DELAY))

-- ================= EXECUTION =================
for idx, PKG in ipairs(SELECTED) do
  local row = math.floor((idx - 1) / COLS)
  local col = (idx - 1) % COLS

  local L = col * GW
  local T = row * GH + OFFSET_TOP
  local R = L + GW
  local B = T + GH

  local PREF = "/data/data/" .. PKG .. "/shared_prefs/" .. PKG .. "_preferences.xml"

  print(string.format("%s[%d/%d]%s Setup Layout -> %s",
    C.GREEN, idx, COUNT, C.NC, PKG))

  exec("su -c 'am force-stop " .. PKG .. "'")
  exec("su -c 'chmod 666 " .. PREF .. "'")

  exec(string.format(
    "su -c \"sed -i 's/name=\\\"app_cloner_current_window_left\\\" value=\\\"[^\\\"]*\\\"/name=\\\"app_cloner_current_window_left\\\" value=\\\"%d\\\"/' %s\"",
    L, PREF))

  exec(string.format(
    "su -c \"sed -i 's/name=\\\"app_cloner_current_window_top\\\" value=\\\"[^\\\"]*\\\"/name=\\\"app_cloner_current_window_top\\\" value=\\\"%d\\\"/' %s\"",
    T, PREF))

  exec(string.format(
    "su -c \"sed -i 's/name=\\\"app_cloner_current_window_right\\\" value=\\\"[^\\\"]*\\\"/name=\\\"app_cloner_current_window_right\\\" value=\\\"%d\\\"/' %s\"",
    R, PREF))

  exec(string.format(
    "su -c \"sed -i 's/name=\\\"app_cloner_current_window_bottom\\\" value=\\\"[^\\\"]*\\\"/name=\\\"app_cloner_current_window_bottom\\\" value=\\\"%d\\\"/' %s\"",
    B, PREF))

  exec("su -c 'chmod 444 " .. PREF .. "'")
  exec("su -c 'am start -n " .. PKG .. "/" .. ACTIVITY .. "'")

  os.execute("sleep " .. STABILIZE_DELAY)
  exec("su -c 'am force-stop " .. PKG .. "'")

  log("＊", C.CYAN, "Posisi terkunci. Menutup " .. PKG)
end

print("---------------------------------------------------")
log("+", C.GREEN, "PROSES SELESAI! Grid telah dikunci.")
