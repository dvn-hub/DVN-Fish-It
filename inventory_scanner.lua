--[[ 
    DVN INVENTORY SCANNER v1.0
    Add-on for DVN Hub.
    Features:
    - Scans Backpack & Character for items (Fish/Tools).
    - Groups duplicates (xCount).
    - DVN UI Style (Matches Main Hub).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
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

-- WEATHER FRAME (HIDDEN)
local WeatherFrame = Instance.new("Frame")
WeatherFrame.Size = UDim2.new(1, -20, 1, -80)
WeatherFrame.Position = UDim2.new(0, 10, 0, 40)
WeatherFrame.BackgroundTransparency = 1
WeatherFrame.Visible = false
WeatherFrame.Parent = MainFrame

local WeatherListLayout = Instance.new("UIListLayout")
WeatherListLayout.Padding = UDim.new(0, 5)
WeatherListLayout.SortOrder = Enum.SortOrder.LayoutOrder
WeatherListLayout.Parent = WeatherFrame

local WeatherDB = {
    {Name = "None", Id = 0},
    {Name = "Clear", Id = 1},
    {Name = "Rain", Id = 2},
    {Name = "Fog", Id = 3},
    {Name = "Wind", Id = 4},
    {Name = "Storm", Id = 5},
    {Name = "Snow", Id = 6},
    {Name = "Cloudy", Id = 7},
    {Name = "Aurora", Id = 8}
}

local Slots = {1, 1, 1} -- Default indices (None)
local AutoBuyActive = false

local function CreateCycleButton(idx)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = ELEMENT_BG
    Btn.TextColor3 = TEXT_COLOR
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Text = "Slot " .. idx .. ": " .. WeatherDB[Slots[idx]].Name
    Btn.Parent = WeatherFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    Btn.MouseButton1Click:Connect(function()
        Slots[idx] = Slots[idx] + 1
        if Slots[idx] > #WeatherDB then Slots[idx] = 1 end
        Btn.Text = "Slot " .. idx .. ": " .. WeatherDB[Slots[idx]].Name
    end)
end

CreateCycleButton(1)
CreateCycleButton(2)
CreateCycleButton(3)

local ToggleAutoBtn = Instance.new("TextButton")
ToggleAutoBtn.Size = UDim2.new(1, 0, 0, 40)
ToggleAutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleAutoBtn.TextColor3 = ACCENT_COLOR
ToggleAutoBtn.Font = Enum.Font.GothamBold
ToggleAutoBtn.TextSize = 14
ToggleAutoBtn.Text = "AUTO BUY: OFF"
ToggleAutoBtn.Parent = WeatherFrame
Instance.new("UICorner", ToggleAutoBtn).CornerRadius = UDim.new(0, 4)

ToggleAutoBtn.MouseButton1Click:Connect(function()
    AutoBuyActive = not AutoBuyActive
    if AutoBuyActive then
        ToggleAutoBtn.Text = "AUTO BUY: ON"
        ToggleAutoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleAutoBtn.Text = "AUTO BUY: OFF"
        ToggleAutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- FOOTER (ACTIONS)
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, -20, 0, 30)
Footer.Position = UDim2.new(0, 10, 1, -40)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.32, 0, 1, 0)
RefreshBtn.Position = UDim2.new(0, 0, 0, 0)
RefreshBtn.BackgroundColor3 = ELEMENT_BG
RefreshBtn.Text = "REFRESH"
RefreshBtn.TextColor3 = TEXT_COLOR
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 10
RefreshBtn.Parent = Footer
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local WeatherBtn = Instance.new("TextButton")
WeatherBtn.Size = UDim2.new(0.32, 0, 1, 0)
WeatherBtn.Position = UDim2.new(0.34, 0, 0, 0)
WeatherBtn.BackgroundColor3 = ELEMENT_BG
WeatherBtn.Text = "WEATHER"
WeatherBtn.TextColor3 = TEXT_COLOR
WeatherBtn.Font = Enum.Font.GothamBold
WeatherBtn.TextSize = 10
WeatherBtn.Parent = Footer
Instance.new("UICorner", WeatherBtn).CornerRadius = UDim.new(0, 4)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.32, 0, 1, 0)
CopyBtn.Position = UDim2.new(0.68, 0, 0, 0)
CopyBtn.BackgroundColor3 = ELEMENT_BG
CopyBtn.Text = "COPY"
CopyBtn.TextColor3 = TEXT_COLOR
CopyBtn.TextSize = 10
CopyBtn.Parent = Footer
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)

