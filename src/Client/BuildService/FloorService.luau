local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RaycastService = require(script.Parent:WaitForChild("RaycastService"))
local PositioningService = require(script.Parent:WaitForChild("PositioningService"))

local FloorService = {}

-- Service Settings
local isPlacing = false
local currentPlot: Model? = nil
local gridSize = 4
local floorThickness = 0.5
local nodeSize = Vector3.new(1, 1, 1)

-- State variables
local nodes: { Vector3 } = {}
local nodeVisuals: { BasePart } = {}
local previewLines: { BasePart } = {}
local previewFloorModel: Model? = nil

local activeNode: BasePart? = nil

local renderConnection: RBXScriptConnection? = nil
local inputBeganConnection: RBXScriptConnection? = nil

--------------------------------------------------------------------------------
-- UTILITY & MATH HELPERS
--------------------------------------------------------------------------------

local function createNodeVisual(): BasePart
	local node = Instance.new("Part")
	node.Shape = Enum.PartType.Ball
	node.Size = nodeSize
	node.Anchored = true
	node.CanCollide = false
	node.Material = Enum.Material.Neon
	node.Color = Color3.fromRGB(0, 170, 255)
	node.Parent = workspace
	return node
end

local function getSnappedMousePosition(): Vector3?
	local raycastResult = RaycastService:GetMouseHitPosition()
	if not raycastResult or not currentPlot then return nil end

	return PositioningService:SnapToGrid(
		raycastResult.Position,
		nodeSize,
		currentPlot,
		gridSize,
		true
	)
end

-- Helper function to instantiate and position an individual right-angled wedge
local function createRightWedge(p1: Vector2, p2: Vector2, p3: Vector2, heightY: number): BasePart?
	local v1 = p2 - p1
	local v2 = p3 - p1

	local len1 = v1.Magnitude
	if len1 < 0.001 then return nil end

	local u1 = v1 / len1
	local len2 = v2:Dot(u1)
	local h2 = (v2 - u1 * len2).Magnitude
	if h2 < 0.001 then return nil end

	local wedge = Instance.new("WedgePart")
	wedge.Anchored = true
	wedge.CanCollide = true
	wedge.Material = Enum.Material.SmoothPlastic
	wedge.Color = Color3.fromRGB(180, 180, 180)

	-- Wedge Dimensions:
	-- Size.X = Floor Thickness (World Y-Height)
	-- Size.Y = Triangle Height (Horizontal Depth)
	-- Size.Z = Triangle Base Length (Horizontal Base)
	wedge.Size = Vector3.new(floorThickness, h2, len1)

	-- Keep direction vectors in 2D (Vector2) for 2D position math
	local heightDir2D = Vector2.new(-u1.Y, u1.X)

	-- Check winding order to face wedge correctly
	local cross = v1.X * v2.Y - v1.Y * v2.X
	if cross < 0 then
		heightDir2D = -heightDir2D
	end

	-- Center of the right-wedge box in 2D space
	local center2D = p1 + (v1 * 0.5) + (heightDir2D * (h2 * 0.5))
	local center3D = Vector3.new(center2D.X, heightY, center2D.Y)

	-- Convert 2D direction vectors to 3D for CFrame matrix construction
	local baseDir3D = Vector3.new(u1.X, 0, u1.Y)
	local heightDir3D = Vector3.new(heightDir2D.X, 0, heightDir2D.Y)

	-- Frame: Up Vector = World Y, Facing directions = Horizontal X/Z
	wedge.CFrame = CFrame.fromMatrix(center3D, Vector3.new(0, 1, 0), heightDir3D, baseDir3D)
	return wedge
end

-- Generates floor geometry for a triangular face defined by 3 2D points (A, B, C)
local function createTrianglePart(a: Vector2, b: Vector2, c: Vector2, heightY: number): { BasePart }
	local parts = {}

	-- Sort vertices by side length so p1-p2 is the longest edge (hypotenuse/base)
	local p1, p2, p3 = a, b, c
	if (b - a).Magnitude < (c - a).Magnitude then
		p1, p2, p3 = c, a, b
	end
	if (p2 - p1).Magnitude < (p3 - p1).Magnitude then
		p1, p2, p3 = p2, p3, p1
	end

	-- Project p3 onto the segment p1-p2 to find the split point (altitude base)
	local v = p2 - p1
	local u = v.Unit
	local d = (p3 - p1):Dot(u)
	local p4 = p1 + u * d

	-- Split into two right-angled wedges along the altitude (p3 -> p4)
	local w1 = createRightWedge(p1, p4, p3, heightY)
	local w2 = createRightWedge(p2, p4, p3, heightY)

	if w1 then
		w1.Parent = workspace
		table.insert(parts, w1)
	end
	if w2 then
		w2.Parent = workspace
		table.insert(parts, w2)
	end

	return parts
end

