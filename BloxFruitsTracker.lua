--====================================
-- BLOX FRUITS TRACKER | ATLANTIS STYLE
--====================================

--=========== CONFIG ==================
getgenv().WEBHOOK_URL = "https://ptb.discord.com/api/webhooks/1462515851168321648/8nE25RbQ8xhgU99b-XMCHYcPW_TXhGMlIMwXjImJM7IKF8sO-iOTYvz4UkXzcwDzTWW1"
getgenv().SEND_INTERVAL = 180 -- 3 phút

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

--=========== INVENTORY =================
local function getInventory()
    local inv = LP.Data:FindFirstChild("Inventory")
    local heart, scale, mythic, leg = 0, 0, 0, 0

    if inv then
        for _,i in pairs(inv:GetChildren()) do
            local n = i.Name:lower()
            local v = i.Value or 1
            if n:find("leviathan heart") then heart += v end
            if n:find("leviathan scale") then scale += v end
            if n:find("mythic scroll") then mythic += v end
            if n:find("legendary scroll") then leg += v end
        end
    end
    return heart, scale, mythic, leg
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
    if not requestFunc then return end

    local p = getPlayerData()
    local h,s,m,l = getInventory()

    local msg =
        "🛠️ **THEO DÕI BLOX FRUITS**\n" ..
        "👤 **User:** "..LP.Name.."\n\n" ..
        "🖥️ **Hệ Thống**\n" ..
        "🎮 FPS: "..currentFPS.."\n" ..
        "📶 Ping: "..math.floor(getPing()).." ms\n" ..
        "⏳ Treo: "..formatTime(os.time() - startTime).."\n\n" ..
        "👤 **Nhân Vật**\n" ..
        "⭐ Level: "..p.Level.."\n" ..
        "💵 Beli: $"..p.Beli.."\n" ..
        "🟣 Frag: "..p.Frag.."\n\n" ..
        "📦 **Leviathan**\n" ..
        "❤️ Tim: x"..h.."\n" ..
        "🧬 Vảy: x"..s.."\n" ..
        "📜 Mythic: x"..m.."\n" ..
        "📘 Legendary: x"..l.."\n\n" ..
        "👹 **Boss:** "..getBosses().."\n" ..
        "⏱️ Update: "..os.date("%H:%M:%S")

    requestFunc({
        Url = getgenv().WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({ content = msg })
    })
end

--=========== SEND FIRST TIME ==========
task.spawn(function()
    task.wait(2)
    pcall(sendWebhook)
end)

--=========== LOOP SEND =================
task.spawn(function()
    while task.wait(getgenv().SEND_INTERVAL) do
        pcall(sendWebhook)
    end
end)

--=========== AUTO REJOIN ===============
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

print("✅ Blox Fruits Tracker Loaded | Send now + every 3 minutes")
