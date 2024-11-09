local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function clearServerFrames(scrollingFrame)
	for _, v in scrollingFrame:GetChildren() do
		if v:IsA("Frame") and not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
end

local function addServerFrame(scrollingFrame, PlaceId, PlayerCount, JobId, Planet, serverIndex)
	local ServerListFrameInstance = script.ServerFrame:Clone()
	ServerListFrameInstance.Parent = scrollingFrame
	ServerListFrameInstance.PlaceId.Value = tostring(PlaceId)
	ServerListFrameInstance.JobId.Value = tostring(JobId)
	ServerListFrameInstance.PlayerCount.Text = tostring(PlayerCount) .. " / 100 Players"
	ServerListFrameInstance.Planet.Value = tostring(Planet)
	ServerListFrameInstance.ServerName.Text = Planet .. " Server #" .. serverIndex

	game:GetService("ReplicatedStorage"):WaitForChild("Servers")[Planet]:WaitForChild(tostring(JobId)).PlayerCount.Changed:Connect(function(NewValue)
		ServerListFrameInstance.PlayerCount.Text = tostring(NewValue) .. " / 100 Players"
	end)

	ServerListFrameInstance.TextButton.Activated:Connect(function()
		TeleportService:TeleportToPlaceInstance(ServerListFrameInstance.PlaceId.Value, ServerListFrameInstance.JobId.Value, Player)
	end)
end

local function updateCreateServerFrame(scrollingFrame)
	local hasServers = false
	for _, v in scrollingFrame:GetChildren() do
		if v:IsA("Frame") and not v:IsA("UIListLayout") and v.Name ~= "CreateServerFrame" then
			hasServers = true
			break
		end
	end

	if not hasServers then
		if not scrollingFrame:FindFirstChild("CreateServerFrame") then
			local CreateServerFrameInstance = script.CreateServerFrame:Clone()
			CreateServerFrameInstance.Parent = scrollingFrame

			CreateServerFrameInstance.TextButton.Activated:Connect(function()
				if scrollingFrame.Parent.Name == "Dantooine" then
					TeleportService:Teleport(93169878293243)
				elseif scrollingFrame.Parent.Name == "Ilum" then
					TeleportService:Teleport(115842737692882)
				elseif scrollingFrame.Parent.Name == "Korriban" then
					TeleportService:Teleport(83404490767945)
				end
			end)
		end
	else
		local createServerFrame = scrollingFrame:FindFirstChild("CreateServerFrame")
		if createServerFrame then
			createServerFrame:Destroy()
		end
	end
end

local function refreshServerList(planet)
	local scrollingFrame = script.Parent.Canvas[planet].ScrollingFrame
	clearServerFrames(scrollingFrame)

	local servers = game:GetService("ReplicatedStorage"):WaitForChild("Servers"):FindFirstChild(planet)
	if servers then
		local serverIndex = 1
		for _, serverData in pairs(servers:GetChildren()) do
			local PlaceId = serverData.PlaceId.Value
			local PlayerCount = serverData.PlayerCount.Value
			local JobId = serverData.JobId.Value
			addServerFrame(scrollingFrame, PlaceId, PlayerCount, JobId, planet, serverIndex)
			serverIndex = serverIndex + 1
		end
	end

	updateCreateServerFrame(scrollingFrame)
end

local function checkAndHandleEmptyServerFolders()
	local servers = game:GetService("ReplicatedStorage"):WaitForChild("Servers")

	if #servers.Dantooine:GetChildren() == 0 then
		local dantooineScrollingFrame = script.Parent.Canvas.Dantooine.ScrollingFrame
		clearServerFrames(dantooineScrollingFrame)
		updateCreateServerFrame(dantooineScrollingFrame)
	end

	if #servers.Ilum:GetChildren() == 0 then
		local ilumScrollingFrame = script.Parent.Canvas.Ilum.ScrollingFrame
		clearServerFrames(ilumScrollingFrame)
		updateCreateServerFrame(ilumScrollingFrame)
	end

	if #servers.Korriban:GetChildren() == 0 then
		local korribanScrollingFrame = script.Parent.Canvas.Korriban.ScrollingFrame
		clearServerFrames(korribanScrollingFrame)
		updateCreateServerFrame(korribanScrollingFrame)
	end
end

local function initializeServerLists()
	while true do
		task.wait(2)
		refreshServerList("Dantooine")
		refreshServerList("Ilum")
		refreshServerList("Korriban")
		checkAndHandleEmptyServerFolders()
	end
end

game:GetService("ReplicatedStorage"):WaitForChild("Events").CreateServer.OnClientEvent:Connect(function(PlaceId, PlayerCount, JobId, Planet)
	refreshServerList(Planet)
end)

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvent").OnClientEvent:Connect(function(JobId, Planet)
	refreshServerList(Planet)
end)

spawn(initializeServerLists)
