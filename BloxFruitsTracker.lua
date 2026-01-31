-- 📸 BLOX FRUITS SCREENSHOT TOOL
-- Chụp ngay khi bật + 3 phút/lần

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================= CONFIG =================
local WEBHOOK_URL = "https://ptb.discord.com/api/webhooks/1462515851168321648/8nE25RbQ8xhgU99b-XMCHYcPW_TXhGMlIMwXjImJM7IKF8sO-iOTYvz4UkXzcwDzTWW1"
local INTERVAL = 180 -- 3 phút
-- ==========================================

-- Detect executor screenshot function
local function takeScreenshot()
    if syn and syn.request and syn.get_screenshot then
        return syn.get_screenshot()
    elseif getexecutorname and getexecutorname():lower():find("fluxus") then
        return getscreenshot()
    elseif getexecutorname and getexecutorname():lower():find("krnl") then
        return getscreenshot()
    elseif getscreenshot then
        return getscreenshot()
    else
        return nil
    end
end

-- Send image to Discord
local function sendScreenshot()
    local img = takeScreenshot()
    if not img then
        warn("❌ Executor không hỗ trợ chụp ảnh")
        return
    end

    local boundary = "----WebKitFormBoundary"..HttpService:GenerateGUID(false)

    local body =
        "--"..boundary.."\r\n"..
        "Content-Disposition: form-data; name=\"file\"; filename=\"bloxfruits.png\"\r\n"..
        "Content-Type: image/png\r\n\r\n"..
        img.."\r\n"..
        "--"..boundary.."--"

    local headers = {
        ["Content-Type"] = "multipart/form-data; boundary="..boundary
    }

    local req = syn and syn.request or http_request or request
    req({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = headers,
        Body = body
    })

    print("📸 Đã chụp & gửi ảnh")
end

-- Chụp lần đầu
task.spawn(function()
    task.wait(5)
    sendScreenshot()
end)

-- Lặp 3 phút/lần
while task.wait(INTERVAL) do
    sendScreenshot()
end
