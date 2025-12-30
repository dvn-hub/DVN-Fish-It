--[[ 
    DVN HUB - CUSTOM UI 
    Features: 
    - Resizable Window (Bottom Right)
    - Fixed Sidebar (No Scroll)
    - Sorted Menu 1-8
    - Bold Aesthetic
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 1. SETUP GUI DASAR
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_HUB_UI"
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DVN_HUB_UI") then
    LocalPlayer.PlayerGui.DVN_HUB_UI:Destroy()
end
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- KONFIGURASI TAMPILAN
local DEFAULT_SIZE = UDim2.new(0, 450, 0, 260) -- Ukuran aman untuk mobile
local MIN_SIZE = Vector2.new(400, 250) -- Ukuran terkecil
local MAIN_BG_COLOR = Color3.fromRGB(18, 18, 18)
local LINE_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_ACTIVE = Color3.fromRGB(255, 255, 255)
local TEXT_INACTIVE = Color3.fromRGB(100, 100, 100)
local ELEMENT_BG = Color3.fromRGB(35, 35, 35)

-- 2. MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = MAIN_BG_COLOR
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = LINE_COLOR
MainStroke.Transparency = 0.85
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- 3. HEADER
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "DVN HUB" -- JUDUL BARU
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = TEXT_ACTIVE
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 35, 1, 0)
MinBtn.Position = UDim2.new(1, -35, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = TEXT_ACTIVE
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 22
MinBtn.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = LINE_COLOR
HeaderLine.BackgroundTransparency = 0.85
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

-- 4. BODY CONTAINER
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, 0, 1, -35)
Body.Position = UDim2.new(0, 0, 0, 35)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

-- SIDEBAR (FIXED / NO SCROLL)
local Sidebar = Instance.new("Frame") -- Ganti jadi Frame biasa (Paten)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.28, 0, 1, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Body

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 2)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.Parent = Sidebar

local VerticalLine = Instance.new("Frame")
VerticalLine.Size = UDim2.new(0, 1, 1, 0)
VerticalLine.Position = UDim2.new(0.28, 0, 0, 0)
VerticalLine.BackgroundColor3 = LINE_COLOR
VerticalLine.BackgroundTransparency = 0.85
VerticalLine.BorderSizePixel = 0
VerticalLine.Parent = Body

-- CONTENT
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(0.72, 0, 1, 0)
Content.Position = UDim2.new(0.28, 0, 0, 0)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Body

-- 6. SISTEM MENU (Sorted 1-8)
local Tabs = {
    "Info", "Fishing", "Shop", "Trade", 
    "Teleport", "Quest", "Config", "Misc"
}

local TabFrames = {}
local TabButtons = {}

local function SwitchTab(activeName)
    for name, frame in pairs(TabFrames) do
        frame.Visible = (name == activeName)
    end
    for name, btn in pairs(TabButtons) do
        if name == activeName then
            btn.TextColor3 = TEXT_ACTIVE
            btn.BackgroundTransparency = 0.92
        else
            btn.TextColor3 = TEXT_INACTIVE
            btn.BackgroundTransparency = 1
        end
    end
end

for index, tabName in ipairs(Tabs) do
    -- Halaman Konten
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tabName
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = LINE_COLOR
    Page.Parent = Content
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page
    
    TabFrames[tabName] = Page
    
    -- Tombol Sidebar
    local Btn = Instance.new("TextButton")
    Btn.Name = tabName
    Btn.LayoutOrder = index
    Btn.Size = UDim2.new(1, -20, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 1
    Btn.Text = tabName
    Btn.TextColor3 = TEXT_INACTIVE
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = Sidebar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        SwitchTab(tabName)
    end)
    TabButtons[tabName] = Btn
end

SwitchTab("Info")

-- 7. HELPER FUNCTIONS
function CreateSection(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Text = text:upper()
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = LINE_COLOR
    Label.TextTransparency = 0.4
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 5)
    Pad.Parent = Label
end

