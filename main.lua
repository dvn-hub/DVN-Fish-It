--[[ 
    DVN HUB - FULL FINAL VERSION
    FIXED:
    - Info & Teleport content not showing
    - Dropdown resize breaking scroll
    - Minimize & Drag errors
    - Enum TextXAlignment fixed
    - Stable CanvasSize handling
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_HUB_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if LocalPlayer.PlayerGui:FindFirstChild(ScreenGui.Name) then
    LocalPlayer.PlayerGui[ScreenGui.Name]:Destroy()
end
ScreenGui.Parent = LocalPlayer.PlayerGui

-- CONFIG
local DEFAULT_SIZE = UDim2.new(0, 520, 0, 320)
local MINIMIZED_SIZE = UDim2.new(0, 520, 0, 35)

local MAIN_BG_COLOR = Color3.fromRGB(18,18,18)
local LINE_COLOR = Color3.fromRGB(255,255,255)
local TEXT_ACTIVE = Color3.fromRGB(255,255,255)
local TEXT_INACTIVE = Color3.fromRGB(120,120,120)
local ELEMENT_BG = Color3.fromRGB(35,35,35)

-- MAIN FRAME
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = UDim2.new(0.5,0,0.4,0)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = MAIN_BG_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0,6)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = LINE_COLOR
MainStroke.Thickness = 1
MainStroke.Transparency = 0.85

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1,0,0,35)
Header.BackgroundTransparency = 1
Header.Active = true

local Title = Instance.new("TextLabel", Header)
Title.Text = "DVN HUB | v0.1"
Title.Position = UDim2.new(0,15,0,0)
Title.Size = UDim2.new(1,-60,1,0)
Title.BackgroundTransparency = 1
Title.TextColor3 = TEXT_ACTIVE
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0,35,1,0)
MinBtn.Position = UDim2.new(1,-35,0,0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = TEXT_ACTIVE
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 22

-- BODY
local Body = Instance.new("Frame", MainFrame)
Body.Position = UDim2.new(0,0,0,35)
Body.Size = UDim2.new(1,0,1,-35)
Body.BackgroundTransparency = 1

-- SIDEBAR
local Sidebar = Instance.new("Frame", Body)
Sidebar.Size = UDim2.new(0.28,0,1,0)
Sidebar.BackgroundTransparency = 1

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0,2)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- CONTENT
local Content = Instance.new("Frame", Body)
Content.Position = UDim2.new(0.28,0,0,0)
Content.Size = UDim2.new(0.72,0,1,0)
Content.BackgroundTransparency = 1

-- TABS
local Tabs = {"Info","Fishing","Shop","Trade","Teleport","Quest","Config","Misc"}
local TabFrames = {}
local TabButtons = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", Content)
    Page.Name = name
    Page.Size = UDim2.new(1,-14,1,-10)
    Page.Position = UDim2.new(0,7,0,5)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.Visible = false

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0,6)

    -- 🔥 FULL FIX: manual CanvasSize update
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
    end)

    return Page
end

local function SwitchTab(name)
    for n,f in pairs(TabFrames) do
        f.Visible = (n==name)
    end
    for n,b in pairs(TabButtons) do
        b.TextColor3 = (n==name) and TEXT_ACTIVE or TEXT_INACTIVE
    end
end

for i,tab in ipairs(Tabs) do
    TabFrames[tab] = CreatePage(tab)

    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1,-20,0,32)
    Btn.Text = "   "..tab
    Btn.BackgroundTransparency = 1
    Btn.TextColor3 = TEXT_INACTIVE
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.MouseButton1Click:Connect(function()
        SwitchTab(tab)
    end)
    TabButtons[tab] = Btn
end

-- HELPERS
local function Section(parent,text)
    local L = Instance.new("TextLabel", parent)
    L.Text = text:upper()
    L.Size = UDim2.new(1,0,0,28)
    L.BackgroundTransparency = 1
    L.TextColor3 = LINE_COLOR
    L.TextTransparency = 0.4
    L.Font = Enum.Font.GothamBold
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
end

local function Button(parent,text,cb)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1,0,0,38)
    B.BackgroundColor3 = ELEMENT_BG
    B.Text = text
    B.TextColor3 = TEXT_ACTIVE
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    Instance.new("UICorner",B).CornerRadius = UDim.new(0,6)
    B.MouseButton1Click:Connect(function()
        pcall(cb)
    end)
end

-- CONTENT EXAMPLE
Section(TabFrames.Info,"Information")
local Info = Instance.new("TextLabel", TabFrames.Info)
Info.Size = UDim2.new(1,0,0,100)
Info.BackgroundTransparency = 1
Info.TextWrapped = true
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextSize = 12
Info.Font = Enum.Font.Gotham
Info.TextColor3 = TEXT_INACTIVE
Info.Text = "Thank you for using DVN Script.\nUse responsibly."

Section(TabFrames.Teleport,"Travel")
Button(TabFrames.Teleport,"Teleport (TEST)",function()
    print("Teleport clicked")
end)

-- MINIMIZE
local isMinimized = false
local lastSize = DEFAULT_SIZE
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    TweenService:Create(MainFrame,TweenInfo.new(0.3,Enum.EasingStyle.Quart),{
        Size = isMinimized and MINIMIZED_SIZE or lastSize
    }):Play()
    MinBtn.Text = isMinimized and "+" or "-"
end)

-- DRAG
local dragging = false
local dragStart
local startPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = MainFrame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + d.X,
            startPos.Y.Scale,
            startPos.Y.Offset + d.Y
        )
    end
end)

-- INIT
SwitchTab("Info")
print("UI DVN FULL FINAL LOADED ✅")
