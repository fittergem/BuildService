local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ObjectService = {}

local RaycastService = require(script.Parent:WaitForChild("RaycastService"))
local PositioningService = require(script.Parent:WaitForChild("PositioningService"))
local Values = require(script.Parent:WaitForChild("Values"))

local objectsFolder = ReplicatedStorage:WaitForChild("BuildObjects")

local buildRequest = ReplicatedStorage:WaitForChild("BuildRequest")

function ObjectService:Highlight(object: Model)
    local highlight = Instance.new("Highlight", object)
    highlight.FillColor = Color3.new(1,1,1)
    highlight.FillTransparency = .75
    highlight.OutlineTransparency = 1
end

function ObjectService:StartPlacement(objectName: string)
    if Values.Plot == nil then
        warn("[BuildService] - Plot is nil")
        return
    end

    local reference = objectsFolder:FindFirstChild(objectName)

    if not reference then
        warn("[BuildService] - Object with name '" .. objectName .. "' does not exist in objects folder")
        return
    end

    local object = reference:Clone()
    object.Parent = ObjectService.Plot
    ObjectService:Highlight(object)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {object}
    params.FilterType = Enum.RaycastFilterType.Exclude

    Values.SessionActive = true
    Values.CurrentPlaceMode = "Object"
    Values.SelectedObject = object

    RunService:BindToRenderStep("ObjectPlacement", Enum.RenderPriority.Camera.Value + 1, function()
        if not Values.SessionActive then
            object:Destroy()
            return
        end

        local raycastResult = RaycastService:GetMouseHitPosition(params)
        local hitPos = startCFrame.Position
        
        if raycastResult then
            hitPos = raycastResult.Position
        end

        local snappedPos = PositioningService:SnapToGrid(hitPos)
        local snappedCFrame = CFrame.new(snappedPos)

        local newCFrame = startCFrame:Lerp(snappedCFrame, .05)
        object:PivotTo(newCFrame)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
            RunService:UnbindFromRenderStep("ObjectPlacement")

            local placed = buildRequest:InvokeServer("request_object_placement", {Name = objectName, CFrame = object:GetPivot()})

            if placed then
                object:Destroy()
                Values.SessionActive = false
            else
                warn("[BuildService] - Object with name '" .. objectName .. "' was not placed. An error occured.")
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