local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local BuildService = {}

local Signal = require(ReplicatedStorage:WaitForChild("GoodSignal"))
BuildService.Error = Signal.new()
BuildService.Warning = Signal.new()
BuildService.Collision = Signal.new()


-- Ensure the config module is loaded
local function GetConfig()
    local config = ReplicatedStorage:WaitForChild("BuildConfig", 10)

    -- Recursive locator
    if not config then
        BuildService.Warning:Fire("Configuration module not found. Retrying...")
        task.wait(1)
        return GetConfig()
    end

    local success, result = pcall(require, config)

    -- Ensure data is loaded properly
    if success and type(result) == "table" and next(result) ~= nil then
        return result
    else
        BuildService.Warning:Fire("Failed to load configuration table. Retrying...")
        task.wait(1)
        return GetConfig()
    end
end

local Config = GetConfig()

local BuildChecks = require(ReplicatedStorage:WaitForChild("BuildChecks"))
local buildEvent = ReplicatedStorage:WaitForChild("BuildEvent")
local buildRequest = ReplicatedStorage:WaitForChild("BuildRequest")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local plotsFolder = Workspace:WaitForChild("BuildPlots")
local objectsFolder = ReplicatedStorage:WaitForChild("BuildObjects")

-- Session variables
local sessionActive = false
local placementMode = "None"
local currentObject = nil

local plot = nil
local plotBase = nil

-- Freecam variables
local freecamActive = false

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

local inputConnection: RBXScriptSignal? = nil

-- Config-based variables
local camHeight = Config.CAM_HEIGHT

local maxCamZoom = Config.MAX_CAM_ZOOM
local minCamZoom = Config.MIN_CAM_ZOOM

local camMoveSpeed = Config.CAM_MOVE_SPEED
local camRotateSpeed = Config.CAM_ROTATE_SPEED
local camZoomSpeed = Config.CAM_ZOOM_SPEED
local camMouseSensitivity = Config.CAM_MOUSE_SENSITIVITY

local smoothFreecam = Config.SMOOTH_FREECAM
local camPosSmoothing = Config.POSITION_SMOOTHING
local camYawSmoothing = Config.ROTATION_SMOOTHING
local camPitchSmoothing = Config.PITCH_SMOOTHING
local camZoomSmoothing = Config.ZOOM_SMOOTHING

local gridSize = Config.GRID_SIZES[1]
local smoothSnapping = Config.SMOOTH_SNAPPING
local snapAlpha = Config.SNAP_ALPHA
local boundsEnabled = Config.BOUNDS_ENABLED

-- Get bounding limits from the plot BasePart
local function GetFreecamBounds()
	local size = plotBase.Size
	local pos = plotBase.Position
	return {
		minX = pos.X - size.X / 2,
		maxX = pos.X + size.X / 2,
		minZ = pos.Z - size.Z / 2,
		maxZ = pos.Z + size.Z / 2,
		minY = pos.Y + 5,
		maxY = pos.Y + maxCamZoom
	}
end

local function ClampCamToPlot(position: Vector3): Vector3
	local bounds = GetFreecamBounds()
	return Vector3.new(
		math.clamp(position.X, bounds.minX, bounds.maxX),
		math.clamp(position.Y, bounds.minY, bounds.maxY),
		math.clamp(position.Z, bounds.minZ, bounds.maxZ)
	)
end

