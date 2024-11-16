local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore = DataStoreService:GetDataStore("Temp9[DEV]")
local ServerFolder = ReplicatedStorage:WaitForChild("Servers")
local DantooineFolder = ServerFolder:WaitForChild("Dantooine")
local IlumFolder = ServerFolder:WaitForChild("Ilum")
local KorribanFolder = ServerFolder:WaitForChild("Korriban")
local Event = ReplicatedStorage:WaitForChild("Events").CreateServer
local NoServerEvent = ReplicatedStorage:WaitForChild("Events").CreateNewServer

local serverIdleTimes = {}
local idleThreshold = 10
local playerAddedConnection

local function updateServersForPlanet(folder, data, planetKey)
	local validServerKeys = {}

	for serverJobId, serverInfo in pairs(data) do
		if serverInfo.Planet and serverInfo.Planet[planetKey] then
			table.insert(validServerKeys, serverJobId)
			local ServerFolderInstance = folder:FindFirstChild(serverJobId)

			if not ServerFolderInstance then
				ServerFolderInstance = Instance.new("Folder")
				ServerFolderInstance.Name = serverJobId
				ServerFolderInstance.Parent = folder
			end

			local JobIdInstance = ServerFolderInstance:FindFirstChild("JobId") or Instance.new("StringValue", ServerFolderInstance)
			JobIdInstance.Name = "JobId"
			JobIdInstance.Value = tostring(serverInfo.JobId or "Unknown")

			local PlaceIdInstance = ServerFolderInstance:FindFirstChild("PlaceId") or Instance.new("StringValue", ServerFolderInstance)
			PlaceIdInstance.Name = "PlaceId"
			PlaceIdInstance.Value = tostring(serverInfo.PlaceId or "Unknown")

			local PlayerCountInstance = ServerFolderInstance:FindFirstChild("PlayerCount") or Instance.new("IntValue", ServerFolderInstance)
			PlayerCountInstance.Name = "PlayerCount"
			PlayerCountInstance.Value = serverInfo.PlayerCount or 0

			local PlanetInstance = ServerFolderInstance:FindFirstChild("Planet") or Instance.new("StringValue", ServerFolderInstance)
			PlanetInstance.Name = "Planet"
			PlanetInstance.Value = planetKey

			if PlayerCountInstance.Value == 0 then
				if not serverIdleTimes[serverJobId] then
					serverIdleTimes[serverJobId] = tick()
				end
			else
				serverIdleTimes[serverJobId] = nil
			end
		end
	end

	for _, child in pairs(folder:GetChildren()) do
		if not table.find(validServerKeys, child.Name) then
			child:Destroy()
		end
	end
end

local function updateServerData()
	local success, data = pcall(function()
		return DataStore:GetAsync("ServerList")
	end)

	if not success or not data then
		warn("Failed to retrieve ServerList from DataStore: " .. tostring(data))
		return
	end

	updateServersForPlanet(DantooineFolder, data, "Dantooine")
	updateServersForPlanet(IlumFolder, data, "Ilum")
	updateServersForPlanet(KorribanFolder, data, "Korriban")
end

local function removeServerFromDataStore(serverJobId)
	local success, err = pcall(function()
		local data = DataStore:GetAsync("ServerList")
		if data then
			data[serverJobId] = nil
			DataStore:SetAsync("ServerList", data)
			print("Server " .. serverJobId .. " has been removed from the DataStore.")
		end
	end)

	if not success then
		warn("Failed to remove server " .. serverJobId .. " from DataStore: " .. tostring(err))
	end
end

spawn(function()
	while true do
		task.wait(1)
		for serverJobId, idleStartTime in pairs(serverIdleTimes) do
			if tick() - idleStartTime > idleThreshold then
				local serverInstance = DantooineFolder:FindFirstChild(serverJobId) or IlumFolder:FindFirstChild(serverJobId) or KorribanFolder:FindFirstChild(serverJobId)
				if serverInstance and serverInstance:FindFirstChild("PlayerCount") and serverInstance.PlayerCount.Value == 0 then
					removeServerFromDataStore(serverJobId)
					serverInstance:Destroy()
					serverIdleTimes[serverJobId] = nil
				end
			end
		end
	end
end)

local function sendServerDataToPlayer(Player)
	task.wait(2)

	local function sendUpdates()
		pcall(function()
			while Player.Parent do
				local hasServers = false

				if #DantooineFolder:GetChildren() > 0 then
					hasServers = true
					for _, v in pairs(DantooineFolder:GetChildren()) do
						Event:FireClient(Player, v.PlaceId.Value, v.PlayerCount.Value, v.JobId.Value, v.Planet.Value)
						task.wait(0.3)
					end
				end

				if #IlumFolder:GetChildren() > 0 then
					hasServers = true
					for _, v in pairs(IlumFolder:GetChildren()) do
						Event:FireClient(Player, v.PlaceId.Value, v.PlayerCount.Value, v.JobId.Value, v.Planet.Value)
						task.wait(0.3)
					end
				end

				if #KorribanFolder:GetChildren() > 0 then
					hasServers = true
					for _, v in pairs(KorribanFolder:GetChildren()) do
						Event:FireClient(Player, v.PlaceId.Value, v.PlayerCount.Value, v.JobId.Value, v.Planet.Value)
						task.wait(0.3)
					end
				end

				if not hasServers then
					NoServerEvent:FireClient(Player)
				end

				task.wait(1)
			end
		end)
	end

	spawn(sendUpdates)
end

local function onPlayerAdded(Player)
	sendServerDataToPlayer(Player)
end

local function connectPlayerAddedEvent()
	playerAddedConnection = Players.PlayerAdded:Connect(onPlayerAdded)
end

local function disconnectPlayerAddedEvent()
	if playerAddedConnection then
		playerAddedConnection:Disconnect()
		playerAddedConnection = nil
	end
end

connectPlayerAddedEvent()

spawn(function()
	while true do
		task.wait(0.1)
		updateServerData()
	end
end)
