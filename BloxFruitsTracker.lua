--====================================
-- BLOX FRUITS TRACKER | FULL TOOL FIX
-- MENU ON / OFF
--====================================

--=========== CONFIG ==================
getgenv().WEBHOOK_URL = "https://ptb.discord.com/api/webhooks/1462515851168321648/8nE25RbQ8xhgU99b-XMCHYcPW_TXhGMlIMwXjImJM7IKF8sO-iOTYvz4UkXzcwDzTWW1"
getgenv().SEND_INTERVAL = 180 -- 3 phút
getgenv().TRACKER_ENABLED = false

--=========== SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

--=========== REQUEST DETECT ==========
local requestFunc =
    (syn and syn.request)
    or http_request
    or request
    or (fluxus and fluxus.request)

if not requestFunc then
    warn("❌ Executor không hỗ trợ HTTP Request")
end

--=========== UPTIME ===================
local startTime = os.time()
local function formatTime(t)
    local h = math.floor(t / 3600)
    local m = math.floor((t % 3600) / 60)
    local s = t % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

--=========== FPS ======================
local fps, currentFPS = 0, 0
RunService.RenderStepped:Connect(function()
    fps += 1
end)

task.spawn(function()
    while task.wait(1) do
        currentFPS = fps
        fps = 0
    end
end)

--=========== PING =====================
local function getPing()
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

--=========== PLAYER DATA ==============
local function getPlayerData()
    local d = LP:WaitForChild("Data")
    return {
        Level = d.Level.Value,
        Beli = d.Beli.Value,
        Frag = d.Fragments.Value
    }
end

--=========== TOOL FIX: LEVI HEART STACK ============
local function getLeviHeartCount()
    local total = 0

    local function check(container)
        for _, tool in pairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("levi") and name:find("heart") then
                    for _,v in pairs(tool:GetChildren()) do
                        if v:IsA("IntValue") or v:IsA("NumberValue") then
                            total += v.Value
                            return
                        end
                    end
                    total += 1
                end
            end
        end
    end

    if LP:FindFirstChild("Backpack") then
        check(LP.Backpack)
    end

    if LP.Character then
        check(LP.Character)
    end

    return total
end

--=========== SCROLL CHECK =================
local function getScrolls()
    local mythic, legendary = 0, 0
    local inv = LP.Data:FindFirstChild("Inventory")
    if inv then
        for _,item in pairs(inv:GetChildren()) do
            local name = item.Name:lower()
            local v = item.Value or 1
            if name:find("mythic scroll") then mythic += v end
            if name:find("legendary scroll") then legendary += v end
        end
    end
    return mythic, legendary
end

--=========== BOSS CHECK =================
local function getBosses()
    local bosses = {}
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Name:lower():find("boss") then
            table.insert(bosses, v.Name)
        end
    end
    return (#bosses > 0 and table.concat(bosses, ", ")) or "None"
end

--=========== WEBHOOK ===================
local function sendWebhook()
    if not requestFunc or not getgenv().TRACKER_ENABLED then return end

    local p = getPlayerData()
    local heart = getLeviHeartCount()
    local mythic, legendary = getScrolls()

    local msg =
        "🛠️ **BLOX FRUITS TRACKER**\n" ..
        "👤 User: "..LP.Name.."\n\n" ..
        "🖥️ **Hệ Thống**\n" ..
        "🎮 FPS: "..currentFPS.."\n" ..
        "📶 Ping: "..math.floor(getPing()).." ms\n" ..
        "⏳ Treo: "..formatTime(os.time() - startTime).."\n\n" ..
        "👤 **Nhân Vật**\n" ..
        "⭐ Level: "..p.Level.."\n" ..
        "💵 Beli: $"..p.Beli.."\n" ..
        "🟣 Frag: "..p.Frag.."\n\n" ..
        "📦 **Kho Đồ**\n" ..
        "❤️ Levi Heart: x"..heart.."\n" ..
        "📜 Mythic Scroll: x"..mythic.."\n" ..
        "📘 Legendary Scroll: x"..legendary.."\n\n" ..
        "👹 Boss: "..getBosses().."\n" ..
        "⏱️ "..os.date("%H:%M:%S")

    requestFunc({
        Url = getgenv().WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({content = msg})
    })
end

--=========== SEND FIRST =================
task.spawn(function()
    task.wait(2)
    sendWebhook()
end)

--=========== LOOP SEND ==================
task.spawn(function()
    while task.wait(getgenv().SEND_INTERVAL) do
        sendWebhook()
    end
end)

--=========== AUTO REJOIN ================
LP.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(5)
        TeleportService:Teleport(game.PlaceId)
    end
end)

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
    if v.Name == "ErrorPrompt" then
        task.wait(5)
        TeleportService:Teleport(game.PlaceId)
    end
end)

--=========== MENU UI ===================
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local Status = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "BFTrackerUI"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Size = UDim2.fromOffset(220,140)
Frame.Position = UDim2.fromScale(0.05,0.4)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(20,20,20)
Title.Text = "🛠️ BF Tracker"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

Status.Parent = Frame
Status.Position = UDim2.fromOffset(0,35)
Status.Size = UDim2.new(1,0,0,30)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.TextSize = 14

ToggleBtn.Parent = Frame
ToggleBtn.Position = UDim2.fromOffset(20,75)
ToggleBtn.Size = UDim2.fromOffset(180,40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.TextColor3 = Color3.new(1,1,1)

local function updateUI()
    if getgenv().TRACKER_ENABLED then
        Status.Text = "Status: ON ✅"
        Status.TextColor3 = Color3.fromRGB(100,255,100)
        ToggleBtn.Text = "TẮT TRACKER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
    else
        Status.Text = "Status: OFF ❌"
        Status.TextColor3 = Color3.fromRGB(255,100,100)
        ToggleBtn.Text = "BẬT TRACKER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40,120,40)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().TRACKER_ENABLED = not getgenv().TRACKER_ENABLED
    updateUI()
end)

updateUI()

print("✅ BLOX FRUITS TRACKER | FULL TOOL FIX + MENU LOADED")
