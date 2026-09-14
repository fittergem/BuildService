local PositioningService = {}

local Values = require(script.Parent:WaitForChild("Values"))

function PositioningService:SnapToGrid(position: Vector3 | CFrame, objectSize: Vector3, plot: Model, gridSize: number, bounds: boolean?)
    if bounds == nil then bounds = true end

    local basePart = plot:WaitForChild("PlotBase")
    local position = typeof(position) == "CFrame" and position.Position or position

	local cframe = basePart.CFrame
	local size = basePart.Size
	
	-- Convert global position to basePart local space
	local localPos = cframe:PointToObjectSpace(position)
	
	-- Centering offset for uneven grid divisions
	local offsetX = (size.X % gridSize) / 2
	local offsetZ = (size.Z % gridSize) / 2
	
	-- Snap local position to nearest grid point
	local snappedX = math.floor((localPos.X - offsetX) / gridSize + 0.5) * gridSize + offsetX
	local snappedZ = math.floor((localPos.Z - offsetZ) / gridSize + 0.5) * gridSize + offsetZ
	
	-- Place the object resting on top of the basePart surface
	local snappedY = (size.Y / 2) + (objectSize.Y / 2)
	
	-- Clamp so the object's edges stay inside the plot boundaries
	if bounds then
		-- Maximum local extent allowed for the object's center point
		local limitX = (size.X / 2) - (objectSize.X / 2)
		local limitZ = (size.Z / 2) - (objectSize.Z / 2)
		
		-- Ensure limits stay valid if object is larger than the plot
		limitX = math.max(0, limitX)
		limitZ = math.max(0, limitZ)

		snappedX = math.clamp(snappedX, -limitX, limitX)
		snappedZ = math.clamp(snappedZ, -limitZ, limitZ)
	end
	
	-- Transform back to world space
	return cframe:PointToWorldSpace(Vector3.new(snappedX, snappedY, snappedZ))
end

return PositioningService