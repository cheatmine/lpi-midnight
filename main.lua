-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Init lib
local rep = "https://github.com/cheatmine/lpi-midnight/raw/beta"
local LPI = loadstring(game:HttpGet(rep.."/API.lua", false), "LPI")()
local UI = loadstring(game:HttpGet(rep.."/UILib.lua", false), "UI")()
local Notif = UI:InitNotifications()

local blacklisted = { -- blacklisted tools
	"D", "G", "C",
	"F3X",
	".*" -- any tool
}
local exempt = { -- exempt players
	Player.Name,
	"qs_9994", "acid1ous"
}
local bans = { -- illum exterminate list
	"Zelxx_007", "BeaverSkin1965", "pompeygrande",
	"rvgfury07"
}

-- Not configurable!
local lockdown = false

-- Utility
local function match(s, t)
	for _, pattern in t do
		if s:match(pattern) then
			return true
		end
	end
	return false
end
local function isFeaturePresent(ft)
	if ft == "f3x" then
		local active = Player.Character:FindFirstChild("F3X")
			or workspace:FindFirstChild("F3X")
			or Player.Backpack:FindFirstChild("F3X")
		Player.Character.Humanoid:EquipTool(active)
		if not active then
			Notif:Notify("This function requires you to hold F3X!", 4, "error")
		end
		return active
	elseif ft == "btools" then
		local active = LPI.BTools.IsInit()
		if not active then
			Notif:Notify("This function requires you to initialize BTools API!", 4, "error")
		end
		return active
	end
end

-- Service functions
local runningServices = {}
local services = {}

local function stopService(name)
	if runningServices[name] then
		services[name].stop(runningServices[name])
		task.cancel(runningServices[name])
		runningServices[name] = nil
	else
		warn("Couldn't find a running task named '".. name.. "'")
	end
end
local function startService(name)
	runningServices[name] = task.spawn(services[name].start)
end
local function execService(name)
	services[name].start()
end

-- Services
local events = {}
services.ToolBlacklist = {
	start = function()
		events.NoTools = {}
		if not isFeaturePresent("btools") then return stopService("ToolBlacklist") end

		local function BindTool(tool, character)
			if not tool or not character then return end
			if tool:IsA("Tool") and match(tool.Name, blacklisted) then
				LPI.BTools.Kill(character)
			end
		end
		local function BindCharacter(character)
			table.insert(events.NoTools, character.ChildAdded:Connect(function(tool)
				BindTool(tool, character)
			end))
		end
		local function BindPlayer(player)
			if player.Character then BindCharacter(player.Character) end
			table.insert(events.NoTools, player.CharacterAdded:Connect(function(char)
				BindCharacter(char)
				table.insert(events.NoTools, player.Backpack.ChildAdded:Connect(function(tool)
					BindTool(tool, char)
				end))
				for i, v in player.Backpack:GetChildren() do
					BindTool(tool, char)
				end
			end))
		end

		table.insert(events.NoTools, Players.PlayerAdded:Connect(BindPlayer))
		for i, v in Players:GetPlayers() do
			if not match(v.Name, exempt) then
				BindPlayer(v)
				if v.Character then
					LPI.BTools.Kill(v.Character)
				end
			end
		end

		table.insert(events.NoTools, workspace.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") and tool:FindFirstChild("Handle") and match(tool.Name, blacklisted) then
				LPI.BTools.DestroyPart(tool.Handle)
			end
		end))
	end,
	stop = function()
		for i, v in events.NoTools do
			v:Disconnect()
		end
	end
}
services.Lockdown = {
	start = function()
		events.Lockdown = {}
		if not isFeaturePresent("f3x") then return stopService("Lockdown") end

		table.insert(event.Lockdown, Players.PlayerAdded:Connect(function(plr)
			if not match(plr.Name, exempt) then
				if not isFeaturePresent("f3x") then return stopService("Lockdown") end
				LPI.Btools.DestroyInstance(plr)
			end
		end))
	end,
	stop = function()
		for i, v in events.Lockdown do
			v:Disconnect()
		end
	end
}

-- UI
UI.title = "- = Midnight = -"
UI:Introduction()

local Window = UI:Init(Enum.KeyCode.RightControl)

local Wm = UI:Watermark("Midnight | b0.2.1 | " .. UI:GetUsername())
local FpsWm = Wm:AddWatermark("fps: " .. UI.fps)

coroutine.wrap(function()
	while wait(.75) do
		FpsWm:Text("fps: " .. UI.fps)
	end
end)()

-- Tabs
local tab = Window:NewTab("World")