WeatherBtn.MouseButton1Click:Connect(function()
    local isWeather = WeatherFrame.Visible
    WeatherFrame.Visible = not isWeather
    Content.Visible = isWeather
    Title.Text = isWeather and "DVN INVENTORY" or "WEATHER AUTO BUY"
end)

-- LOGIC FUNCTIONS
local function ClickGui(obj)
    if not obj then return end
    
    -- [DEBUG] Visualisasi Klik (Kotak Merah)
    local debugBox = Instance.new("Frame")
    debugBox.Name = "DebugClickBox"
    debugBox.Size = UDim2.new(0, obj.AbsoluteSize.X, 0, obj.AbsoluteSize.Y)
    debugBox.Position = UDim2.new(0, obj.AbsolutePosition.X, 0, obj.AbsolutePosition.Y)
    debugBox.BackgroundTransparency = 1
    debugBox.Parent = ScreenGui
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 4
    stroke.Parent = debugBox
    game:GetService("Debris"):AddItem(debugBox, 2)

    -- [FIX] Gunakan GuiInset untuk koordinat akurat (Otomatis deteksi ukuran TopBar)
    local inset = GuiService:GetGuiInset()
    local center = obj.AbsolutePosition + (obj.AbsoluteSize / 2) + inset
    VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
    
    -- Method 2: Direct Event Firing (Fallback for Executors)
    -- Jika klik virtual gagal, kita coba paksa trigger event-nya menggunakan getconnections
    if typeof(getconnections) == "function" then
        local btn = obj
        if not btn:IsA("GuiButton") then
            btn = obj:FindFirstChildWhichIsA("GuiButton", true)
        end
        
        if btn then
            for _, event in ipairs({"MouseButton1Click", "MouseButton1Down", "Activated"}) do
                for _, conn in pairs(getconnections(btn[event])) do
                    conn:Fire()
                end
            end
        end
    end
end

