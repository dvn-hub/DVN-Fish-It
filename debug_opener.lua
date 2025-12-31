--[[ 
    DVN DEBUG OPENER v7 (BUTTON HUNTER)
    Mencari tombol Inventory secara otomatis di seluruh UI
    dan mencoba mengkliknya satu per satu.
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
Title.Text = "DVN BUTTON HUNTER"
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
    
    -- 2. Cari Tombol Inventory/Bag/Backpack
    Log("🔍 Mencari tombol 'Inventory' / 'Bag'...", Color3.new(1, 0.5, 0))
    
    local buttons = {}
    for _, v in pairs(PlayerGui:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
            local name = v.Name:lower()
            local text = (v:IsA("TextButton") and v.Text:lower()) or ""
            
            -- Filter tombol yang relevan
            if name == "inventory" or name == "bag" or name == "backpack" or text == "inventory" or text == "bag" then
                table.insert(buttons, v)
            end
        end
    end
    
    if #buttons == 0 then
        Log("❌ Tidak ditemukan tombol Inventory.", Color3.new(1, 0, 0))
    else
        Log("✅ Ditemukan " .. #buttons .. " tombol potensial.", Color3.new(0, 1, 0))
        
        for i, btn in ipairs(buttons) do
            Log("Testing Tombol #" .. i .. ": " .. btn.Name, Color3.new(0, 1, 1))
            Log("Path: " .. btn:GetFullName())
            
            ClickObject(btn)
            task.wait(1.5)
            
            local current = ScanItems()
            Log("📊 Item sekarang: " .. current)
            
            if current > initial then
                Log("🎉 SUKSES! Tombol ini membuka tas.", Color3.new(0, 1, 0))
                Log("SIMPAN PATH INI!", Color3.new(1, 1, 0))
                break
            end
        end
    end
    
    Log("🏁 Debug Selesai.", Color3.new(1, 1, 1))
end)
