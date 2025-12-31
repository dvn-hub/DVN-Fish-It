--[[ 
    DVN INVENTORY SCANNER v1.0
    Add-on for DVN Hub.
    Features:
    - Scans Backpack & Character for items (Fish/Tools).
    - Groups duplicates (xCount).
    - DVN UI Style (Matches Main Hub).
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")

-- GUI PARENT SAFE
local GUI_PARENT = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- CLEANUP OLD GUI
if GUI_PARENT:FindFirstChild("DVN_INVENTORY") then
    GUI_PARENT.DVN_INVENTORY:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_INVENTORY"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10001 -- Above Main
ScreenGui.Parent = GUI_PARENT
ScreenGui.ResetOnSpawn = false

-- UI CONSTANTS
local WIDTH = 280
local HEIGHT = 350
local MAIN_BG = Color3.fromRGB(15, 15, 15)
local ELEMENT_BG = Color3.fromRGB(30, 30, 30)
local ACCENT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local TEXT_DIM = Color3.fromRGB(120, 120, 120)

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
MainFrame.Position = UDim2.new(0.85, -WIDTH, 0.5, -HEIGHT/2) -- Default to Right Side
MainFrame.BackgroundColor3 = MAIN_BG
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ACCENT_COLOR
MainStroke.Transparency = 0.5
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "DVN INVENTORY"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = TEXT_COLOR
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 32, 1, 0)
CloseBtn.Position = UDim2.new(1, -32, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- CONTENT LIST
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -80)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = ACCENT_COLOR
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Content

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

-- FOOTER (ACTIONS)
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, -20, 0, 30)
Footer.Position = UDim2.new(0, 10, 1, -40)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.48, 0, 1, 0)
RefreshBtn.BackgroundColor3 = ELEMENT_BG
RefreshBtn.Text = "REFRESH"
RefreshBtn.TextColor3 = TEXT_COLOR
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 12
RefreshBtn.Parent = Footer
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.48, 0, 1, 0)
CopyBtn.Position = UDim2.new(0.52, 0, 0, 0)
CopyBtn.BackgroundColor3 = ELEMENT_BG
CopyBtn.Text = "COPY LIST"
CopyBtn.TextColor3 = TEXT_COLOR
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 12
CopyBtn.Parent = Footer
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)

-- LOGIC FUNCTIONS
local function GetItems()
    local items = {}
    
    local function add(name, qty)
        qty = qty or 1
        if name and name ~= "" then
            items[name] = (items[name] or 0) + qty
        end
    end
    
    -- Helper: Get Full Name with Variant (e.g. "Shiny Catfish")
    local function getFullFishName(tile)
        local nameLabel = tile:FindFirstChild("ItemName")
        if not nameLabel or not nameLabel:IsA("TextLabel") then return nil end
        
        local name = nameLabel.Text
        if name == "Item Name" or name == "Fish Name" or name == "" then return nil end

        -- Check for Variant (Sibling or Child)
        local variant = tile:FindFirstChild("Variant")
        if variant then
            local varLabel = variant:FindFirstChild("ItemName")
            if varLabel and varLabel:IsA("TextLabel") and varLabel.Text ~= "" then
                name = varLabel.Text .. " " .. name
            end
        end
        return name
    end

    -- 1. Scan Standard Backpack (Tools)
    local function scanTools(loc)
        for _, v in pairs(loc:GetChildren()) do
            if v:IsA("Tool") then
                add(v.Name)
            end
        end
    end
    
    if LocalPlayer:FindFirstChild("Backpack") then scanTools(LocalPlayer.Backpack) end
    if LocalPlayer.Character then scanTools(LocalPlayer.Character) end
    
    -- 2. Scan PlayerGui UI (Specific Paths from Debug)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        -- Path A: Main Inventory
        -- Path: PlayerGui.Inventory.Main.Content.Pages.Inventory.Tile
        local inv = pGui:FindFirstChild("Inventory")
        if inv and inv:FindFirstChild("Main") and inv.Main:FindFirstChild("Content") then
            local pages = inv.Main.Content:FindFirstChild("Pages")
            if pages and pages:FindFirstChild("Inventory") then
                for _, tile in pairs(pages.Inventory:GetChildren()) do
                    local fullName = getFullFishName(tile)
                    if fullName then add(fullName) end
                end
            end
        end

        -- Path B: Backpack Hotbar
        -- Path: PlayerGui.Backpack.Display.Tile.Inner.Tags.ItemName
        local backpack = pGui:FindFirstChild("Backpack")
        if backpack and backpack:FindFirstChild("Display") then
            for _, tile in pairs(backpack.Display:GetChildren()) do
                local inner = tile:FindFirstChild("Inner")
                if inner and inner:FindFirstChild("Tags") then
                    local nameLabel = inner.Tags:FindFirstChild("ItemName")
                    if nameLabel and nameLabel:IsA("TextLabel") and nameLabel.Text ~= "" then
                        add(nameLabel.Text)
                    end
                end
            end
        end
    end

    -- 3. Scan Custom Inventory (Folder inside Player)
    -- Mencari folder umum: "Inventory", "FishInventory", "Bag", "Fish"
    local customFolders = {"Inventory", "FishInventory", "Bag", "Fish"}
    for _, folderName in ipairs(customFolders) do
        local folder = LocalPlayer:FindFirstChild(folderName)
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                -- Cek StringValue (Slot -> Nama Ikan)
                if v:IsA("StringValue") then
                    add(v.Value)
                -- Cek IntValue (Nama Ikan -> Jumlah)
                elseif v:IsA("IntValue") then
                    add(v.Name, v.Value)
                -- Cek Object biasa (Model/Folder/Part)
                elseif not v:IsA("Script") and not v:IsA("LocalScript") then
                    add(v.Name)
                end
            end
        end
    end

    return items
