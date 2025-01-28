--/ Services
local Players = game:GetService("Players")

--/ Globals
local speaker = Players.LocalPlayer
local cmsc = game:GetService("ReplicatedStorage")["ßtools"].Client_M_ServerControl

--/ Utility
local function getChar()
	return speaker.Character
end
local function getTool(name)
	local char = getChar()
	local tool
	if char then
		tool = char:FindFirstChild(name)
	end
	local res = 
		workspace:FindFirstChild(name) or
		speaker.Backpack:FindFirstChild(name) or
		tool
	if not res then
		for _, v in workspace:GetChildren() do
			if v:IsA("Tool") and v.Name == name then
				return v
			end
		end
		for _, plr in Players:GetPlayers() do
			for _, v in plr.Backpack:GetChildren() do
				if v:IsA("Tool") and v.Name == name then
					return v
				end
			end
			if plr.Character then
				for _, v in plr.Character:GetChildren() do
					if v:IsA("Tool") and v.Name == name then
						return v
					end
				end
			end
		end
	else
		return res
	end
end

--/ BTools API
local server = {}
local function getTServer(tt)
	return server[tt].Server
end

local btools = {}
btools.Init = function()
	-- Get tool references
	local d = getTool("D")
	local g = getTool("G")
	local c = getTool("C")
	if not d or not g or not c then
		return warn("--[LPI]-- Couldn't find BTools")
	end
	local char = getChar()
	server = {
		["D"] = d,
		["G"] = g,
		["C"] = c
	}
	-- Safely store tools
	for i, v in server do
		v.Parent = char
	end
	wait()
	for i, v in server do
		v.Parent = workspace
	end
	
	print("--[LPI]-- Got tool references!")
end
btools.DestroyPart = function(orig)
	local pnan = CFrame.new(0/0, 0/0, 0/0)
	local grab = getTServer("G")
	grab:InvokeServer(orig, pnan, "Update", "InputBegun")
	cmsc:FireServer(orig, pnan)
end
btools.DestroyInstances = function(orig)
	local f3x = getTool("F3X")
	f3x["SyncAPl"]["ServerEndPoint‌"]:InvokeServer("UndoRemove", orig)
end
btools.DestroyInstance = function(orig)
	btools.DestroyInstances({orig})
end
btools.ClonePart = function(orig)
	local clone = getTServer("C")
	orig.Locked = false
	clone:InvokeServer(orig, orig.CFrame, "Clone")
end
btools.Kill = function(orig)
	if orig:FindFirstChildOfClass("Humanoid") then
		local rootpart = orig:FindFirstChild("Head") or
			orig:FindFirstChild("Torso") or
			orig:FindFirstChild("LowerTorso") or
			orig:FindFirstChild("HumanoidRootPart")
		btools.DestroyPart(rootpart)
	end
end
btools.PlaySound = function(orig, sound)
	local grab = getTServer("G")
	grab:InvokeServer(orig, nil, "Sound", sound)
end

--/ Workspace API
local worksp = {}
worksp.GetDispensers = function()
	local holder = workspace.SafePlate.Mesh.Value
	local res = {}
	for i, v in holder:GetChildren() do
		if v.Bricks:FindFirstChild("Bar") then
			res.F3X = v
		else
			res.BTools = v
		end
	end
	return res
end
worksp.GetF3XDispenser = function()
	return worksp.GetDispensers().F3X
end
worksp.GetBToolsDispenser = function()
	return worksp.GetDispensers().BTools
end
worksp.GrabF3X = function()
	local dispenser = worksp.GetF3XDispenser()
	local hrp = getChar().HumanoidRootPart
	local cf = hrp.CFrame
	hrp.CFrame = dispenser.Bricks.Bar.CFrame
	speaker.Backpack:WaitForChild("F3X")
	hrp.CFrame = cf
end
worksp.GrabBTools = function()
	local dispenser = worksp.GetBToolsDispenser()
	local hrp = getChar().HumanoidRootPart
	local cf = hrp.CFrame
	hrp.CFrame = dispenser.Bricks["Smooth Block Model"].CFrame
	speaker.Backpack:WaitForChild("D")
	hrp.CFrame = cf
end
worksp.ChangeCharacterSize = function(size)
	local holder = workspace["Sp bricks"]["Sp bricks"].CharacterSizeChanger
	local changers = {
		Big = holder:FindFirstChild("Big"),
		Default = holder:FindFirstChild("Default"),
		Small = holder:FindFirstChild("Small")
	}
	local changer = changers[changer]
	assert(changer, "Couldn't find the character size changer")

	local hrp = getChar().HumanoidRootPart
	local cf = changer.CFrame
	changer.CFrame = hrp.CFrame
	task.wait(0.1)
	change.CFrame = cf
end

--/ Expose the API
return {
	["BTools"] = btools,
	["Workspace"] = worksp
}
