--[[ 
    DVN HUB - MINIMALIST & FIXED VERSION
    Updates:
    - FIXED: Menu Bleeding (Text tembus saat minimize)
    - FIXED: Visibility (Font lebih tebal/Bold)
    - STYLE: Minimalist Components (Ukuran lebih kecil & rapi)
    - FEATURE: Teleport Logic Template Ready
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. SETUP GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_HUB_FIXED"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DVN_HUB_FIXED") then
    LocalPlayer.PlayerGui.DVN_HUB_FIXED:Destroy()
end
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- KONFIGURASI TAMPILAN (WARNA & UKURAN)
local DEFAULT_SIZE = UDim2.new(0, 500, 0, 300) -- Ukuran standar
local MIN_SIZE = Vector2.new(380, 240)
local MINIMIZED_SIZE = UDim2.new(0, 500, 0, 32) -- Tinggi saat minimize

-- Palette Warna Gelap Minimalis
local MAIN_BG = Color3.fromRGB(15, 15, 15)       -- Background Utama Gelap
local ELEMENT_BG = Color3.fromRGB(30, 30, 30)    -- Background Tombol
local ACCENT_COLOR = Color3.fromRGB(255, 255, 255) -- Warna Garis/Aksen
local TEXT_COLOR = Color3.fromRGB(240, 240, 240) -- Warna Text Terang
local TEXT_DIM = Color3.fromRGB(120, 120, 120)   -- Warna Text Mati

-- 2. MAIN FRAME (WADAH UTAMA)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = MAIN_BG
MainFrame.BackgroundTransparency = 0.05 -- Sedikit transparan tapi tetap gelap agar tulisan terbaca
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true -- PENTING: Mencegah text tembus keluar kotak
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ACCENT_COLOR
MainStroke.Transparency = 0.8
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- 3. HEADER (BAGIAN ATAS)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32) -- Lebih tipis
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "DVN HUB"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = TEXT_COLOR
Title.Font = Enum.Font.GothamBold -- Ganti Font jadi Bold agar jelas
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 32, 1, 0)
MinBtn.Position = UDim2.new(1, -32, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = TEXT_COLOR
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = ACCENT_COLOR
HeaderLine.BackgroundTransparency = 0.8
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

-- 4. BODY & CONTENT CONTAINER
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, 0, 1, -32)
Body.Position = UDim2.new(0, 0, 0, 32)
Body.BackgroundTransparency = 1
Body.ClipsDescendants = true
Body.Parent = MainFrame

-- Sidebar (Menu Kiri)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0.28, 0, 1, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Body

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 2)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.Parent = Sidebar

local SepLine = Instance.new("Frame") -- Garis Pemisah Vertikal
SepLine.Size = UDim2.new(0, 1, 1, 0)
SepLine.Position = UDim2.new(0.28, 0, 0, 0)
SepLine.BackgroundColor3 = ACCENT_COLOR
SepLine.BackgroundTransparency = 0.8
SepLine.BorderSizePixel = 0
SepLine.Parent = Body

-- Content (Isi Kanan)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(0.72, 0, 1, 0)
Content.Position = UDim2.new(0.28, 0, 0, 0)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Body

-- 5. TAB SYSTEM
local Tabs = {"Info", "Fishing", "Shop", "Teleport", "Config", "Misc"}
local TabFrames = {}
local TabButtons = {}

local function SwitchTab(activeName)
    for name, frame in pairs(TabFrames) do
        frame.Visible = (name == activeName)
    end
    for name, btn in pairs(TabButtons) do
        if name == activeName then
            btn.TextColor3 = TEXT_COLOR
            btn.BackgroundTransparency = 0.9 -- Highlight aktif tipis
        else
            btn.TextColor3 = TEXT_DIM
            btn.BackgroundTransparency = 1
        end
    end
end

for i, name in ipairs(Tabs) do
    -- Buat Halaman
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = ACCENT_COLOR
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.Parent = Content
    
    local PLayout = Instance.new("UIListLayout")
    PLayout.Padding = UDim.new(0, 5) -- Jarak antar item lebih rapat (Minimalis)
    PLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PLayout.Parent = Page
    
    local PPad = Instance.new("UIPadding")
    PPad.PaddingTop = UDim.new(0, 5)
    PPad.PaddingLeft = UDim.new(0, 5)
    PPad.PaddingRight = UDim.new(0, 5)
    PPad.Parent = Page
    
    TabFrames[name] = Page
    
    -- Buat Tombol Sidebar
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.LayoutOrder = i
    Btn.Size = UDim2.new(1, -16, 0, 28) -- Tinggi tombol dikecilkan (32 -> 28)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.Font = Enum.Font.GothamBold -- Font Bold
    Btn.TextSize = 12
    Btn.TextColor3 = TEXT_DIM
    Btn.Parent = Sidebar
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = Btn
end

