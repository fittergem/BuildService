local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local BuildService = require(ServerScriptService.BuildService)

local BuildChecks = require(ReplicatedStorage.BuildChecks)
local PlotService = require(ServerScriptService.PlotService)

local buildEvent = ReplicatedStorage.BuildEvent
local buildRequest = ReplicatedStorage.BuildRequest

local plots = Workspace.Plots
local objectsFolder = ReplicatedStorage.BuildObjects

buildRequest.OnServerInvoke = function(player, action, buildData)
	if action == "start_session" then
        return true
    elseif action == "stop_session" then
        return true
    elseif action == "request_object_placement" then
        local reference = objectsFolder:FindFirstChild(buildData.Name)
        
        if not reference then
            warn("[BuildService] - Object with name '" .. buildData.Name .. "' could not be found.")
            return false
        end

        local plot = PlotService:GetPlayerPlot(player)

        local object = reference:Clone()
        object.Parent = plot
        object:PivotTo(buildData.CFrame)
        return true
    elseif action == "request_plot" then
        return true
    end
end

Players.PlayerAdded:Connect(function(player)

end)