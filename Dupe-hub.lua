-- Wrapper: chạy script1 rồi chỉ chạy script2 khi người dùng bấm "Enter" (hoặc khi menu bị đóng)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local SCRIPT1 = "https://api.rubis.app/v2/scrap/QGrTKeHMbBd4L3I2/raw"
local SCRIPT2 = "https://raw.githubusercontent.com/silentxvn/StealABrainrotDupe/main/Dupe-hub.lua"

-- lưu snapshot các Gui đang có trước khi load script1
local before = {}
for _, c in ipairs(PG:GetChildren()) do before[c] = true end

-- chạy script1 (menu)
loadstring(game:HttpGet(SCRIPT1))()

-- tìm GUI mới do script1 tạo
local newGui
local timeout = 15 -- thời gian tối đa chờ GUI xuất hiện
local t0 = tick()
while not newGui and tick() - t0 < timeout do
    for _, g in ipairs(PG:GetChildren()) do
        if not before[g] then
            newGui = g
            break
        end
    end
    task.wait(0.1)
end

-- helper: tìm nút phù hợp (TextButton/ImageButton có Text chứa các từ khóa)
local function findEnterButton(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local txt = ""
            if obj:IsA("TextButton") then txt = obj.Text or "" end
            local name = obj.Name or ""
            local lower = (txt .. " " .. name):lower()
            -- kiểm tra từ khóa phổ biến: "enter", "confirm", "ok", "start"
            if lower:find("enter") or lower:find("confirm") or lower:find("ok") or lower:find("start") then
                return obj
            end
        end
    end
    return nil
end

if newGui then
    local btn = findEnterButton(newGui)
    if btn then
        -- khi nút được bấm, load script2
        -- dùng Activated cho compatibility (Touch/Mouse/Gamepad)
        btn.Activated:Connect(function()
            pcall(function()
                loadstring(game:HttpGet(SCRIPT2))()
            end)
        end)
    else
        -- fallback: nếu không tìm thấy nút, chờ GUI bị xóa (menu đóng) rồi load script2
        newGui.AncestryChanged:Connect(function(child, parent)
            if not parent then
                pcall(function()
                    loadstring(game:HttpGet(SCRIPT2))()
                end)
            end
        end)
    end
else
    -- Nếu không detect được GUI mới (ví dụ script1 dùng existing GUI), fallback nhẹ:
    -- chờ ngắn rồi chạy script2 (nếu bạn không muốn fallback này, xóa khối này)
    task.wait(0.5)
    pcall(function()
        loadstring(game:HttpGet(SCRIPT2))()
    end)
end