tab:NewSection("Building Tools")
tab:NewButton("Init BTools API", function()
	if not workspace:FindFirstChild("D") then
		LPI.Workspace.GrabBTools()
	end
	LPI.BTools.Init()
end)
tab:NewButton("Get F3X", function()
	LPI.Workspace.GrabF3X()
end)
tab:NewButton("Get BTools", function()
	LPI.Workspace.GrabBTools()
end)
tab:NewSection("Gears")
tab:NewToggle("Gear Blacklist", false, function(bool)
	if bool then
		startService("ToolBlacklist")
	else
		stopService("ToolBlacklist")
	end
end)
tab:NewButton("Invisible F3X", function()
	if not isFeaturePresent("f3x") then return end
	local char = Player.Character
	if not char then return end
	if not char:FindFirstChild("Humanoid") then return end
	local tool = Player.Backpack:FindFirstChild("F3X")
		or char:FindFirstChild("F3X")
	if not tool:FindFirstChild("Handle") then return end
	local hum = char.Humanoid
	hum:EquipTool(tool)
	task.wait(0.1)
	LPI.BTools.DestroyInstance(tool.Handle)
end)

tab:NewSection("Parts")
tab:NewButton("Delete all spawns", function()
	if not isFeaturePresent("f3x") then return end
	local t = {}
	for i, v in workspace:GetChildren() do
		if v.Name == "SpawnLocation" then
			table.insert(t, v)
		end
	end
	LPI.BTools.DestroyInstances(t)
end)

tab:NewSection("Gear Board")
tab:NewButton("Delete banned gear", function()
	if not isFeaturePresent("f3x") then return end
	local t = {}
	for i, v in workspace["made by FoxBinMK4"]:GetChildren() do
		if v.Name == "Model" then
			table.insert(t, v.Dispenser.Dispenser.GamepassButtons)
		end
	end
	LPI.BTools.DestroyInstances(t)
end)
tab:NewButton("Delete gear boards", function()
	if not isFeaturePresent("f3x") then return end
	LPI.BTools.DestroyInstances({
		workspace["made by FoxBin"],
		workspace["made by FoxBin1"],
		workspace["made by FoxBinMK4"],
		workspace["made by FoxBinMK6"],
		workspace["made byFoxBin MK2"]
	})
end)

local users = {}
local tab = Window:NewTab("Players")
tab:NewTextbox("User selection", "", "all/others/me/<username>", "all", "small", false, false, function(text)
	if text == "all" then
		users = Players:GetPlayers()
	elseif text == "others" then
		users = {}
		for i, v in Players:GetPlayers() do
			if not match(v.Name, exempt) then
				table.insert(users, v)
			end
		end
	elseif text == "me" then
		users = {Players.LocalPlayer}
	else
		users = {}
		local user = Players:FindFirstChild(text)
		if user then
			users = {user}
		else
			Notif:Notify("Player not found!", 4, "error")
		end
	end
end)
tab:NewSection("Actions")
tab:NewButton("Kill", function()
	if not isFeaturePresent("btools") then return end
	for i, v in users do
		if v.Character then
			LPI.BTools.Kill(v.Character)
		end
	end
end)
tab:NewButton("Kick", function()
	if not isFeaturePresent("f3x") then return end
	LPI.BTools.DestroyInstances(users)
end)
tab:NewButton("Ban", function()
	if not isFeaturePresent("f3x") then return end
	for i, v in users do
		LPI.BTools.DestroyInstance(v)
		table.insert(bans, v.Name)
	end
end)
tab:NewButton("Punish", function()
	if not isFeaturePresent("f3x") then return end
	for i, v in users do
		if v.Character then
			LPI.BTools.DestroyInstances(v.Character:GetChildren())
		end
	end
end)
tab:NewSection("Fun")
tab:NewButton("Naked", function()
	if not isFeaturePresent("f3x") then return end
	for i, v in users do
		if v.Character then
			table.insert(t, v.Character:FindFirstChild("Shirt"))
			table.insert(t, v.Character:FindFirstChild("Pants"))
		end
	end
	LPI.BTools.DestroyInstances(t)
end)

local tab = Window:NewTab("Server")
tab:NewSection("Management")
tab:NewButton("Shutdown", function()
	if not isFeaturePresent("f3x") then return end
	LPI.BTools.DestroyInstances(Players:GetPlayers())
end)
tab:NewToggle("Whitelist", false, function(bool)
	if bool then
		startService("Lockdown")
	else
		stopService("Lockdown")
	end
end)

Players.PlayerAdded:Connect(function(plr)
	if table.find(bans, plr.Name) then
		if not isFeaturePresent("f3x") then return end
		LPI.BTools.DestroyInstance(plr)
	end
end)

Window:NewTab("")

local tab = Window:NewTab("Settings")
tab:NewKeybind("Menu keybind", Enum.KeyCode.RightAlt, function(key)
    UI:UpdateKeybind(Enum.KeyCode[key])
end)

Notif:Notify("Loaded Midnight", 4, "success")