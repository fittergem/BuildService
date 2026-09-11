local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local FreecamService = {}

FreecamService.MoveSpeed = 50
FreecamService.RotateSpeed = 2
FreecamService.ZoomSpeed = 5
FreecamService.MouseSensitivity = .005
FreecamService.MinZoom = 10
FreecamService.MaxZoom = 100
FreecamService.HeightAbovePlot = 20
FreecamService.PositionSmoothing = 20
FreecamService.RotationSmoothing = 20
FreecamService.PitchSmoothing = 10
FreecamService.ZoomSmoothing = 10
FreecamService.IsCameraActive = false
FreecamService.Plot = nil

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local targetPos = Vector3.new()
local currentPos = targetPos

local targetYaw = 0
local currentYaw = targetYaw

local targetPitch = math.rad(-45)
local currentPitch = targetPitch

local targetZoom = 30
local currentZoom = targetZoom

local isTopView = false
local isRightMouseDown = false

-- Get bounding limits from the plot BasePart
local function GetPlotBounds()
	local size = FreecamService.Plot.Size
	local pos = FreecamService.Plot.Position
	return {
		minX = pos.X - size.X / 2,
		maxX = pos.X + size.X / 2,
		minZ = pos.Z - size.Z / 2,
		maxZ = pos.Z + size.Z / 2,
		minY = pos.Y + 5,
		maxY = pos.Y + FreecamService.MaxZoom
	}
end

local function ClampToPlot(position: Vector3): Vector3
	local bounds = GetPlotBounds()
	return Vector3.new(
		math.clamp(position.X, bounds.minX, bounds.maxX),
		math.clamp(position.Y, bounds.minY, bounds.maxY),
		math.clamp(position.Z, bounds.minZ, bounds.maxZ)
	)
end

local function CalculateBasePitch(zoom: number)
    -- Normalize zoom from 0 (at MIN_ZOOM) to 1 (at MAX_ZOOM)
	local alpha = (zoom - FreecamService.MinZoom) / (FreecamService.MaxZoom - FreecamService.MinZoom)
	alpha = math.clamp(alpha, 0, 1)

	-- Non-linear curve (cubic ease): stays close to 1 (-45 deg) until passing halfway,
	-- then drops sharply toward 0 (-5 deg) near MIN_ZOOM.
	local curvedAlpha = math.pow(alpha, 1)

	local minPitchDeg = -5   -- Almost parallel to plot base at MIN_ZOOM
	local maxPitchDeg = -45  -- Isometric angle at MAX_ZOOM

	local targetDeg = minPitchDeg + (maxPitchDeg - minPitchDeg) * curvedAlpha
	return math.rad(targetDeg)
end

local function UpdateCamera(dt: number)
	if not FreecamService.IsCameraActive then return end

	-- Movement vectors based on camera orientation
	local moveDir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Vector3.new(0, 0, -1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir += Vector3.new(0, 0, 1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir += Vector3.new(-1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Vector3.new(1, 0, 0) end

	-- Rotation inputs (Q / E)
	if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
		targetYaw -= FreecamService.RotateSpeed * dt
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.E) then
		targetYaw += FreecamService.RotateSpeed * dt
	end

    -- Top view input
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        isTopView = true
    else
        isTopView = false
    end

	-- Transform movement relative to camera rotation
	local rotationCFrame = CFrame.Angles(0, targetYaw, 0)
	local worldMove = rotationCFrame:VectorToWorldSpace(moveDir)
	
	if worldMove.Magnitude > 0 then
		worldMove = worldMove.Unit * FreecamService.MoveSpeed * dt
        targetPos = ClampToPlot(targetPos + worldMove)
    end

    -- 3. Calculate target pitch
	if isTopView then
		targetPitch = math.rad(-89.9) -- Top View (perpendicular)
	else
		targetPitch = CalculateBasePitch(currentZoom) -- Adaptive curve based on zoom
	end

    -- 4. Smooth interpolation per property
	local blendPos = 1 - math.exp(-FreecamService.PositionSmoothing * dt)
	local blendYaw = 1 - math.exp(-FreecamService.RotationSmoothing * dt)
	local blendPitch = 1 - math.exp(-FreecamService.PitchSmoothing * dt)
	local blendZoom = 1 - math.exp(-FreecamService.ZoomSmoothing * dt)
	
	currentPos = currentPos:Lerp(targetPos, blendPos)
	currentYaw = currentYaw + (targetYaw - currentYaw) * blendYaw
	currentPitch = currentPitch + (targetPitch - currentPitch) * blendPitch
	currentZoom = currentZoom + (targetZoom - currentZoom) * blendZoom

    -- Clamp current smooth position to keep bounds crisp during heavy lerping
	currentPos = ClampToPlot(currentPos)

	-- Calculate final CFrame with pitch and zoom offset
	local targetRotation = CFrame.Angles(0, currentYaw, 0) * CFrame.Angles(currentPitch, 0, 0)
	local cameraCFrame = CFrame.new(currentPos) * targetRotation * CFrame.new(0, 0, currentZoom)
	
	camera.CFrame = cameraCFrame
end

-- Input bindings for mouse interactions
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed or not FreecamService.IsCameraActive then return end

    -- Zooming with scroll wheel
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		targetZoom = math.clamp(targetZoom - (input.Position.Z * FreecamService.ZoomSpeed), FreecamService.MinZoom, FreecamService.MaxZoom)
	end

    -- Mouse drag rotation (Right Mouse Button)
	if input.UserInputType == Enum.UserInputType.MouseMovement and isRightMouseDown then
		targetYaw -= input.Delta.X * FreecamService.MouseSensitivity
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not FreecamService.IsCameraActive then return end

	-- Right Mouse Button Pressed
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	-- Right Mouse Button Released
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

-- Public functions to toggle the build camera mode
function FreecamService:EnableBuildCamera(plot: BasePart)
    FreecamService.Plot = plot
	FreecamService.IsCameraActive = true
	camera.CameraType = Enum.CameraType.Scriptable

	local initialPos = ClampToPlot(FreecamService.Plot.Position + Vector3.new(0, FreecamService.HeightAbovePlot, 0))
    targetPos = initialPos
    currentPos = initialPos

	RunService:BindToRenderStep("BuildCamUpdate", Enum.RenderPriority.Camera.Value + 1, UpdateCamera)
end

function FreecamService:DisableBuildCamera()
    isRightMouseDown = false
	FreecamService.IsCameraActive = false
	RunService:UnbindFromRenderStep("BuildCamUpdate")
	camera.CameraType = Enum.CameraType.Custom
end

return FreecamService