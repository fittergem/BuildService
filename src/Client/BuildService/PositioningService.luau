local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PositioningService = {}

local Values = require(script.Parent:WaitForChild("Values"))
local Checks = require(ReplicatedStorage:WaitForChild("BuildChecks"))

function PositioningService:SnapToGrid(hitPos: Vector3)
    if not Values.CurrentPlotBase then return end

	local objectSize

	if Values.SelectedObject:IsA("Model") then
		objectSize = Values.SelectedObject:GetExtentsSize()
	elseif Values.SelectedObject:IsA("BasePart") then
		objectSize = Values.SelectedObject.Size
	end

	local cframe = Values.CurrentPlotBase.CFrame
	local size = Values.CurrentPlotBase.Size
	
	-- Convert global position to basePart local space
	local localPos = cframe:PointToObjectSpace(hitPos)
	
	-- Centering offset for uneven grid divisions
	local offsetX = (size.X % Values.GridSize) / 2
	local offsetZ = (size.Z % Values.GridSize) / 2
	
	-- Snap local position to nearest grid point
	local snappedX = math.floor((localPos.X - offsetX) / Values.GridSize + 0.5) * Values.GridSize + offsetX
	local snappedZ = math.floor((localPos.Z - offsetZ) / Values.GridSize + 0.5) * Values.GridSize + offsetZ
	
	-- Place the object resting on top of the basePart surface
	local snappedY = (size.Y / 2) + (objectSize.Y / 2)
	
	-- Clamp so the object's edges stay inside the plot boundaries
	if Values.Bounds then
		-- Maximum local extent allowed for the object's center point
		local limitX = (size.X / 2) - (objectSize.X / 2)
		local limitZ = (size.Z / 2) - (objectSize.Z / 2)
		
		-- Ensure limits stay valid if object is larger than the plot
		limitX = math.max(0, limitX)
		limitZ = math.max(0, limitZ)

		snappedX = math.clamp(snappedX, -limitX, limitX)
		snappedZ = math.clamp(snappedZ, -limitZ, limitZ)
	end

	local fianlCFrame = CFrame.new(snappedX, snappedY, snappedZ)
	
	if Values.SmoothSnapping then
		Values.SelectedObject:PivotTo(Values.SelectedObject:GetPivot():Lerp(fianlCFrame, Values.SnapAlpha))
		return true
	else
		Values.SelectedObject:PivotTo(fianlCFrame)
		return true
	end
end

return PositioningService