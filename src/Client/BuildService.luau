local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local Signal = require(ReplicatedStorage:WaitForChild("GoodSignal"))

local BuildChecks = require(ReplicatedStorage:WaitForChild("BuildChecks"))
local buildEvent = ReplicatedStorage:WaitForChild("BuildEvent")

local BuildService = {}

BuildService.ActiveSession = false
BuildService.CurrentObject = nil
BuildService.Plot = nil

BuildService.Warning = Signal.new()

function BuildService:RequestSessionStart()
    buildEvent:FireServer("start_session")
end

function BuildService:RequestSessionCancel()
    buildEvent:FireServer("stop_session")
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

local function StartSession()
    camera.CameraType = Enum.CameraType.Scriptable

    RunService:BindToRenderStep("PlacementSession", Enum.RenderPriority.Camera.Value + 1, function()
        local mouse = UserInputService:GetMouseLocation()
        
    end)
end

local function StopSession()
    RunService:UnbindFromRenderStep("PlacementSession")

    if BuildService.CurrentObject ~= nil then
        BuildService.CurrentObject:Destroy()
        BuildService.CurrentObject = nil
    end

    camera.CameraType = Enum.CameraType.Custom
end

buildEvent.OnClientEvent:Connect(function(action: string, data: {any})
    if action == "start_session" then
        if data.CanStart then
            BuildService.ActiveSession = true
            StartSession()
        else
            BuildService.Warning:Fire("There was an error starting a build session. Please try again.")
        end
    elseif action == "stop_session" then
        BuildService.ActiveSession = false
        StopSession()
    end
end)

return BuildService