local function CalculateBasePitch(zoom: number)
    -- Normalize zoom from 0 (at MIN_ZOOM) to 1 (at MAX_ZOOM)
	local alpha = (zoom - minCamZoom) / (maxCamZoom - minCamZoom)
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
	if not freecamActive then return end

	-- Movement vectors based on camera orientation
	local moveDir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Vector3.new(0, 0, -1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir += Vector3.new(0, 0, 1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir += Vector3.new(-1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Vector3.new(1, 0, 0) end

	-- Rotation inputs (Q / E)
	if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
		targetYaw -= camRotateSpeed * dt
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.E) then
		targetYaw += camRotateSpeed * dt
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
		worldMove = worldMove.Unit * camMoveSpeed * dt
        targetPos = ClampCamToPlot(targetPos + worldMove)
    end

    -- 3. Calculate target pitch
	if isTopView then
		targetPitch = math.rad(-89.9) -- Top View (perpendicular)
	else
		targetPitch = CalculateBasePitch(currentZoom) -- Adaptive curve based on zoom
	end

    -- 4. Smooth interpolation per property
	local blendPos = 1 - math.exp(-camPosSmoothing * dt)
	local blendYaw = 1 - math.exp(-camYawSmoothing * dt)
	local blendPitch = 1 - math.exp(-camPitchSmoothing * dt)
	local blendZoom = 1 - math.exp(-camZoomSmoothing * dt)
	
    if smoothFreecam then
        currentPos = currentPos:Lerp(targetPos, blendPos)
        currentYaw = currentYaw + (targetYaw - currentYaw) * blendYaw
        currentPitch = currentPitch + (targetPitch - currentPitch) * blendPitch
        currentZoom = currentZoom + (targetZoom - currentZoom) * blendZoom
    else
        currentPos = targetPos
        currentYaw = currentYaw + (targetYaw - currentYaw)
        currentPitch = currentPitch + (targetPitch - currentPitch)
        currentZoom = currentZoom + (targetZoom - currentZoom)
    end

    -- Clamp current smooth position to keep bounds crisp during heavy lerping
	currentPos = ClampCamToPlot(currentPos)

	-- Calculate final CFrame with pitch and zoom offset
	local targetRotation = CFrame.Angles(0, currentYaw, 0) * CFrame.Angles(currentPitch, 0, 0)
	local cameraCFrame = CFrame.new(currentPos) * targetRotation * CFrame.new(0, 0, currentZoom)
	
	camera.CFrame = cameraCFrame
end

local function EnableBuildCamera()
    freecamActive = true
	camera.CameraType = Enum.CameraType.Scriptable

	local initialPos = ClampCamToPlot(plotBase.Position + Vector3.new(0, camHeight, 0))
    targetPos = initialPos
    currentPos = initialPos

	RunService:BindToRenderStep("BuildCamUpdate", Enum.RenderPriority.Camera.Value + 1, UpdateCamera)
end

local function DisableBuildCamera()
    isRightMouseDown = false
	freecamActive = false
	RunService:UnbindFromRenderStep("BuildCamUpdate")
	camera.CameraType = Enum.CameraType.Custom
end

local function HighlightObject(object: Model)
    local highlight = Instance.new("Highlight", object)
    highlight.FillColor = Color3.new(1,1,1)
    highlight.FillTransparency = .75
    highlight.OutlineTransparency = 1
    return highlight
end

local function Raycast(x: number, y: number, params: RaycastParams?)
    local unitRay = camera:ViewportPointToRay(x, y)
    return Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
end

local function GetMouseHitPosition(params: RaycastParams)
    local mouse = UserInputService:GetMouseLocation()
    local result = Raycast(mouse.X, mouse.Y, params)

    return result
end

local function CheckCollisions()
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = {currentObject, plotBase}

    if currentObject:IsA("Model") then
        local cframe, size = currentObject:GetBoundingBox()
        local parts = Workspace:GetPartBoundsInBox(cframe, size, overlapParams)
        return #parts > 0
    elseif currentObject:IsA("BasePart") then
        local parts = Workspace:GetPartsInPart(currentObject, overlapParams)
        return #parts > 0
    end

    return false
end

local function SnapToGrid(hitPos: Vector3)
    if not plotBase or not currentObject then
        BuildService.Warning:Fire("Plot base or object is missing")
        return
    end

	local objectSize = currentObject:IsA("Model") and currentObject:GetExtentsSize() or currentObject.Size

	local cframe = plotBase.CFrame
	local size = plotBase.Size
	
	-- Convert global position to basePart local space
	local localPos = cframe:PointToObjectSpace(hitPos)
	
	-- Centering offset for uneven grid divisions
	local offsetX = (size.X % gridSize) / 2
	local offsetZ = (size.Z % gridSize) / 2
	
	-- Snap local position to nearest grid point
	local snappedX = math.floor((localPos.X - offsetX) / gridSize + 0.5) * gridSize + offsetX
	local snappedZ = math.floor((localPos.Z - offsetZ) / gridSize + 0.5) * gridSize + offsetZ
	
	-- Place the object resting on top of the basePart surface
	local snappedY = (size.Y / 2) + (objectSize.Y / 2)
	
	-- Clamp so the object's edges stay inside the plot boundaries
	if boundsEnabled then
		-- Maximum local extent allowed for the object's center point
		local limitX = math.max(0, (size.X / 2) - (objectSize.X / 2))
		local limitZ = math.max(0, (size.Z / 2) - (objectSize.Z / 2))

		snappedX = math.clamp(snappedX, -limitX, limitX)
		snappedZ = math.clamp(snappedZ, -limitZ, limitZ)
	end

	local finalCFrame = cframe * CFrame.new(snappedX, snappedY, snappedZ)
	
	if smoothSnapping then
		currentObject:PivotTo(currentObject:GetPivot():Lerp(finalCFrame, snapAlpha))
	else
		currentObject:PivotTo(finalCFrame)
	end
end

local function StopObjectPlacement()
    RunService:UnbindFromRenderStep("ObjectPlacement")

    if inputConnection then
        inputConnection:Disconnect()
        inputConnection = nil
    end

    if currentObject then
        currentObject:Destroy()
        currentObject = nil
    end

    placementMode = "None"
end

local function StartObjectPlacement(objectName: string)
    if not sessionActive then
        BuildService.Warning:Fire("Build session is not active. Placement attempt failed")
        return
    end

    if plotBase == nil then
        BuildService.Warning:Fire("Plot is nil")
        return
    end

    local reference = objectsFolder:FindFirstChild(objectName)

    if not reference then
        BuildService.Warning:Fire("Object with name '" .. objectName .. "' does not exist in objects folder")
        return
    end

    if inputConnection then inputConnection:Disconnect() end

    local object = reference:Clone()
    object.Parent = plot
    local highlight = HighlightObject(object)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {object}
    params.FilterType = Enum.RaycastFilterType.Exclude

    placementMode = "Object"
    currentObject = object

    local isColliding = false

    RunService:BindToRenderStep("ObjectPlacement", Enum.RenderPriority.Camera.Value + 1, function()
        if not sessionActive or placementMode ~= "Object" or not currentObject then
            StopObjectPlacement()
            return
        end

        local raycastResult = GetMouseHitPosition(params)
        local hitPos = raycastResult and raycastResult.Position or currentObject:GetPivot().Position

        SnapToGrid(hitPos)

        isColliding = CheckCollisions()

        if isColliding then
            highlight.FillColor = Color3.new(1,0,0)
        else
            highlight.FillColor = Color3.new(1,1,1)
        end
    end)

    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
            if isColliding then
                BuildService.Warning:Fire("Cannot place object: Object is colliding")
                return
            end

            local targetCFrame = currentObject:GetPivot()

            RunService:UnbindFromRenderStep("ObjectPlacement")

            if inputConnection then
                inputConnection:Disconnect()
                inputConnection = nil
            end

            local placed = buildRequest:InvokeServer("request_object_placement", {Name = objectName, CFrame = targetCFrame})

            if placed then
                object:Destroy()
                currentObject = nil
            else
                BuildService.Warning:Fire("Object placement failed on server")
                return
            end
        end
    end)
end

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

local function StopWallPlacement()
    isPlacing = false
	startPoint = nil

	if renderConnection then renderConnection:Disconnect() end
	if inputBeganConnection then inputBeganConnection:Disconnect() end
	if inputEndedConnection then inputEndedConnection:Disconnect() end

	if activePole1 then activePole1:Destroy() activePole1 = nil end
	if activePole2 then activePole2:Destroy() activePole2 = nil end
	if previewWall then previewWall:Destroy() previewWall = nil end
end

local function StartWallPlacement()
    if not sessionActive then
        BuildService.Warning:Fire("Build session is not active. Placement attempt failed")
        return
    end

    if plotBase == nil then
        BuildService.Warning:Fire("Plot is nil")
        return
    end

    if isPlacing then self:StopPlacement() end

	isPlacing = true
	gridSize = gridStep or gridSize

	activePole1 = CreatePole()

	renderConnection = RunService.RenderStepped:Connect(OnRender)
	inputBeganConnection = UserInputService.InputBegan:Connect(OnInputBegan)
	inputEndedConnection = UserInputService.InputEnded:Connect(OnInputEnded)
end

local function StartSession()
    sessionActive = true
    EnableBuildCamera()
end

local function EndSession()
    DisableBuildCamera()
    StopObjectPlacement()

    sessionActive = false
        
    RunService:UnbindFromRenderStep("PlacementSession")

    if currentObject ~= nil then
        currentObject:Destroy()
        currentObject = nil
    end
end

-- Request to start a new session
function BuildService:RequestSessionStart()
    -- Ensure a plot is selected and has a plot base part
    if not plotBase then
        BuildService.Warning:Fire("Plot not selected")
        return
    end

    -- Request from the server to start a build session
    local success, start = pcall(function()
        return buildRequest:InvokeServer("start_session")
    end)

    -- Respond to server response
    if success and start then
        StartSession()
    else
        BuildService.Warning:Fire("Request to start placement session failed")
    end
end

-- Request to cancel the session
function BuildService:RequestSessionCancel()
    local success, ended = pcall(function()
        return buildRequest:InvokeServer("stop_session")
    end)

    if success and ended then
        EndSession()
    else
        BuildService.Warning:Fire("Request to terminate placement session failed")
    end
end

-- Finds the plot of the player (Returns nil if not found)
function BuildService:GetPlot()
    for i, v in pairs(plotsFolder:GetChildren()) do
        if v:GetAttribute("OwnerId") == player.UserId then
            return v
        end
    end

    return nil
end

-- Request a plot for the player (Either random or by name)
function BuildService:RequestPlot(plotName: string?)
    local success, plotAssigned = pcall(function()
        return buildRequest:InvokeServer("request_plot", plotName)
    end)

    -- Get the plot if assigned
    if success and plotAssigned then
        local result = BuildService:GetPlot()

        if result then
            plot = result
            plotBase = plot:FindFirstChild("PlotBase")

            if not plotBase then
                BuildService.Warning:Fire("Plot base for plot '" .. plot.Name .. "' not found")
            end

        else
            BuildService.Warning:Fire("Plot not available")
        end
    else
        BuildService.Warning:Fire("Plot was not assigned")
    end
end

function BuildService:SelectObject(name: string)
    StartObjectPlacement(name)
end

function BuildService:SelectWall()
    StartWallPlacement()
end

function BuildService:SelectFloor()
    
end

buildEvent.OnClientEvent:Connect(function(action: string, data: {any})
    
end)

-- Input bindings
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed or not freecamActive then return end

    -- Zooming with scroll wheel
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		targetZoom = math.clamp(targetZoom - (input.Position.Z * camZoomSpeed), minCamZoom, maxCamZoom)
	end

    -- Mouse drag rotation (Right Mouse Button)
	if input.UserInputType == Enum.UserInputType.MouseMovement and isRightMouseDown then
		targetYaw -= input.Delta.X * camMouseSensitivity
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not freecamActive then return end

	-- Right Mouse Button Pressed
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

UserInputService.InputEnded:Connect(function(input)
	-- Right Mouse Button Released
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

return BuildService
