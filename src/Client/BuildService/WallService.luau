local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies (Adjust paths as needed for your project structure)
local RaycastService = require(script.Parent:WaitForChild("RaycastService"))
local PositioningService = require(script.Parent:WaitForChild("PositioningService"))

local WallService = {}

-- Private state variables
local isPlacing = false
local currentPlot: Model? = nil
local gridSize = 4
local wallThickness = 0.5
local wallHeight = 10
local poleSize = Vector3.new(wallHeight, wallThickness, wallThickness)

local startPoint: Vector3? = nil
local activePole1: BasePart? = nil
local activePole2: BasePart? = nil
local previewWall: BasePart? = nil

local renderConnection: RBXScriptConnection? = nil
local inputBeganConnection: RBXScriptConnection? = nil
local inputEndedConnection: RBXScriptConnection? = nil

-- Helper: Creates a standard visual pole
local function CreatePole(): BasePart
	local pole = Instance.new("Part")
	pole.Shape = Enum.PartType.Cylinder
	pole.Size = poleSize
	pole.Orientation = Vector3.new(0, 0, 90) -- Orient cylinder upright
	pole.Anchored = true
	pole.CanCollide = false
	pole.Material = Enum.Material.SmoothPlastic
	pole.Color = Color3.fromRGB(150, 150, 150)
    pole.Transparency = .5
	pole.Parent = workspace
	return pole
end

-- Helper: Creates a wall segment
local function CreateWall(): BasePart
	local wall = Instance.new("Part")
	wall.Anchored = true
	wall.CanCollide = false
	wall.Material = Enum.Material.SmoothPlastic
	wall.Color = Color3.fromRGB(200, 200, 200)
	wall.Parent = workspace
	return wall
end

-- Helper: Returns current snapped position on the plot based on mouse location
local function GetSnappedMousePosition(): Vector3?
	local raycastResult = RaycastService:GetMouseHitPosition()
	if not raycastResult or not currentPlot then return nil end

	return PositioningService:SnapToGrid(
		raycastResult.Position,
		Vector3.new(wallThickness, wallHeight, wallThickness),
		currentPlot,
		gridSize,
		true
	)
end

-- Helper: Updates position, orientation, and size of a wall between two points
local function UpdateWallBetweenPoints(wall: BasePart, p1: Vector3, p2: Vector3)
	local distance = (p1 - p2).Magnitude
	
	-- Keep wall floating height aligned with pole height center
	local centerPosition = (p1 + p2) / 2
	
	wall.Size = Vector3.new(wallThickness, wallHeight, distance)
	wall.CFrame = CFrame.lookAt(centerPosition, p2)
end

-- Per-frame update loop
local function OnRender()
	local currentPos = GetSnappedMousePosition()
	if not currentPos then return end

	if startPoint == nil then
		-- Phase 1: Moving initial pole with mouse
		if activePole1 then
			activePole1.Position = activePole1.Position:Lerp(currentPos, .06)
		end
	else
		-- Phase 2: Drawing wall from startPoint to current mouse position
		if activePole2 then
			activePole1.Position = activePole2.Position:Lerp(currentPos, .06)
		end
		if previewWall then
			UpdateWallBetweenPoints(previewWall, startPoint, currentPos)
		end
	end
end

-- Handles left-click press (locks Pole 1, starts Pole 2 + preview wall)
local function OnInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed or not isPlacing then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local currentPos = GetSnappedMousePosition()
		if not currentPos then return end

		startPoint = currentPos

		-- Lock Pole 1 visually
		if activePole1 then
			activePole1.Position = startPoint
            activePole1.Transparency = 0
		end

		-- Create Pole 2 and preview wall segment
		activePole2 = CreatePole()
		activePole2.Position = currentPos

		previewWall = CreateWall()
		previewWall.Transparency = 0.5
		UpdateWallBetweenPoints(previewWall, startPoint, currentPos)
	end
end

-- Handles left-click release (locks Pole 2, places solid wall, resets loop)
local function OnInputEnded(input: InputObject, gameProcessed: boolean)
	if not isPlacing or startPoint == nil then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local endPoint = GetSnappedMousePosition() or (activePole2 and activePole2.Position)

		if endPoint and (startPoint - endPoint).Magnitude > 0.1 then
			-- Solidify built wall
			local finalWall = CreateWall()
			finalWall.CanCollide = true
			finalWall.Color = Color3.fromRGB(150, 150, 150)
			UpdateWallBetweenPoints(finalWall, startPoint, endPoint)

            -- Solidify start pole
            if activePole1 then
                activePole1.CanCollide = true
                activePole1.Transparency = 0
                activePole1 = nil
            end

			-- Solidify end pole
			if activePole2 then
				activePole2.CanCollide = true
                activePole2.Transparency = 0
				activePole2 = nil
			end
		else
            if activePole1 then
                activePole1:Destroy()
                activePole1 = nil
            end

			-- Clean up active Pole 2 if placement distance was too small
			if activePole2 then
				activePole2:Destroy()
				activePole2 = nil
			end
		end

		-- Clean up temporary preview wall
		if previewWall then
			previewWall:Destroy()
			previewWall = nil
		end

		startPoint = nil
		activePole1 = CreatePole()
	end
end

-- Starts the wall placement mode
function WallService:StartPlacement(plot: Model, gridStep: number?)
	if isPlacing then self:StopPlacement() end

	isPlacing = true
	currentPlot = plot
	gridSize = gridStep or gridSize

	activePole1 = CreatePole()

	renderConnection = RunService.RenderStepped:Connect(OnRender)
	inputBeganConnection = UserInputService.InputBegan:Connect(OnInputBegan)
	inputEndedConnection = UserInputService.InputEnded:Connect(OnInputEnded)
end

-- Cancels wall placement mode and cleans up active preview parts
function WallService:StopPlacement()
	isPlacing = false
	startPoint = nil
	currentPlot = nil

	if renderConnection then renderConnection:Disconnect() end
	if inputBeganConnection then inputBeganConnection:Disconnect() end
	if inputEndedConnection then inputEndedConnection:Disconnect() end

	if activePole1 then activePole1:Destroy() activePole1 = nil end
	if activePole2 then activePole2:Destroy() activePole2 = nil end
	if previewWall then previewWall:Destroy() previewWall = nil end
end

return WallService