local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Signal = require(ReplicatedStorage:WaitForChild("GoodSignal"))

local BuildChecks = require(ReplicatedStorage:WaitForChild("BuildChecks"))
local buildEvent = ReplicatedStorage:WaitForChild("BuildEvent")
local buildRequest = ReplicatedStorage:WaitForChild("BuildRequest")

local FreecamService = require(script:WaitForChild("FreecamService"))
local ObjectService = require(script:WaitForChild("ObjectService"))
local WallService = require(script:WaitForChild("WallService"))
local FloorService = require(script:WaitForChild("FloorService"))

local BuildService = {}

BuildService.ActiveSession = false
BuildService.CurrentObject = nil
BuildService.Plot = nil

BuildService.Warning = Signal.new()

BuildService.GridSize = 4 -- In studs
BuildService.GridEnabled = true -- Snaps positions to the above grid size
BuildService.BoundsEnabled = true -- Prevents placement outside of plot

local function StartSession()
    FreecamService:EnableBuildCamera(BuildService.Plot.PlotBase)
end

local function StopSession()
    RunService:UnbindFromRenderStep("PlacementSession")

    if BuildService.CurrentObject ~= nil then
        BuildService.CurrentObject:Destroy()
        BuildService.CurrentObject = nil
    end
end

function BuildService:RequestSessionStart()
    local success, start = pcall(function()
        return buildRequest:InvokeServer("start_session")
    end)

    if success and start then
        BuildService.ActiveSession = true
        BuildService.Plot = BuildService:GetPlot(workspace:WaitForChild("Plots"))
        StartSession()
    else
        warn("[BuildService] - Request to start placement session failed")
    end
end

function BuildService:RequestSessionCancel()
    local success, ended = pcall(function()
        return buildRequest:InvokeServer("stop_session")
    end)

    if success and ended then
        BuildService.ActiveSession = false
        StopSession()
    else
        warn("[BuildService] - Request to terminate placement session failed")
    end
end

function BuildService:GetPlot(plots: Folder)
    for i, plot in pairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerId") == player.UserId then
            BuildService.Plot = plot
            return plot
        end
    end

    warn("[BuildService] - Plot not found for player " .. player.Name)
    return nil
end

function BuildService:SelectObject(name: string)
    if not BuildService.ActiveSession then return end
    if not BuildService.Plot then return end

    ObjectService.Plot = BuildService.Plot
    ObjectService:StartPlacement(name)
end

function BuildService:SelectWall()
    WallService:StartPlacement(BuildService.Plot, 4)
end

function BuildService:SelectFloor()
    FloorService:StartPlacement(BuildService.Plot, 4)
end

buildEvent.OnClientEvent:Connect(function(action: string, data: {any})
    
end)

return BuildService
