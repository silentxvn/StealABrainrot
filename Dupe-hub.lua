-- Thực hiện tải và chạy 1 script từ URL an toàn bằng pcall
local function fetchAndRun(url)
    if not url or url == "" then
        return false, "Empty URL"
    end

    -- thử gọi HttpGet (nhiều executor dùng game:HttpGet)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok or not body or body == "" then
        return false, "Không tải được từ URL: " .. tostring(url)
    end

    -- chạy code trả về bằng loadstring trong pcall để bắt lỗi runtime
    local ok2, res = pcall(function()
        local fn = loadstring(body)
        if not fn then error("loadstring trả về nil") end
        return fn()
    end)

    if not ok2 then
        return false, "Lỗi khi chạy script từ URL: " .. tostring(url) .. " — " .. tostring(res)
    end

    return true, "OK"
end

-- Cách nhập URL:
local DEFAULT_URL1 = "https://pastefy.app/AILhrbIZ/raw" -- đổi nếu muốn
local url1

if type(rconsoleinput) == "function" then
    -- interactive nếu executor hỗ trợ rconsoleinput
    rconsoleprint("Nhập link script thứ nhất (hoặc dán vào) rồi Enter:\n")
    url1 = rconsoleinput()
    if not url1 or url1 == "" then
        -- nếu người dùng không nhập, fallback về default
        url1 = DEFAULT_URL1
        rconsoleprint("Không nhập gì — sử dụng DEFAULT_URL1: "..url1.."\n")
    end
else
    -- không có rconsoleinput -> dùng mặc định (bạn có thể sửa DEFAULT_URL1)
    url1 = DEFAULT_URL1
end

-- Tải và chạy script 1, nếu thành công mới tiếp tục
local ok, msg = fetchAndRun(url1)
if not ok then
    -- thông báo lỗi, dừng; bạn có thể thay bằng print nếu rconsoleprint không có
    if type(rconsoleprint) == "function" then
        rconsoleprint("Lỗi: "..msg.."\n")
    else
        warn("Lỗi: "..msg)
    end
    return -- dừng không chạy tiếp
end

-- Nếu đến đây thì script 1 chạy thành công -> chạy script 2
local url2 = "https://raw.githubusercontent.com/silentxvn/StealABrainrot/main/Dupe-hub.lua"
local ok2, msg2 = fetchAndRun(url2)
if not ok2 then
    if type(rconsoleprint) == "function" then
        rconsoleprint("Lỗi khi chạy script 2: "..msg2.."\n")
    else
        warn("Lỗi khi chạy script 2: "..msg2)
    end
    return
end

if type(rconsoleprint) == "function" then
    rconsoleprint("Cả 2 script đã chạy xong.\n")
else
    print("Cả 2 script đã chạy xong.")
end
