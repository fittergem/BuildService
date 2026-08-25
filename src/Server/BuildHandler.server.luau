local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local BuildService = require(ServerScriptService.BuildService)

local BuildChecks = require(ReplicatedStorage.BuildChecks)

local buildEvent = ReplicatedStorage.BuildEvent

local plots = Workspace.Plots

buildEvent.OnServerEvent:Connect(function(player, action, buildData)
	
end)