-- 6. HELPER COMPONENTS (Minimalist Size)
local function GetOrder(parent) return #parent:GetChildren() end

function CreateSection(parent, text)
    local Lab = Instance.new("TextLabel")
    Lab.LayoutOrder = GetOrder(parent)
    Lab.Text = text:upper()
    Lab.Size = UDim2.new(1, 0, 0, 24) -- Section lebih tipis
    Lab.BackgroundTransparency = 1
    Lab.TextColor3 = ACCENT_COLOR
    Lab.TextTransparency = 0.4
    Lab.Font = Enum.Font.GothamBold
    Lab.TextSize = 10
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.Parent = parent
end

function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.LayoutOrder = GetOrder(parent)
    Btn.Size = UDim2.new(1, 0, 0, 30) -- Tinggi tombol 30px (Minimalis)
    Btn.BackgroundColor3 = ELEMENT_BG
    Btn.Text = text
    Btn.TextColor3 = TEXT_COLOR
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.LayoutOrder = GetOrder(parent)
    Frame.Size = UDim2.new(1, 0, 0, 30) -- Tinggi Toggle 30px
    Frame.BackgroundColor3 = ELEMENT_BG
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame
    
    local Lab = Instance.new("TextLabel")
    Lab.Text = text
    Lab.Size = UDim2.new(0.7, 0, 1, 0)
    Lab.Position = UDim2.new(0, 10, 0, 0)
    Lab.BackgroundTransparency = 1
    Lab.TextColor3 = TEXT_COLOR
    Lab.Font = Enum.Font.GothamBold
    Lab.TextSize = 12
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 36, 0, 18) -- Switch lebih kecil
    ToggleBtn.Position = UDim2.new(1, -42, 0.5, -9)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = ToggleBtn
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Dot.Parent = ToggleBtn
    
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(1, 0)
    DCorner.Parent = Dot
    
    local on = false
    ToggleBtn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
        pcall(callback, on)
    end)
end

function CreateDropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.LayoutOrder = GetOrder(parent)
    Frame.Size = UDim2.new(1, 0, 0, 30) -- Tinggi Dropdown Awal 30px
    Frame.BackgroundColor3 = ELEMENT_BG
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame
    
    local Lab = Instance.new("TextLabel")
    Lab.Text = text
    Lab.Size = UDim2.new(0.6, 0, 0, 30)
    Lab.Position = UDim2.new(0, 10, 0, 0)
    Lab.BackgroundTransparency = 1
    Lab.TextColor3 = TEXT_COLOR
    Lab.Font = Enum.Font.GothamBold
    Lab.TextSize = 12
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.Parent = Frame
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Text = "▼"
    Arrow.Size = UDim2.new(0, 30, 0, 30)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.TextColor3 = TEXT_DIM
    Arrow.TextSize = 10
    Arrow.Parent = Frame
    
    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 0, 0, 30)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = Frame
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -4, 0, 0)
    Container.Position = UDim2.new(0, 2, 0, 32)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 2)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Container
    
    local isOpen = false
    for _, opt in ipairs(options) do
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(1, 0, 0, 24) -- Tinggi pilihan item 24px
        B.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        B.Text = opt
        B.TextColor3 = TEXT_DIM
        B.Font = Enum.Font.Gotham
        B.TextSize = 11
        B.Parent = Container
        
        local C = Instance.new("UICorner")
        C.CornerRadius = UDim.new(0, 3)
        C.Parent = B
        
        B.MouseButton1Click:Connect(function()
            Lab.Text = text .. ": " .. opt
            Lab.TextColor3 = Color3.fromRGB(255, 255, 255)
            pcall(callback, opt)
            isOpen = false
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
        end)
    end
    
    Trigger.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local h = (#options * 26) + 4
        if isOpen then
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30 + h)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
        end
    end)
end

-- 7. LOGIC & ISI KONTEN