local function GetItems()
    local items = {}
    
    local function add(name, qty)
        qty = qty or 1
        if name and name ~= "" then
            items[name] = (items[name] or 0) + qty
        end
    end

    -- [DISABLED] 1. Scan Standard Backpack (Tools) - Agar Rod tidak masuk list
    -- local function scanTools(loc)
    --     for _, v in pairs(loc:GetChildren()) do
    --         if v:IsA("Tool") then
    --             add(v.Name)
    --         end
    --     end
    -- end
    -- if LocalPlayer:FindFirstChild("Backpack") then scanTools(LocalPlayer.Backpack) end
    -- if LocalPlayer.Character then scanTools(LocalPlayer.Character) end
    
    -- 2. Scan PlayerGui UI (Targeted Scan - Only Fish Inventory & Backpack)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        -- Helper: Cek apakah object benar-benar terlihat di layar (Recursive check)
        local function isVisible(obj)
            local curr = obj
            while curr and curr ~= pGui do
                if curr:IsA("GuiObject") and not curr.Visible then return false end
                if curr:IsA("ScreenGui") and not curr.Enabled then return false end
                curr = curr.Parent
            end
            return true
        end

        -- Helper to extract name from a Tile
        local function scanTile(tile)
            -- [FILTER] Hanya ambil item yang Visible (Aktif di layar)
            if not isVisible(tile) then return end
            
            -- Cek ItemName langsung (Inventory Style)
            local nameLabel = tile:FindFirstChild("ItemName")
            
            -- Cek ItemName dalam Tags (Backpack Style)
            if not nameLabel then
                local inner = tile:FindFirstChild("Inner")
                if inner then
                    local tags = inner:FindFirstChild("Tags")
                    if tags then nameLabel = tags:FindFirstChild("ItemName") end
                end
            end

            if nameLabel and nameLabel:IsA("TextLabel") and nameLabel.Text ~= "" and nameLabel.Text ~= "Item Name" and nameLabel.Text ~= "Fish Name" then
                local fullName = nameLabel.Text
                
                -- Cek Variant (Sibling dari ItemName atau di dalam Variant folder)
                -- Struktur Inventory: Tile -> Variant -> ItemName
                local variant = tile:FindFirstChild("Variant")
                if variant then
                    local varLabel = variant:FindFirstChild("ItemName")
                    if varLabel and varLabel:IsA("TextLabel") and varLabel.Text ~= "" then
                        fullName = varLabel.Text .. " " .. fullName
                    end
                end
                
                add(fullName)
            end
        end

        -- Target A: Main Inventory
        -- Path: PlayerGui.Inventory.Main.Content (Scan Recursive untuk menangkap semua halaman)
        local inv = pGui:FindFirstChild("Inventory")
        if inv and inv:FindFirstChild("Main") and inv.Main:FindFirstChild("Content") then
            -- Scan seluruh Content agar tidak peduli nama halamannya (Pages/Fish/dll)
            for _, v in pairs(inv.Main.Content:GetDescendants()) do
                if v.Name == "ItemName" and v.Parent then
                    -- v.Parent adalah Tile atau Tags, kita scan tile-nya
                    scanTile(v.Parent) -- [FIX] v.Parent adalah Tile
                end
            end
        end

        -- [DISABLED] Target B: Backpack/Hotbar - Agar Rod tidak masuk list
        -- local backpack = pGui:FindFirstChild("Backpack")
        -- if backpack and backpack:FindFirstChild("Display") then
        --     for _, tile in pairs(backpack.Display:GetChildren()) do
        --         scanTile(tile)
        --     end
        -- end
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
    
    Title.Text = "SCANNING..."
    
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local invGui = pGui and pGui:FindFirstChild("Inventory")
    local invMain = invGui and invGui:FindFirstChild("Main")
    local wasVisible = invMain and invMain.Visible
    
    local data = {}

    if wasVisible then
        -- Jika sudah terbuka, langsung scan
        data = GetItems()
    else
        -- Jika tertutup, lakukan prosedur Buka -> Scan -> Tutup
        Title.Text = "OPENING BAG..."
        
        -- Hitung baseline item (noise) sebelum buka
        local initialData = GetItems()
        local initialCount = 0
        for _ in pairs(initialData) do initialCount = initialCount + 1 end
        
        -- 1. Coba Klik Tombol Tas (Prioritas Utama agar script game jalan)
        local invBtn = nil
        if pGui and pGui:FindFirstChild("Backpack") and pGui.Backpack:FindFirstChild("Display") then
            invBtn = pGui.Backpack.Display:FindFirstChild("Inventory")
        end
        if invBtn then ClickGui(invBtn) end
        task.wait(0.5) -- Tunggu animasi game
        
        -- 2. Force Open jika masih tertutup (Backup)
        if invGui then
            if not invGui.Enabled then invGui.Enabled = true end
            if invMain and not invMain.Visible then invMain.Visible = true end
        end
        
        task.wait(0.2) -- Tunggu UI render sebentar
        
        local fishTab = invMain 
            and invMain:FindFirstChild("Top") 
            and invMain.Top:FindFirstChild("Options") 
            and invMain.Top.Options:FindFirstChild("Fish")
            
        if fishTab then 
            ClickGui(fishTab)
            task.wait(0.2) -- Tunggu tab berpindah
        end

        -- Tunggu sampai item bertambah (Max 2.5 detik)
        for i = 1, 25 do
            task.wait(0.1)
            data = GetItems() -- Update data terus menerus
            local check = data
            local c = 0
            for _ in pairs(check) do c = c + 1 end
            -- Jika item bertambah (karena scan sekarang spesifik, penambahan 1 pun berarti berhasil load)
            if c > initialCount then break end 
        end
        
        -- Pastikan data terisi terakhir kali
        if next(data) == nil then data = GetItems() end

        -- [RESTORE] Tutup kembali (Force Close)
        if invMain then
            invMain.Visible = false
        end
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
    CopyBtn.Text = "COPY"
end)

-- AUTO BUY LOOP
task.spawn(function()
    local function GetRemote(name)
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if packages then
            for _, v in pairs(packages:GetDescendants()) do
                if v:IsA("RemoteFunction") and (v.Name == name or v.Name == "RF/" .. name) then
                    return v
                end
            end
        end
        return nil
    end

    while ScreenGui.Parent do
        if AutoBuyActive then
            for i = 1, 3 do
                if not AutoBuyActive then break end
                local weatherIdx = Slots[i]
                local weatherData = WeatherDB[weatherIdx]
                
                if weatherData.Id > 0 then
                    local remote = GetRemote("PurchaseWeather")
                    if remote then
                        pcall(function() remote:InvokeServer(weatherData.Id, 1) end)
                    end
                    task.wait(1.5)
                end
            end
        end
        task.wait(0.5)
    end
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