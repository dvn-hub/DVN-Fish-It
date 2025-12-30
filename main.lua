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
local DEFAULT_SIZE = UDim2.new(0, 550, 0, 350) -- Ukuran awal dalam Pixel biar enak diresize
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
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false 
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = LINE_COLOR
MainStroke.Transparency = 0.6
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- DRAG BAR (HOME INDICATOR)
local DragBar = Instance.new("Frame")
DragBar.Name = "DragBar"
DragBar.Size = UDim2.new(0, 140, 0, 4)
DragBar.Position = UDim2.new(0.5, 0, 1, 12)
DragBar.AnchorPoint = Vector2.new(0.5, 1)
DragBar.BackgroundColor3 = LINE_COLOR
DragBar.BackgroundTransparency = 0.3
DragBar.BorderSizePixel = 0
DragBar.Active = true
DragBar.Parent = MainFrame
local DragBarCorner = Instance.new("UICorner")
DragBarCorner.CornerRadius = UDim.new(1, 0)
DragBarCorner.Parent = DragBar

-- DragBar Animation
DragBar.MouseEnter:Connect(function()
    TweenService:Create(DragBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 160, 0, 6), BackgroundTransparency = 0.2}):Play()
end)
DragBar.MouseLeave:Connect(function()
    TweenService:Create(DragBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 140, 0, 4), BackgroundTransparency = 0.5}):Play()
end)

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
HeaderLine.BackgroundTransparency = 0.6
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
VerticalLine.BackgroundTransparency = 0.6
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

-- 5. RESIZE HANDLE (POJOK KANAN BAWAH)
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
ResizeHandle.Position = UDim2.new(1, 0, 1, 0)
ResizeHandle.AnchorPoint = Vector2.new(1, 1)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "◢" -- Simbol pojok
ResizeHandle.TextColor3 = TEXT_INACTIVE
ResizeHandle.TextSize = 14
ResizeHandle.Font = Enum.Font.Gotham
ResizeHandle.Parent = MainFrame

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
            btn.BackgroundTransparency = 1
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
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = LINE_COLOR
    BtnStroke.Transparency = 0.6
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
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
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = LINE_COLOR
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = ELEMENT_BG
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = LINE_COLOR
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Frame
    
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

function CreateParagraph(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(1, 0, 0, 0)
    Label.AutomaticSize = Enum.AutomaticSize.Y
    Label.BackgroundTransparency = 1
    Label.TextColor3 = TEXT_ACTIVE
    Label.TextTransparency = 0.2
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.Parent = parent
    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 10)
    Pad.PaddingRight = UDim.new(0, 10)
    Pad.PaddingTop = UDim.new(0, 5)
    Pad.PaddingBottom = UDim.new(0, 5)
    Pad.Parent = Label
end

-- 8. ISI FITUR SCRIPT
-- [INFO]
CreateSection(TabFrames["Info"], "Information")
CreateParagraph(TabFrames["Info"], "Thank you for using DVN Hub!\nThis tool is created to enhance your experience and make your gameplay easier.\n\nUse this tool at your own risk. DVN Team is not responsible for any misuse or consequences.\n\nBrought to you with care by DVN.\nEnjoy and have fun!")
CreateSection(TabFrames["Info"], "Official Discord DVN! Join Us!")
CreateButton(TabFrames["Info"], "Copy Discord Link", function()
    setclipboard("https://discord.gg/LINK_DISCORD_DISINI") -- Ganti link nanti
end)

-- [FISHING]
CreateSection(TabFrames["Fishing"], "Feature")
CreateToggle(TabFrames["Fishing"], "Auto Fish", function(v) end)

-- [SHOP]
CreateSection(TabFrames["Shop"], "Items")
CreateToggle(TabFrames["Shop"], "Auto Buy", function(v) end)

-- [TRADE]
CreateSection(TabFrames["Trade"], "System")

-- [TELEPORT]
CreateSection(TabFrames["Teleport"], "Maps")

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
        ResizeHandle.Visible = true
    else
        -- Minimize
        storedSize = MainFrame.Size -- Simpan ukuran terakhir sebelum ditutup
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, storedSize.X.Offset, 0, 35)}):Play()
        MinBtn.Text = "+"
        ResizeHandle.Visible = false
    end
    isMinimized = not isMinimized
end)

-- B. Dragging (Header Only)
local dragging, dragInput, dragStart, startPos

local function StartDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end

local function UpdateDragInput(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end

Header.InputBegan:Connect(StartDrag)
Header.InputChanged:Connect(UpdateDragInput)
DragBar.InputBegan:Connect(StartDrag)
DragBar.InputChanged:Connect(UpdateDragInput)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- C. Resizing Logic
local resizing = false
local resizeStart = Vector2.new()
local startSize = Vector2.new()

ResizeHandle.InputBegan:Connect(function(input)
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
        
        -- Matikan animasi tween saat resize agar responsif
        MainFrame.Size = UDim2.new(0, newX, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        -- Update stored size buat minimize logic
        if not isMinimized then
            storedSize = MainFrame.Size
        end
    end
end)

print("DVN HUB LOADED")