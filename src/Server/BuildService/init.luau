local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.BuildConfig)
local Signal = require(ReplicatedStorage.GoodSignal)

local PlotService = require(script.PlotService)
local SaveService = require(script.SaveService)

local BuildChecks = require(ReplicatedStorage.BuildChecks)

local buildEvent = ReplicatedStorage.BuildEvent
local buildRequest = ReplicatedStorage.BuildRequest

local objectsFolder = ReplicatedStorage.BuildObjects

local BuildService = {}

BuildService.Warning = Signal.new()

function BuildService:PlayerAdded(player: Player)
    return true
end

function BuildService:PlaceObject(player: Player, name: string, cframe: CFrame)
	local reference = objectsFolder:FindFirstChild(name)
        
    if not reference then
        BuildService.Warning:Fire("Object with name '" .. name .. "' could not be found.")
        return false
    end

    local plot = PlotService:GetPlayerPlot(player)

    local object = reference:Clone()
    object.Parent = plot
    object:PivotTo(cframe)
    return true
end

buildRequest.OnServerInvoke = function(player, action, buildData)
	if action == "start_session" then
        return true
    elseif action == "stop_session" then
        return true
    elseif action == "request_object_placement" then
        return BuildService:PlaceObject(player, buildData.Name, buildData.CFrame)
    elseif action == "request_plot" then
        return true
    end
end

return BuildService