function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = ELEMENT_BG
    Btn.Text = text
    Btn.TextColor3 = TEXT_ACTIVE
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = ELEMENT_BG
    Frame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = TEXT_ACTIVE
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Toggler = Instance.new("TextButton")
    Toggler.Size = UDim2.new(0, 40, 0, 20)
    Toggler.Position = UDim2.new(1, -50, 0.5, -10)
    Toggler.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Toggler.Text = ""
    Toggler.Parent = Frame
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = Toggler
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.Parent = Toggler
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = Circle
    
    local enabled = false
    Toggler.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(Toggler, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(Toggler, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
        pcall(callback, enabled)
    end)
end

function CreateDropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = ELEMENT_BG
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 0, 38)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = TEXT_ACTIVE
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Text = "▼"
    Arrow.Size = UDim2.new(0, 30, 0, 38)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.TextColor3 = TEXT_INACTIVE
    Arrow.TextSize = 12
    Arrow.Parent = Frame
    
    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 0, 0, 38)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = Frame
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 0)
    Container.Position = UDim2.new(0, 5, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 2)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Container
    
    local isOpen = false
    for _, option in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 25)
        OptBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        OptBtn.Text = option
        OptBtn.TextColor3 = TEXT_INACTIVE
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 12
        OptBtn.Parent = Container
        local OptCorner = Instance.new("UICorner")
        OptCorner.CornerRadius = UDim.new(0, 4)
        OptCorner.Parent = OptBtn
        
        OptBtn.MouseButton1Click:Connect(function()
            Label.Text = text .. ": " .. option
            Label.TextColor3 = Color3.fromRGB(0, 255, 150)
            pcall(callback, option)
            isOpen = false
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
        end)
    end
    
    Trigger.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local totalHeight = (#options * 27) + 5
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 38 + totalHeight)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
        else
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
        end
    end)
end

-- 8. ISI FITUR SCRIPT
-- [INFO]
CreateSection(TabFrames["Info"], "Information")
CreateButton(TabFrames["Info"], "Copy Discord", function() end)

-- [FISHING]
CreateSection(TabFrames["Fishing"], "Feature")
CreateToggle(TabFrames["Fishing"], "Auto Fish", function(v) end)

-- [SHOP]
CreateSection(TabFrames["Shop"], "Items")
CreateToggle(TabFrames["Shop"], "Auto Buy", function(v) end)

-- [TRADE]
CreateSection(TabFrames["Trade"], "System")

-- [TELEPORT]
local IslandCoords = {
    ["Christmas Island"] = Vector3.new(0,0,0),
    ["Christmas Cave"] = Vector3.new(0,0,0),
    ["Fisherman Island"] = Vector3.new(0,0,0),
    ["Ocean"] = Vector3.new(0,0,0),
    ["Kohana"] = Vector3.new(0,0,0),
    ["Kohana Volcano"] = Vector3.new(0,0,0),
    ["Coral Reefs"] = Vector3.new(0,0,0),
    ["Esotoric Depths"] = Vector3.new(0,0,0),
    ["Tropical Grove"] = Vector3.new(0,0,0),
    ["Crater Island"] = Vector3.new(0,0,0),
    ["Treasure Room"] = Vector3.new(0,0,0),
    ["Sisyphus Statue"] = Vector3.new(0,0,0),
    ["Ancient Jungle"] = Vector3.new(0,0,0),
    ["Sacred Temple"] = Vector3.new(0,0,0),
    ["Underground Cellar"] = Vector3.new(0,0,0),
    ["Ancient Ruin"] = Vector3.new(0,0,0)
}
local selectedLocation = nil

CreateDropdown(TabFrames["Teleport"], "Teleport Island", {
    "Christmas Island", "Christmas Cave", "Fisherman Island", "Ocean", 
    "Kohana", "Kohana Volcano", "Coral Reefs", "Esotoric Depths", 
    "Tropical Grove", "Crater Island", "Treasure Room", "Sisyphus Statue", 
    "Ancient Jungle", "Sacred Temple", "Underground Cellar", "Ancient Ruin"
}, function(val)
    selectedLocation = val
end)

CreateButton(TabFrames["Teleport"], "Teleport to Location", function()
    if selectedLocation and IslandCoords[selectedLocation] then
        local targetPos = IslandCoords[selectedLocation]
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        end
    end
end)

-- [QUEST]
CreateSection(TabFrames["Quest"], "Auto Quest")

-- [CONFIG]
CreateSection(TabFrames["Config"], "Settings")

-- [MISC]
CreateSection(TabFrames["Misc"], "Extra")
CreateButton(TabFrames["Misc"], "Rejoin", function() end)


-- 9. LOGIKA: DRAG, MINIMIZE, RESIZE

-- A. Minimize
local isMinimized = false
local storedSize = DEFAULT_SIZE
MinBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        -- Restore
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = storedSize}):Play()
        MinBtn.Text = "-"
    else
        -- Minimize
        storedSize = MainFrame.Size -- Simpan ukuran terakhir sebelum ditutup
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, storedSize.X.Offset, 0, 35)}):Play()
        MinBtn.Text = "+"
    end
    isMinimized = not isMinimized
end)

-- B. Dragging (Header Only)
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

print("DVN HUB LOADED")