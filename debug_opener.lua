--[[ 
    DVN DEBUG OPENER v5 (UI VERSION)
    Mencoba menekan tombol angka 3 dan menampilkan hasil di UI.
]]

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_DEBUG_UI"
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
Title.Text = "DVN DEBUG CONSOLE"
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

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 100, 0, 30)
CopyBtn.Position = UDim2.new(1, -135, 0, 0)
CopyBtn.Text = "COPY LOGS"
CopyBtn.TextColor3 = Color3.new(1, 1, 1)
CopyBtn.BackgroundColor3 = Color3.new(0, 0.5, 0)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 14
CopyBtn.Parent = Frame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll

local FullLog = ""

local function Log(text)
    FullLog = FullLog .. text .. "\n"
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = Scroll
    Scroll.CanvasPosition = Vector2.new(0, 99999)
end

CopyBtn.MouseButton1Click:Connect(function()
    setclipboard(FullLog)
    CopyBtn.Text = "COPIED!"
    task.wait(1)
    CopyBtn.Text = "COPY LOGS"
end)

Log("🚀 DVN KEYBOARD DEBUG STARTED")

-- LOGIC
task.spawn(function()
    local function ScanItems()
        local found = {}
        for _, v in pairs(PlayerGui:GetDescendants()) do
            if v:IsA("TextLabel") and (v.Name == "ItemName" or v.Name == "FishName") then
                if v.Text ~= "" and v.Text ~= "Item Name" and v.Text ~= "Fish Name" then
                    table.insert(found, v.Text .. " | Path: " .. v:GetFullName())
                end
            end
        end
        return found
    end

    Log("⌨️ Menekan Tombol '3'...")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)

    Log("⏳ Menunggu UI muncul (3 detik)...")
    task.wait(3)

    local items = ScanItems()
    if #items > 0 then
        Log("✅ BERHASIL! Ditemukan " .. #items .. " item:")
        for _, msg in ipairs(items) do
            Log("   > " .. msg)
        end
    else
        Log("❌ Tidak ada item terdeteksi.")
        Log("Pastikan tombol 3 benar-benar membuka tas ikan.")
    end
end)
