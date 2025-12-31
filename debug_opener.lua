--[[ 
    DVN DEBUG OPENER v6 (AUTO-OPEN TEST)
    Script ini akan mencoba membuka inventory secara otomatis
    dan mendeteksi kapan daftar ikan muncul.
]]

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_DEBUG_OPENER"
-- Coba masukkan ke CoreGui agar aman, fallback ke PlayerGui
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.8, 0, 0.6, 0)
Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.1
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 0, 30)
Title.Text = "DVN INVENTORY DEBUG"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 0, 0)
CloseBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
CloseBtn.Parent = Frame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll

local function Log(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = Scroll
    Scroll.CanvasPosition = Vector2.new(0, 99999)
end

-- LOGIC
task.spawn(function()
    Log("🚀 MEMULAI DEBUG SEQUENCE...", Color3.new(1, 1, 0))
    
    local function ScanItems()
        local count = 0
        for _, v in pairs(PlayerGui:GetDescendants()) do
            if v:IsA("TextLabel") and (v.Name == "ItemName" or v.Name == "FishName") then
                if v.Text ~= "" and v.Text ~= "Item Name" and v.Text ~= "Fish Name" then
                    count = count + 1
                end
            end
        end
        return count
    end

    local function ClickObject(obj)
        if not obj then return end
        Log("🖱️ Klik UI: " .. obj.Name, Color3.new(0, 1, 1))
        local center = obj.AbsolutePosition + (obj.AbsoluteSize / 2)
        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
    end

    -- 1. Cek Kondisi Awal
    local initial = ScanItems()
    Log("📊 Item Terlihat Awal: " .. initial)
    
    if initial > 5 then
        Log("✅ Item sudah terlihat! Tidak perlu aksi.", Color3.new(0, 1, 0))
        return
    end
    
    -- 2. Coba Tombol '3'
    Log("⌨️ Mencoba Tombol Keyboard '3'...", Color3.new(1, 0.5, 0))
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)

    Log("⏳ Menunggu 2 detik...")
    task.wait(2)

    local afterKey = ScanItems()
    Log("📊 Item setelah Tombol '3': " .. afterKey)
    
    if afterKey > initial then
        Log("✅ Tombol '3' Berhasil!", Color3.new(0, 1, 0))
        return
    end
    
    -- 3. Coba Klik Tombol Inventory di Layar
    Log("🔍 Mencari Tombol Inventory di Layar...", Color3.new(1, 0.5, 0))
    local invBtn = nil
    
    -- Path spesifik game ini (Backpack -> Display -> Inventory)
    if PlayerGui:FindFirstChild("Backpack") and PlayerGui.Backpack:FindFirstChild("Display") then
        invBtn = PlayerGui.Backpack.Display:FindFirstChild("Inventory")
    end
    
    if invBtn then
        ClickObject(invBtn)
        Log("⏳ Menunggu 2 detik...")
        task.wait(2)
        
        local afterClick = ScanItems()
        Log("📊 Item setelah Klik UI: " .. afterClick)
        
        if afterClick > initial then
            Log("✅ Klik UI Berhasil!", Color3.new(0, 1, 0))
            return
        else
            Log("❌ Klik UI gagal memuat item.")
        end
    else
        Log("❌ Tombol Inventory tidak ditemukan di PlayerGui.")
    end
    
    -- 4. Coba Cari Tab "Fish" (Jika tas terbuka tapi kosong)
    Log("🔍 Mencari Tab 'Fish'...", Color3.new(1, 0.5, 0))
    local fishTab = nil
    local invGui = PlayerGui:FindFirstChild("Inventory")
    if invGui then
        for _, v in pairs(invGui:GetDescendants()) do
            if (v:IsA("TextButton") or v:IsA("ImageButton")) and (v.Name == "Fish" or (v:IsA("TextButton") and v.Text == "Fish")) then
                fishTab = v
                break
            end
        end
    end
    
    if fishTab then
        ClickObject(fishTab)
        task.wait(1)
        Log("📊 Item setelah Klik Tab Fish: " .. ScanItems())
    else
        Log("❌ Tab Fish tidak ditemukan.")
    end
    
    Log("🏁 Debug Selesai.", Color3.new(1, 1, 1))
end)
