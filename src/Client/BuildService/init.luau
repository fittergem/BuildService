local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Signal = require(ReplicatedStorage:WaitForChild("GoodSignal"))

local BuildChecks = require(ReplicatedStorage:WaitForChild("BuildChecks"))
local Config = require(ReplicatedStorage:WaitForChild("BuildConfig"))
local buildEvent = ReplicatedStorage:WaitForChild("BuildEvent")
local buildRequest = ReplicatedStorage:WaitForChild("BuildRequest")

local FreecamService = require(script:WaitForChild("FreecamService"))
local ObjectService = require(script:WaitForChild("ObjectService"))
local WallService = require(script:WaitForChild("WallService"))
local FloorService = require(script:WaitForChild("FloorService"))
local Values = require(script:WaitForChild("Values"))

local plotsFolder = workspace:WaitForChild("Plots")

local BuildService = {}

BuildService.Warning = Signal.new()

local function StartSession()
    FreecamService:EnableBuildCamera()
end

local function StopSession()
    RunService:UnbindFromRenderStep("PlacementSession")

    if Values.CurrentObject ~= nil then
        Values.CurrentObject:Destroy()
        Values.CurrentObject = nil
    end
end

function BuildService:RequestSessionStart()
    if not Values.CurrentPlotBase then
        BuildService.Warning:Fire("Plot not selected")
        return
    end

    local success, start = pcall(function()
        return buildRequest:InvokeServer("start_session")
    end)

    if success and start then
        Values.SessionActive = true
        StartSession()
    else
        BuildService.Warning:Fire("Request to start placement session failed")
    end
end

function BuildService:RequestSessionCancel()
    local success, ended = pcall(function()
        return buildRequest:InvokeServer("stop_session")
    end)

    if success and ended then
        Values.SessionActive = false
        StopSession()
    else
        BuildService.Warning:Fire("Request to terminate placement session failed")
    end
end

function BuildService:GetPlot(plots: Folder)
    for i, plot in pairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerId") == player.UserId then
            return plot
        end
    end

    return nil
end

function BuildService:SelectObject(name: string)
    if not Values.SessionActive then return end
    if not Values.CurrentPlotBase then return end

    ObjectService:StartPlacement(name)
end

function BuildService:SelectWall()
    WallService:StartPlacement(Values.Plot, 4)
end

function BuildService:SelectFloor()
    FloorService:StartPlacement(Values.Plot, 4)
end

function BuildService:RequestPlot(plotName: string)
    local success, plotAssigned = pcall(function()
        return buildRequest:InvokeServer("request_plot", plotName)
    end)

    if success and plotAssigned then
        Values.CurrentPlotModel = BuildService:GetPlot(plotsFolder)
        Values.CurrentPlotBase = Values.CurrentPlotModel:FindFirstChild("PlotBase")
    end
end

buildEvent.OnClientEvent:Connect(function(action: string, data: {any})
    
end)

-- Initialize values

Values.GridSize = Config.GRID_SIZES[1]
Values.GridSizes = Config.GRID_SIZES
Values.SnapAlpha = Config.LERP_ALPHA
Values.RotationSmoothing = Config.ROTATION_SMOOTHING
Values.PositionSmoothing = Config.POSITION_SMOOTHING
Values.ZoomSmoothing = Config.ZOOM_SMOOTHING
Values.PitchSmoothing = Config.PITCH_SMOOTHING
Values.CamMoveSpeed = Config.CAM_MOVE_SPEED
Values.CamRotateSpeed = Config.CAM_ROTATE_SPEED
Values.CamZoomSpeed = Config.CAM_ZOOM_SPEED
Values.CamMouseSensitivity = Config.CAM_MOUSE_SENSITIVITY
Values.CamHeightAbovePlot = Config.CAM_HEIGHT
Values.SmoothFreecam = Config.SMOOTH_FREECAM

return BuildService
