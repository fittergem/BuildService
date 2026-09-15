local Values = {}

-- NOTE: THESE VALUES ARE ALL PLACEHOLDERS
-- These values are updated when a new client joins with the correct default values from the BuildConfig.luau module
-- These values get updated and are dynamic

-- TL;DR: Values are not constant. Values are updated constantly.

-- Locations
Values.ObjectsFolder = nil
Values.PlotsFolder = nil

-- Session Values
Values.SessionActive = false
Values.FreecamActive = false
Values.CurrentPlaceMode = "None" -- "None" | "Object" | "Wall" | "Floor" | "Roof"
Values.SelectedObject = nil
Values.CurrentPlotModel = nil
Values.CurrentPlotBase = nil

Values.GridSize = 4 -- In studs
Values.GridSizes = {4, 2, 1}
Values.CurrentLevel = 0

Values.GridEnabled = true
Values.Collisions = true
Values.Bounds = true

-- Lerp Alpha
Values.SmoothSnapping = true

Values.SnapAlpha = .05

-- Smoothing (Higher numbers = faster response / less "momentum")
Values.RotationSmoothing = 20
Values.PositionSmoothing = 20
Values.ZoomSmoothing = 10
Values.PitchSmoothing = 10

-- Keybinds
Values.MoveCamForward = Enum.KeyCode.W
Values.MoveCamBackward = Enum.KeyCode.S
Values.MoveCamLeft = Enum.KeyCode.A
Values.MoveCamRight = Enum.KeyCode.D

Values.RotateCamLeft = Enum.KeyCode.Q
Values.RotateCamRight = Enum.KeyCode.E

Values.CamTopView = Enum.KeyCode.Space

Values.Rotate = Enum.KeyCode.R
Values.Paint = Enum.KeyCode.F
Values.Copy = Enum.KeyCode.C
Values.Delete = Enum.KeyCode.G
Values.Transform = Enum.KeyCode.T

-- Freecam
Values.SmoothFreecam = true

Values.CamMoveSpeed = 50
Values.CamRotateSpeed = 2
Values.CamZoomSpeed = 5
Values.CamMouseSensitivity = .005
Values.MinCamZoom = 10
Values.MaxCamZoom = 100
Values.CamHeightAbovePlot = 20 -- In studs

return Values