local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlotService = require(ServerScriptService.PlotService)
local SaveService = require(ServerScriptService.SaveService)

local buildEvent = ReplicatedStorage.BuildEvent
local BuildChecks = require(ReplicatedStorage.BuildChecks)

local Signal = require(ReplicatedStorage.GoodSignal)

local BuildService = {}

function BuildService:PlaceObject(object: Model, plot: Model)
	
end

function BuildService:SellObject(object: Model)
	
end

return BuildService