end

local function UpdateList()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    -- [AUTO-OPEN] Use Key 3 to open inventory
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local wasVisible = false
    
    -- Check if inventory is already visible
    if pGui and pGui:FindFirstChild("Inventory") and pGui.Inventory:FindFirstChild("Main") then
        wasVisible = pGui.Inventory.Main.Visible
    end
    
    if not wasVisible then
        Title.Text = "SCANNING..."
        -- Press 3
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
        
        -- Wait for load (Smart Wait)
        for i = 1, 30 do -- Max 3 seconds
            local tempItems = GetItems()
            local count = 0
            for _ in pairs(tempItems) do count = count + 1 end
            if count > 2 then -- Found items (more than just rod)
                task.wait(0.2) -- Small buffer
                break 
            end
            task.wait(0.1)
        end
    end

    local data = GetItems()
    
    -- [RESTORE] Close inventory if we opened it
    if not wasVisible then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
    end

    local sortedNames = {}
    for name, _ in pairs(data) do table.insert(sortedNames, name) end
    table.sort(sortedNames)
    
    local totalCount = 0
    
    for _, name in ipairs(sortedNames) do
        local count = data[name]
        totalCount = totalCount + count
        
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 24)
        ItemFrame.BackgroundColor3 = ELEMENT_BG
        ItemFrame.BackgroundTransparency = 0.5
        ItemFrame.Parent = Scroll
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)
        
        local NameLab = Instance.new("TextLabel")
        NameLab.Size = UDim2.new(0.7, 0, 1, 0)
        NameLab.Position = UDim2.new(0, 8, 0, 0)
        NameLab.BackgroundTransparency = 1
        NameLab.Text = name
        NameLab.TextColor3 = TEXT_COLOR
        NameLab.Font = Enum.Font.Gotham
        NameLab.TextSize = 12
        NameLab.TextXAlignment = Enum.TextXAlignment.Left
        NameLab.Parent = ItemFrame
        
        local CountLab = Instance.new("TextLabel")
        CountLab.Size = UDim2.new(0.3, -8, 1, 0)
        CountLab.Position = UDim2.new(0.7, 0, 0, 0)
        CountLab.BackgroundTransparency = 1
        CountLab.Text = "x" .. count
        CountLab.TextColor3 = ACCENT_COLOR
        CountLab.Font = Enum.Font.GothamBold
        CountLab.TextSize = 12
        CountLab.TextXAlignment = Enum.TextXAlignment.Right
        CountLab.Parent = ItemFrame
    end
    
    Title.Text = "DVN INVENTORY (" .. totalCount .. ")"
end

RefreshBtn.MouseButton1Click:Connect(UpdateList)

CopyBtn.MouseButton1Click:Connect(function()
    local data = GetItems()
    local str = "DVN INVENTORY LIST:\n"
    for name, count in pairs(data) do
        str = str .. "- " .. name .. " x" .. count .. "\n"
    end
    setclipboard(str)
    CopyBtn.Text = "COPIED!"
    task.wait(1)
    CopyBtn.Text = "COPY LIST"
end)

-- DRAGGING LOGIC
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- INIT
UpdateList()
print("DVN INVENTORY LOADED")