local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ObjectService = {}

local RaycastService = require(script.Parent:WaitForChild("RaycastService"))
local PositioningService = require(script.Parent:WaitForChild("PositioningService"))
local Values = require(script.Parent:WaitForChild("Values"))
local Checks = require(ReplicatedStorage:WaitForChild("BuildChecks"))

local buildRequest = ReplicatedStorage:WaitForChild("BuildRequest")

function ObjectService:ApplyHighlight(object: Model)
    local highlight = Instance.new("Highlight", object)
    highlight.FillColor = Color3.new(1,1,1)
    highlight.FillTransparency = .75
    highlight.OutlineTransparency = 1
end

function ObjectService:ChangeHighlightColor(object: Model, color: Color3)
    local highlight = object:FindFirstChildOfClass("Highlight")

    if not highlight then
        return false
    end

    highlight.FillColor = color
    return true
end

function ObjectService:StartPlacement(objectName: string)
    if Values.Plot == nil then
        return false, "Plot is nil"
    end

    local reference = Values.ObjectsFolder:FindFirstChild(objectName)

    if not reference then
        return false, "Object with name '" .. objectName .. "' does not exist in objects folder"
    end

    local object = reference:Clone()
    object.Parent = ObjectService.Plot
    ObjectService:ApplyHighlight(object)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {object}
    params.FilterType = Enum.RaycastFilterType.Exclude

    Values.SessionActive = true
    Values.CurrentPlaceMode = "Object"
    Values.SelectedObject = object

    RunService:BindToRenderStep("ObjectPlacement", Enum.RenderPriority.Camera.Value + 1, function()
        if not Values.SessionActive then
            if Values.SelectedObject == nil then return end
            Values.SelectedObject:Destroy()
            return false, "Placement session not active"
        end

        if not Values.CurrentPlaceMode == "Object" then
            return false, "Place mode is not set to 'Object'"
        end

        local raycastResult = RaycastService:GetMouseHitPosition(params)
        local hitPos = Values.SelectedObject:GetPivot().Position
        
        if raycastResult then
            hitPos = raycastResult.Position
        end

        local success, warning = PositioningService:SnapToGrid(hitPos)

        if not success then
            return warning
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
            RunService:UnbindFromRenderStep("ObjectPlacement")

            local placed = buildRequest:InvokeServer("request_object_placement", {Name = objectName, CFrame = object:GetPivot()})

            if placed then
                object:Destroy()
                Values.SessionActive = false
            else
                return false, "Object with name '" .. objectName .. "' was not placed. An error occured."
            end
        end
    end)
end

function ObjectService:CancelPlacement()
    RunService:UnbindFromRenderStep("PlacementSession")

    if Values.SelectedObject ~= nil then
        Values.SelectedObject:Destroy()
        Values.SelectedObject = nil
    end

    Values.SessionActive = false
    Values.CurrentPlaceMode = "None"
end

return ObjectService