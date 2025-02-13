--/ Configuration
local config = {
	AnimationSpeed = 1,
	Keybinds = {
		Menu = "Semicolon"
	}
}
local BanList = {}

--/ Instancing
local _ins = debug.info(1, "f")
if MV2 then MV2.UI:Destroy() end
getgenv().MV2 = {
	UI = nil,
	Instance = _ins
}
local function IsInstanceRunning()
	return getgenv().MV2.Instance == _ins
end

--/ Services
local Players = game:FindService("Players")
local UIS = game:FindService("UserInputService")
local TWS = game:FindService("TweenService")
local COREGUI = gethui and gethui() or game:FindService("CoreGui")
local Prim = loadstring(game:HttpGet("https://github.com/cheatmine/lpi-prim/raw/main/API.lua"))()

--/ LPI Protection
task.spawn(function()
	_G.LPI_SECURITY_SCOPE = "Midnight";
	loadstring(game:HttpGet("https://github.com/cheatmine/lpi/raw/main/security"))()
end)

--/ Utility
local function PlrSelection(query: string): {Player}
	query = query or "!"
	
	if query == "me" then
		return {Players.LocalPlayer}
	elseif query == "all" then
		return Players:GetPlayers()
	elseif query == "others" then
		local t = {}
		for i, v in Players:GetPlayers() do
			if v ~= Players.LocalPlayer then
				table.insert(t, v)
			end
		end
		return t
	elseif query == "random" then
		local plrs = Players:GetPlayers()
		return {(plrs)[math.random(1, #plrs)]}
	elseif query == "!" then
		return {}
	else
		local t = {}
		for i, v in Players:GetPlayers() do
			if v.Name:sub(1, #query):lower() == query:lower() or v.DisplayName:sub(1, #query):lower() == query:lower() then
				table.insert(t, v)
			end
		end
		return t
	end
end

--/ Commands list
local commands = {}
commands.List = {} :: {[string]: {Alias: {string}, Display: string, Callback: (Player, ...string) -> ()}}
commands.AddCommand = function(name, aliases, display, callback)
	commands.List[name:lower()] = {
		Alias = aliases,
		Display = display:lower(),
		Callback = callback
	}
end

----------------------------------------------------------------
----------------------------------------------------------------
--------------------------- COMMANDS ---------------------------
----------------------------------------------------------------
----------------------------------------------------------------
local Notify = Instance.new("BindableEvent")

local Freeze = workspace:FindFirstChild("MV2-Freeze")
local lockdown = false

local function InitFreeze()
	if Freeze then if Freeze.Parent then return end end
	Freeze = Prim.GetF3X().SyncAPI:InvokeServer("CreatePart", "Normal", CFrame.new(0, 0, 0))
	Freeze:AddTag("MV2")
	Freeze.Name = "MV2-Freeze"
	Prim.QueuePartChange(Freeze, {Transparency = 1, Anchored = true, CanCollide = false, CanTouch = false})
end

commands.AddCommand("bring", {}, "bring <player>", function(speaker, user)
	local pos = speaker.Character.Torso.Position
	local characters = PlrSelection(user)
	for i, v in characters do
		if v.Character and v.Character:FindFirstChild("Torso") then
			characters[i] = v.Character
		end
	end
	local i = 0
	local garbage = {}
	for _, character in characters do
		task.spawn(function()
			local mover = Prim.GetF3X().SyncAPI:InvokeServer("CreatePart", "Normal", CFrame.new(0, 0, 0))
			local weld = Prim.Weld(mover, character.Torso)
			Prim.QueuePartChange(mover, {CFrame = character.Torso.CFrame:Inverse() + pos, Transparency = 1, CanCollide = false, CanTouch = false})
			table.insert(garbage, mover)
			table.insert(garbage, weld)
			i += 1
		end)
	end
	repeat task.wait() until i == #characters
	Prim.DestroyInstances(garbage)
	Notify:Fire(`Bringed {#characters} players`)
end)

commands.AddCommand("goto", {}, "goto <player>", function(speaker, user)
	local hrp = speaker.Character.HumanoidRootPart
	local character = PlrSelection(user)[1].Character
	hrp.CFrame = character.Torso.CFrame
end)

commands.AddCommand("ban", {}, "ban <player>", function(speaker, user)
	local players = PlrSelection(user)
	local t = {}
	for i, v in players do
		if v ~= Players.LocalPlayer then
			table.insert(BanList, v.Name)
			table.insert(t, v)
		end
	end
	Prim.DestroyInstances(t)
	Notify:Fire(`Banned {#players} players`)
end)

commands.AddCommand("kick", {}, "kick <player>", function(speaker, user)
	local players = PlrSelection(user)
	Prim.DestroyInstances(players)
	Notify:Fire(`Kicked {#players} players`)
end)

commands.AddCommand("kill", {}, "kill <player>", function(speaker, user)
	local characters = PlrSelection(user)
	for i, v in characters do
		if v.Character then
			characters[i] = v.Character
		end
	end
	local joints = {}
	for _, character in characters do
		for i, v in character:GetDescendants() do
			if v:IsA("JointInstance") then
				table.insert(joints, v)
			end
		end
	end
	Prim.DestroyInstances(joints)
	Notify:Fire(`Killed {#characters} players`)
end)
commands.AddCommand("loopkill", {}, "loopkill <player>", function(speaker, user)
	while task.wait(0.1) do
		local characters = PlrSelection(user)
		for i, v in characters do
			if v.Character then
				characters[i] = v.Character
			end
		end
		local joints = {}
		for _, character in characters do
			for i, v in character:GetDescendants() do
				if v:IsA("JointInstance") then
					table.insert(joints, v)
				end
			end
		end
		Prim.DestroyInstances(joints)
	end
end)

commands.AddCommand("punish", {}, "punish <player>", function(speaker, user)
	local characters = PlrSelection(user)
	for i, v in characters do
		if v.Character then
			characters[i] = v.Character
		end
	end
	local t = {}
	for _, character in characters do
		for i, v in character:GetChildren() do
			table.insert(t, v)
		end
	end
	Prim.DestroyInstances(t)
	Notify:Fire(`Deleted {#characters} players characters`)
end)
commands.AddCommand("looppunish", {}, "looppunish <player>", function(speaker, user)
	while task.wait(0.1) do
		local characters = PlrSelection(user)
		for i, v in characters do
			if v.Character then
				characters[i] = v.Character
			end
		end
		local t = {}
		for _, character in characters do
			for i, v in character:GetChildren() do
				table.insert(t, v)
			end
		end
		Prim.DestroyInstances(t)
	end
end)

commands.AddCommand("freeze", {}, "freeze <player>", function(speaker, user)
	InitFreeze()
	local characters = PlrSelection(user)
	for i, v in characters do
		if v.Character and v.Character:FindFirstChild("Torso") then
			characters[i] = v.Character
		end
	end
	for _, character in characters do
		task.spawn(Prim.Weld, Freeze, character.Torso)
	end
	Notify:Fire(`Freezed {#characters} players`)
end)
commands.AddCommand("unfreeze", {}, "unfreeze <player>", function(speaker, user)
	local characters = PlrSelection(user)
	local t = {}
	for i, v in characters do
		if v.Character then
			for _, weld in v.Character:GetDescendants() do
				if weld:IsA("Weld") and (weld.Part0 == Freeze or weld.Part1 == Freeze) then
					table.insert(t, weld)
				end
			end
		end
	end
	Prim.DestroyInstances(t)
	Notify:Fire(`Unfreezed {#characters} players`)
end)
if table.find(BanList, Players.LocalPlayer.Name) then getgenv().MV2 = nil return end

commands.AddCommand("shutdown", {}, "shutdown", function(speaker)
	Notify:Fire("Shutting down server...")
	Prim.DestroyInstances(PlrSelection("others"))
	Prim.DestroyInstances(PlrSelection("me"))
end)
commands.AddCommand("whitelist", {"lockdown"}, "whitelist/lockdown", function(speaker)
	lockdown = not lockdown
	if lockdown then
		Notify:Fire("This server is now locked")
	else
		Notify:Fire("This server is now open")
	end
end)

commands.AddCommand("f3x", {"getf3x"}, "f3x/getf3x", function(speaker)
	local char = speaker.Character
	local InitialCF = char.HumanoidRootPart.CFrame
	local InitialState = {}
	for i, v in char:GetDescendants() do
		if not v:IsA("BasePart") then continue end
		InitialState[v] = {
			CanCollide = v.CanCollide,
			CanTouch = v.CanTouch
		}
		v.CanCollide = false
		v.CanTouch = v.Name == "HumanoidRootPart"
	end
	local f3xdispenser
	for i, v in workspace.SafePlate.Mesh.Value:GetChildren() do
		if v.Bricks:FindFirstChild("Bar") then
			f3xdispenser = v.Bricks.Bar
			break
		end
	end
	repeat
		char.HumanoidRootPart.CFrame = f3xdispenser.CFrame
		char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, math.random() * 20, 0)
		char.HumanoidRootPart.AssemblyAngularVelocity = Vector3.one * math.random() * 20
		task.wait(0.1)
	until speaker.Backpack:FindFirstChild("F3X")
	for i, v in char:GetDescendants() do
		if not v:IsA("BasePart") then continue end
		v.CanCollide = InitialState[v].CanCollide
		v.CanTouch = InitialState[v].CanTouch
	end
	char.HumanoidRootPart.CFrame = InitialCF
end)

commands.AddCommand("invisf3x", {"nohandle"}, "invisf3x/nohandle", function(speaker)
	Prim.DestroyF3XHandle()
end)

commands.AddCommand("gearisland", {"gil"}, "gearisland/gil", function(speaker)
	speaker.Character:MoveTo(Vector3.new(32, 3, -86))
end)

commands.AddCommand("sit", {}, "sit", function(speaker)
	speaker.Character.Humanoid.Sit = true
end)
commands.AddCommand("unsit", {}, "unsit", function(speaker)
	speaker.Character.Humanoid.Sit = false
end)
commands.AddCommand("nogears", {}, "nogears <player>", function(speaker, user)
	local players = PlrSelection(user)
	local t = {}
	for _, player in players do
		for i, v in player.Backpack:GetChildren() do
			if v:IsA("Tool") then
				table.insert(t, v)
			end
		end
		if player.Character then
			for i, v in player.Character:GetChildren() do
				if v:IsA("Tool") then
					table.insert(t, v)
				end
			end
		end
	end
	Prim.DestroyInstances(t)
end)

commands.AddCommand("secretroom", {"secret"}, "secretroom/secret", function(speaker)
	speaker.Character:MoveTo(Vector3.new(-23862, 40, -135))
end)

commands.AddCommand("dumpster", {"lpidumpster"}, "dumpster", function(speaker)
	loadstring(game:HttpGet("https://github.com/cheatmine/lpi-dumpster/raw/main/main.lua"))()
end)

----------------------------------------------------------------
----------------------------------------------------------------
--------------------------- FINISHED ---------------------------
----------------------------------------------------------------
----------------------------------------------------------------

--/ Public functions
local MidnightV2 = {}

MidnightV2.Commands = commands

MidnightV2.ExecuteCommand = function(query: string)
	local components = query:split(" ")
	local cmd = components[1]
	local args = select(2, unpack(components))
	for fname, fcommand in commands.List do
		if fname == cmd:lower() or table.find(fcommand.Alias, cmd:lower()) then
			task.spawn(fcommand.Callback, Players.LocalPlayer, args)
		end
	end
end

MidnightV2.GetSuggestions = function(query: string)
	local suggestions = {}
	local i = 0
	for _, command in commands.List do
		if i >= 10 then
			break
		end
		if command.Display:find(query:lower()) then
			table.insert(suggestions, command.Display)
			i += 1
		end
	end
	return suggestions
end

getgenv().MidnightV2 = MidnightV2

--------------------------- UI ---------------------------
-- Instances:
local UI = Instance.new("ScreenGui")
local TextEntry = Instance.new("Frame")
local UIStroke = Instance.new("UIStroke")
local TextBox = Instance.new("TextBox")
local Suggestions = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Suggestion = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local Notifications = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local Notification = Instance.new("Frame")
local NotifText = Instance.new("TextLabel")

UI.Name = "UI"
UI.Parent = COREGUI
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

TextEntry.Name = "TextEntry"
TextEntry.Parent = UI
TextEntry.AnchorPoint = Vector2.new(0, 0.5)
TextEntry.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextEntry.BackgroundTransparency = 0.500
TextEntry.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextEntry.BorderSizePixel = 0
TextEntry.ClipsDescendants = true
TextEntry.Position = UDim2.new(0, 0, 0.5, 0)
TextEntry.Size = UDim2.new(1, 0, 0, 36)

UIStroke.Name = "UIStroke"
UIStroke.Parent = TextEntry
UIStroke.Color = Color3.fromRGB(127, 127, 127)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5

TextBox.Parent = TextEntry
TextBox.AnchorPoint = Vector2.new(0, 0.5)
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundTransparency = 1
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0, 0, 0.5, 0)
TextBox.Size = UDim2.new(1, 0, 0, 36)
TextBox.Font = Enum.Font.Michroma
TextBox.PlaceholderText = "Enter your command here"
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 26

Suggestions.Name = "Suggestions"
Suggestions.Parent = UI
Suggestions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Suggestions.BackgroundTransparency = 1
Suggestions.BorderColor3 = Color3.fromRGB(0, 0, 0)
Suggestions.BorderSizePixel = 0
Suggestions.Position = UDim2.new(0, 0, 0.5, 32)
Suggestions.Size = UDim2.new(1, 0, 1, 0)

UIListLayout.Parent = Suggestions
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

Suggestion.Name = "Suggestion"
Suggestion.Parent = UI
Suggestion.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Suggestion.BackgroundTransparency = 0.600
Suggestion.BorderColor3 = Color3.fromRGB(0, 0, 0)
Suggestion.BorderSizePixel = 0
Suggestion.Size = UDim2.new(1, 0, 0, 30)
Suggestion.Visible = false

TextLabel.Parent = Suggestion
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Font = Enum.Font.Michroma
TextLabel.Text = "bring <player>"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 23

Notifications.Name = "Notifications"
Notifications.Parent = UI
Notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Notifications.BackgroundTransparency = 1
Notifications.BorderColor3 = Color3.fromRGB(0, 0, 0)
Notifications.BorderSizePixel = 0
Notifications.Position = UDim2.new(0, 0, 0.05, 0)
Notifications.Size = UDim2.new(1, 0, 0.8, 0)

UIListLayout_2.Parent = Notifications
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

Notification.Name = "Notification"
Notification.Parent = UI
Notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Notification.BackgroundTransparency = 0.500
Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
Notification.BorderSizePixel = 0
Notification.ClipsDescendants = true
Notification.Size = UDim2.new(1, 0, 0, 36)
Notification.Visible = false

NotifText.Name = "NotifText"
NotifText.Parent = Notification
NotifText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NotifText.BackgroundTransparency = 1
NotifText.BorderColor3 = Color3.fromRGB(0, 0, 0)
NotifText.BorderSizePixel = 0
NotifText.Size = UDim2.new(1, 0, 1, 0)
NotifText.Font = Enum.Font.Michroma
NotifText.Text = "Midnight V2 notification!"
NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifText.TextSize = 26
NotifText.RichText = true

Notify.Name = "Notify"
Notify.Parent = UI

local MV2ESP = Instance.new("Folder", UI)
MV2ESP.Name = "MV2ESP"
local names = {} :: {[Player]: BillboardGui}
local events = {} :: {[Player]: RBXScriptConnection}
local ranked = {} :: {[string]: number}

local function getNickname(player: Player)
	local rank = ranked[player.Name]
	if rank >= 4 then
		return `<font color="#00ff00"><stroke color="#00ff00" joins="miter" thickness="0.5" transparency="0.25"><b>▲ {player.Name}</b></stroke></font>`
	elseif rank > 0 then
		return `<font color="#00ff00"><stroke color="#000000" joins="miter" thickness="0.25" transparency="0.25">▲ {player.Name}</stroke></font>`
	else
		return `<font color="#ffffff"><stroke color="#000000" joins="miter" thickness="0.25" transparency="0.25">{player.Name}</stroke></font>`
	end
end

local function CharacterAdded(player: Player, character: Model)
	if not IsInstanceRunning() then return end
	local bl = names[player]
	bl.Adornee = character:WaitForChild("Head")
	if character:WaitForChild("Humanoid", 3) then
		character.Humanoid.DisplayName = " "
	end
end
local function PlayerAdded(player: Player, silent: boolean?)
	if not IsInstanceRunning() then return end
	if names[player] == false then return end
	local rank = player:GetRankInGroup(35462739)
	ranked[player.Name] = rank
	if not silent then
		if rank == 255 then
			Notify:Fire(`@{player.Name} Illuminati <font color="#00ff00">owner</font> joined the game`)
		elseif rank >= 4 then
			Notify:Fire(`@{player.Name} Illuminati <font color="#ffff00">elite</font> joined the game`)
		elseif rank > 0 then
			Notify:Fire(`@{player.Name} Illuminati member joined the game`)
		end
	end

	local bl = Instance.new("BillboardGui", MV2ESP)
	bl.Name = player.Name
	bl.Size = UDim2.fromScale(10, 1.5)
	bl.StudsOffsetWorldSpace = Vector3.yAxis * 2
	bl.PlayerToHideFrom = player
	bl.LightInfluence = 0
	bl.AlwaysOnTop = true

	local text = Instance.new("TextLabel", bl)
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.Michroma
	text.RichText = true
	text.Text = getNickname(player)
	text.TextScaled = true

	names[player] = bl

	events[player] = player.CharacterAdded:Connect(function(character)
		task.spawn(CharacterAdded, player, character)
	end)
end
local function PlayerRemoving(player: Player)
	if not IsInstanceRunning() then return end
	if names[player] == nil then
		names[player] = false
		task.delay(1, function()
			names[player] = nil
		end)
		return
	end
	names[player]:Destroy()
	names[player] = nil
	events[player]:Disconnect()
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)
for i, v in Players:GetPlayers() do
	PlayerAdded(v, true)
	if v.Character then
		task.spawn(CharacterAdded, v, v.Character)
	end
end

--/ UI
local AnimationTime = 1/config.AnimationSpeed
local Tasks = {Opening = {}, Closing = {}}

local function OpenBar()
	for i, v in Tasks.Closing do
		task.cancel(v)
	end
	
	table.insert(Tasks.Opening, task.spawn(function()
		TextEntry.Visible = true
		TWS:Create(
			TextEntry,
			TweenInfo.new(AnimationTime * 0.5, Enum.EasingStyle.Quint),
			{Size = UDim2.new(1, 0, 0, 36)}
		):Play()
		TWS:Create(
			TextEntry.UIStroke,
			TweenInfo.new(AnimationTime * 0.5, Enum.EasingStyle.Quint),
			{Transparency = 0.5}
		):Play()
		TextEntry.TextBox:CaptureFocus()
		UI.Suggestions.Visible = true
		TextEntry.TextBox.Text = ""
	end))
end

local function CloseBar()
	for i, v in Tasks.Opening do
		task.cancel(v)
	end

	table.insert(Tasks.Closing, task.spawn(function()
		TWS:Create(
			TextEntry,
			TweenInfo.new(AnimationTime * 0.5, Enum.EasingStyle.Quint),
			{Size = UDim2.new(1, 0, 0, 0)}
		):Play()
		TWS:Create(
			TextEntry.UIStroke,
			TweenInfo.new(AnimationTime * 0.5, Enum.EasingStyle.Quint),
			{Transparency = 1}
		):Play()
		TextEntry.TextBox.Text = ""
		UI.Suggestions.Visible = false
		task.wait(AnimationTime * 0.5 - 0.05)
		TextEntry.Visible = false
	end))
end

local function ExecuteCommand()
	MidnightV2.ExecuteCommand(TextEntry.TextBox.Text)
end
local function Suggestions()
	local suggestions = MidnightV2.GetSuggestions(TextEntry.TextBox.Text)
	for i, v in UI.Suggestions:GetChildren() do
		if v.Name == "Suggestion" then
			v:Destroy()
		end
	end
	
	for _, suggestion in suggestions do
		local sugf = UI.Suggestion:Clone()
		sugf.Parent = UI.Suggestions
		sugf.TextLabel.Text = suggestion
		sugf.Visible = true
	end
end

--/ Events
UIS.InputBegan:Connect(function(input, gme)
	if not IsInstanceRunning() then return end
	task.wait(0.008)
	if input.KeyCode.Name == config.Keybinds.Menu and not gme then
		OpenBar()
	end
	
	if TextEntry.TextBox:IsFocused() then
		Suggestions()
	else
		CloseBar()
	end
end)

TextEntry.TextBox.FocusLost:Connect(function(enter)
	if not IsInstanceRunning() then return end
	if enter then
		ExecuteCommand()
	end
	CloseBar()
end)

UI.Notify.Event:Connect(function(text)
	if not IsInstanceRunning() then return end
	local notification = UI.Notification:Clone()
	notification.NotifText.Text = text
	notification.Size = UDim2.new(1, 0, 0, 0)
	notification.Visible = true
	notification.Parent = UI.Notifications
	
	TWS:Create(
		notification,
		TweenInfo.new(AnimationTime * 0.5, Enum.EasingStyle.Quint),
		{Size = UDim2.new(1, 0, 0, 36)}
	):Play()
	
	task.delay(4, function()
		TWS:Create(
			notification,
			TweenInfo.new(AnimationTime * 0.5, Enum.EasingStyle.Quint),
			{Size = UDim2.new(1, 0, 0, 0)}
		):Play()
		task.wait(AnimationTime * 0.5)
		notification:Destroy()
	end)
end)

Players.PlayerAdded:Connect(function(player)
	if not IsInstanceRunning() then return end
	if table.find(BanList, player.Name) or lockdown then
		Prim.DestroyInstance(player)
	end
end)

--/ Finished loading
CloseBar()
getgenv().MV2 = {
	UI = UI,
	Instance = debug.info(1, "f")
}

Notify:Fire(`Loaded Midnight V2! Press [{config.Keybinds.Menu}] to open command bar.`)