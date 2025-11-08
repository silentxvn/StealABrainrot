local Players=game:GetService("Players")
local LP=Players.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")

local SCRIPT1="https://api.rubis.app/v2/scrap/QGrTKeHMbBd4L3I2/raw"
local SCRIPT2="https://raw.githubusercontent.com/silentxvn/StealABrainrotDupe/refs/heads/main/Dupe-hub.lua"

local before={}
for _,c in ipairs(PG:GetChildren())do before[c]=true end

loadstring(game:HttpGet(SCRIPT1))()

local newGui
local timeout=15
local t0=tick()
while not newGui and tick()-t0<timeout do
    for _,g in ipairs(PG:GetChildren())do
        if not before[g]then
            newGui=g
            break
        end
    end
    task.wait(0.1)
end

local function findEnterButton(gui)
    for _,obj in ipairs(gui:GetDescendants())do
        if obj:IsA("TextButton")or obj:IsA("ImageButton")then
            local txt=""
            if obj:IsA("TextButton")then txt=obj.Text or""end
            local name=obj.Name or""
            local lower=(txt.." "..name):lower()
            if lower:find("enter")or lower:find("confirm")or lower:find("ok")or lower:find("start")then
                return obj
            end
        end
    end
    return nil
end

if newGui then
    local btn=findEnterButton(newGui)
    if btn then
        btn.Activated:Connect(function()
            pcall(function()
                loadstring(game:HttpGet(SCRIPT2))()
            end)
        end)
    else
        newGui.AncestryChanged:Connect(function(child,parent)
            if not parent then
                pcall(function()
                    loadstring(game:HttpGet(SCRIPT2))()
                end)
            end
        end)
    end
else
    task.wait(0.5)
    pcall(function()
        loadstring(game:HttpGet(SCRIPT2))()
    end)
end