-- Triangulates an ordered polygon array into a set of floor wedges
local function triangulatePolygon(pointList: { Vector3 }): { BasePart }
	local parts = {}
	if #pointList < 3 then return parts end

	local yLevel = pointList[1].Y
	local verts: { Vector2 } = {}
	for _, p in ipairs(pointList) do
		table.insert(verts, Vector2.new(p.X, p.Z))
	end

	-- Simple Ear Clipping Algorithm
	local indices = {}
	for i = 1, #verts do table.insert(indices, i) end

	local function isEar(i1, i2, i3)
		local p1, p2, p3 = verts[indices[i1]], verts[indices[i2]], verts[indices[i3]]
		local cp = (p2.X - p1.X) * (p3.Y - p1.Y) - (p2.Y - p1.Y) * (p3.X - p1.X)
		if cp <= 0 then return false end -- Concave angle

		for idx = 1, #indices do
			if idx ~= i1 and idx ~= i2 and idx ~= i3 then
				local pt = verts[indices[idx]]
				-- Point-in-triangle check
				local d1 = (pt.X - p2.X) * (p1.Y - p2.Y) - (p1.X - p2.X) * (pt.Y - p2.Y)
				local d2 = (pt.X - p3.X) * (p2.Y - p3.Y) - (p2.X - p3.X) * (pt.Y - p3.Y)
				local d3 = (pt.X - p1.X) * (p3.Y - p1.Y) - (p3.X - p1.X) * (pt.Y - p1.Y)
				if (d1 >= 0 and d2 >= 0 and d3 >= 0) or (d1 <= 0 and d2 <= 0 and d3 <= 0) then
					return false
				end
			end
		end
		return true
	end

	local count = #indices
	local timeout = 0
	while count > 2 and timeout < 100 do
		timeout += 1
		local earFound = false
		for i = 1, count do
			local prevIdx = if i == 1 then count else i - 1
			local nextIdx = if i == count then 1 else i + 1

			if isEar(prevIdx, i, nextIdx) then
				local w = createTrianglePart(verts[indices[prevIdx]], verts[indices[i]], verts[indices[nextIdx]], yLevel)
				if w then table.insert(parts, w) end
				table.remove(indices, i)
				count -= 1
				earFound = true
				break
			end
		end
		if not earFound then break end
	end

	return parts
end

--------------------------------------------------------------------------------
-- PREVIEW RENDERING
--------------------------------------------------------------------------------

local function clearPreviews()
	if previewFloorModel then
		previewFloorModel:Destroy()
		previewFloorModel = nil
	end
	for _, line in ipairs(previewLines) do line:Destroy() end
	table.clear(previewLines)
end

local function drawLine(p1: Vector3, p2: Vector3): BasePart
	local dist = (p1 - p2).Magnitude
	local line = Instance.new("Part")
	line.Anchored = true
	line.CanCollide = false
	line.Material = Enum.Material.Neon
	line.Color = Color3.fromRGB(0, 255, 120)
	line.Size = Vector3.new(0.2, 0.2, dist)
	line.CFrame = CFrame.lookAt((p1 + p2) / 2, p2)
	line.Parent = workspace
	return line
end

local function updatePreviews(currentMousePos: Vector3)
	clearPreviews()

	local currentPolygon = table.clone(nodes)
	table.insert(currentPolygon, currentMousePos)

	-- Draw boundary preview lines connecting placed points and active mouse
	for i = 1, #currentPolygon do
		local nextI = if i == #currentPolygon then 1 else i + 1
		table.insert(previewLines, drawLine(currentPolygon[i], currentPolygon[nextI]))
	end

	-- Draw live polygon mesh preview if 3 or more points exist
	if #currentPolygon >= 3 then
		local previewParts = triangulatePolygon(currentPolygon)
		previewFloorModel = Instance.new("Model")
		for _, part in ipairs(previewParts) do
			part.Transparency = 0.5
			part.CanCollide = false
			part.Parent = previewFloorModel
		end
		previewFloorModel.Parent = workspace
	end
end

local function onRender()
	local pos = getSnappedMousePosition()
	if not pos then return end

	if activeNode then
		activeNode.Position = pos
	end

	updatePreviews(pos)
end

--------------------------------------------------------------------------------
-- INPUT HANDLERS
--------------------------------------------------------------------------------

local function onInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed or not isPlacing then return end

	-- Left Click: Place node
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local pos = getSnappedMousePosition()
		if not pos then return end

		table.insert(nodes, pos)

		local placedNode = createNodeVisual()
		placedNode.Position = pos
		placedNode.Color = Color3.fromRGB(100, 255, 100)
		table.insert(nodeVisuals, placedNode)

	-- Right Click / Enter Key: Finalize floor construction
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Return then
		FloorService:FinalizeFloor()
	end
end

--------------------------------------------------------------------------------
-- SERVICE PUBLIC METHODS
--------------------------------------------------------------------------------

function FloorService:StartPlacement(plot: Model, gridStep: number?)
	if isPlacing then self:StopPlacement() end

	isPlacing = true
	currentPlot = plot
	gridSize = gridStep or gridSize

	activeNode = createNodeVisual()

	renderConnection = RunService.RenderStepped:Connect(onRender)
	inputBeganConnection = UserInputService.InputBegan:Connect(onInputBegan)
end

function FloorService:FinalizeFloor(): Model?
	if #nodes < 3 then
		warn("FloorService: Minimum of 3 points required to generate a floor.")
		return nil
	end

	-- Build permanent floor geometry
	local floorParts = triangulatePolygon(nodes)
	local floorModel = Instance.new("Model")
	floorModel.Name = "BuiltFloor"

	for _, part in ipairs(floorParts) do
		part.Transparency = 0
		part.CanCollide = true
		part.Color = Color3.fromRGB(160, 160, 160)
		part.Parent = floorModel
	end
	floorModel.Parent = workspace

	-- Reset current node session to allow building another floor immediately
	self:ResetSession()

	return floorModel
end

function FloorService:ResetSession()
	nodes = {}
	for _, vis in ipairs(nodeVisuals) do vis:Destroy() end
	table.clear(nodeVisuals)
	clearPreviews()
end

function FloorService:StopPlacement()
	isPlacing = false
	currentPlot = nil

	if renderConnection then renderConnection:Disconnect() end
	if inputBeganConnection then inputBeganConnection:Disconnect() end

	if activeNode then activeNode:Destroy() activeNode = nil end
	self:ResetSession()
end

return FloorService