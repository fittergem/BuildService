local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local BuildService = require(ServerScriptService.BuildService)

local sharedFolder = ReplicatedStorage.BuildService
local BuildChecks = require(sharedFolder.BuildChecks)

local buildEvent = sharedFolder.BuildEvent

local plots = Workspace.Plots

buildEvent.OnServerEvent:Connect(function(player, action, buildData)
	
end)
