
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DVN_DEBUG_UI"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.8, 0, 0.6, 0)
Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.2
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 0, 30)
Title.Text = "DVN DEBUG SCANNER RESULTS"
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
CopyBtn.Text = "COPY ALL"
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

-- LOG FUNCTION
local function Log(text, color)
    FullLog = FullLog .. text .. "\n"
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = Scroll
end

CopyBtn.MouseButton1Click:Connect(function()
    setclipboard(FullLog)
    CopyBtn.Text = "COPIED!"
    task.wait(1)
    CopyBtn.Text = "COPY ALL"
end)

Log("Scanning started...", Color3.new(1, 1, 0))

-- SCAN LOGIC
local KEYWORDS = {"fish", "bass", "trout", "carp", "shark", "legend", "common", "mythic", "item"}

local function scanHierarchy(root, depth)
    if depth > 8 then return end
    
    for _, v in pairs(root:GetChildren()) do
        local found = false
        local name = v.Name:lower()
        local textContent = ""

        for _, key in ipairs(KEYWORDS) do
            if name:find(key) then found = true break end
        end
        
        if not found and (v:IsA("TextLabel") or v:IsA("TextButton")) then
            textContent = v.Text:lower()
            for _, key in ipairs(KEYWORDS) do
                if textContent:find(key) then found = true break end
            end
        end

        if found then
            Log("FOUND: " .. v.Name, Color3.new(0, 1, 0))
            Log("Path: " .. v:GetFullName(), Color3.new(0.8, 0.8, 0.8))
            if textContent ~= "" then
                Log("Text: " .. v.Text, Color3.new(0.5, 0.5, 1))
            end
            Log("--------------------------------", Color3.new(1, 1, 1))
        end
        
        scanHierarchy(v, depth + 1)
    end
end

-- EXECUTE SCAN
task.spawn(function()
    wait(1)
    Log("--- Scanning PlayerGui ---", Color3.new(1, 0.5, 0))
    if LocalPlayer:FindFirstChild("PlayerGui") then
        scanHierarchy(LocalPlayer.PlayerGui, 1)
    end
    
    Log("--- Scanning Backpack ---", Color3.new(1, 0.5, 0))
    if LocalPlayer:FindFirstChild("Backpack") then
        scanHierarchy(LocalPlayer.Backpack, 1)
    end
    
    Log("--- Scanning Player Folder ---", Color3.new(1, 0.5, 0))
    for _, c in pairs(LocalPlayer:GetChildren()) do
        if c:IsA("Folder") then
            scanHierarchy(c, 1)
        end
    end
    Log("DONE.", Color3.new(1, 1, 0))
end)