-- [INFO]
CreateSection(TabFrames["Info"], "About")
local InfoTxt = Instance.new("TextLabel")
InfoTxt.Text = "Thank you for using DVN Hub!\nThis tool is created to enhance your experience and make your gameplay easier.\n\nUse this tool at your own risk. DVN Team is not responsible for any misuse or consequences.\n\nBrought to you with care by DVN.\nEnjoy and have fun!"
InfoTxt.Size = UDim2.new(1, 0, 0, 140)
InfoTxt.BackgroundTransparency = 1
InfoTxt.TextColor3 = TEXT_DIM
InfoTxt.Font = Enum.Font.GothamBold
InfoTxt.TextSize = 11
InfoTxt.TextXAlignment = Enum.TextXAlignment.Left
InfoTxt.Parent = TabFrames["Info"]

CreateSection(TabFrames["Info"], "Official Discord DVN!")
local DiscordTxt = Instance.new("TextLabel")
DiscordTxt.Text = "Join Us!"
DiscordTxt.Size = UDim2.new(1, 0, 0, 20)
DiscordTxt.BackgroundTransparency = 1
DiscordTxt.TextColor3 = TEXT_DIM
DiscordTxt.Font = Enum.Font.Gotham
DiscordTxt.TextSize = 10
DiscordTxt.TextXAlignment = Enum.TextXAlignment.Left
DiscordTxt.Parent = TabFrames["Info"]

-- [FISHING]
CreateSection(TabFrames["Fishing"], "Main")
CreateToggle(TabFrames["Fishing"], "Auto Fish", function(v) end)

-- [SHOP]
CreateSection(TabFrames["Shop"], "Shop")
CreateToggle(TabFrames["Shop"], "Auto Buy Bait", function(v) end)

-- [TELEPORT LOGIC - ISI KOORDINAT DI SINI]
CreateSection(TabFrames["Teleport"], "Waypoints")

-- 1. ISI NAMA TEMPAT DI SINI
local PlaceNames = {
    "Christmas Island", 
    "Fisherman Island", 
    "Ocean",
    "Kohana",
    "Coral Reefs"
}

-- 2. ISI KOORDINAT (X, Y, Z) DI SINI
local Locations = {
    ["Christmas Island"] = Vector3.new(0, 0, 0), -- Ganti 0,0,0 dengan koordinat asli
    ["Fisherman Island"] = Vector3.new(100, 50, 100),
    ["Ocean"]            = Vector3.new(-50, 10, -50),
    ["Kohana"]           = Vector3.new(200, 50, 200),
    ["Coral Reefs"]      = Vector3.new(300, 10, 300)
}

local selectedPlace = nil

CreateDropdown(TabFrames["Teleport"], "Select Location", PlaceNames, function(val)
    selectedPlace = val
end)

CreateButton(TabFrames["Teleport"], "Teleport Now", function()
    if selectedPlace and Locations[selectedPlace] then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Locations[selectedPlace])
        end
    else
        print("Koordinat belum diisi!")
    end
end)

-- 8. WINDOW LOGIC (MINIMIZE & RESIZE FIXED)

-- Minimize Logic
local isMin = false
local lastSize = DEFAULT_SIZE

MinBtn.MouseButton1Click:Connect(function()
    if isMin then
        -- Expand
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = lastSize}):Play()
        Body.Visible = true -- PENTING: Munculkan isi kembali
        MinBtn.Text = "-"
    else
        -- Minimize
        lastSize = MainFrame.Size
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = MINIMIZED_SIZE}):Play()
        Body.Visible = false -- PENTING: Sembunyikan isi agar tidak tembus
        MinBtn.Text = "+"
    end
    isMin = not isMin
end)

-- Dragging Logic
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Resize Logic
local ResizeBtn = Instance.new("ImageButton")
ResizeBtn.Size = UDim2.new(0, 15, 0, 15)
ResizeBtn.Position = UDim2.new(1, -15, 1, -15)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Image = "rbxassetid://3599185146" -- Icon Segitiga
ResizeBtn.ImageTransparency = 0.5
ResizeBtn.ImageColor3 = ACCENT_COLOR
ResizeBtn.Parent = MainFrame

local resizing, resizeStart, startSize
ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStart = input.Position
        startSize = MainFrame.AbsoluteSize
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - resizeStart
        local newX = math.max(MIN_SIZE.X, startSize.X + delta.X)
        local newY = math.max(MIN_SIZE.Y, startSize.Y + delta.Y)
        MainFrame.Size = UDim2.new(0, newX, 0, newY)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

SwitchTab("Info")