local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local Signal = require(ReplicatedStorage:WaitForChild("GoodSignal"))

local BuildChecks = require(ReplicatedStorage:WaitForChild("BuildChecks"))
local buildEvent = ReplicatedStorage:WaitForChild("BuildEvent")

local RaycastService = require(script:WaitForChild("RaycastService"))
local PositioningService = require(script:WaitForChild("PositioningService"))

local BuildService = {}

BuildService.ActiveSession = false
BuildService.CurrentObject = nil
BuildService.Plot = nil

BuildService.Warning = Signal.new()

BuildService.GridSize = 4 -- In studs
BuildService.GridEnabled = true -- Snaps positions to the above grid size
BuildService.BoundsEnabled = true -- Prevents placement outside of plot

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
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    --camera.CameraType = Enum.CameraType.Scriptable

    RunService:BindToRenderStep("PlacementSession", Enum.RenderPriority.Camera.Value + 1, function()
        if BuildService.CurrentObject == nil then return end
        if BuildService.Plot == nil then return end

        params.FilterDescendantsInstances = {BuildService.CurrentObject}

        local startCFrame = BuildService.CurrentObject:GetPivot()
        local objectSize = BuildService.CurrentObject:GetExtentsSize()

        local raycastResult = RaycastService:GetMouseHitPosition(params)
        local hitPos = startCFrame.Position
        
        if raycastResult then
            hitPos = raycastResult.Position
        end

        local snappedPos = PositioningService:SnapToGrid(hitPos, objectSize, BuildService.Plot, BuildService.GridSize, BuildService.BoundsEnabled)
        local snappedCFrame = CFrame.new(snappedPos)

        local newCFrame = startCFrame:Lerp(snappedCFrame, .05)
        BuildService.CurrentObject:PivotTo(newCFrame)
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
