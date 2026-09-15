local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = {}

-- NOTE: THESE ARE ALL DEFAULT VALUES
-- Most values can be updated per-player by updating the Values.luau module
-- For example, customizing keybinds, smooth snapping, freecam settings, etc. can all be done by updating the Values.luau module
-- This module is for DEFAULT values or server-defined unchangeables (Constants)

-- Locations
Config.OBJECTS_FOLDER = ReplicatedStorage:WaitForChild("BuildObjects")
Config.PLOTS_FOLDER = Workspace:WaitForChild("BuildPlots")

-- Server constants
Config.GRID_SIZES = {4, 2, 1}           -- In studs (First entry is the default size)
Config.GRID_TEXTURE_ID = 0              -- ID of the grid texture
Config.ALLOW_GRID_TOGGLE = false        -- Allow players to toggle the grid on and off
Config.GRID_TOGGLE_GAMEPASS = 0         -- ID of the gamepass required to turn the grid off (Only works if ALLOW_GRID_TOGGLE is true. Leave 0 for no gamepass)

Config.BOUNDS_ENABLED = true            -- Allows players to build outside of the plot
Config.ALLOW_DISABLED_BOUNDS = false    -- Allow players to turn bounds off even if bounds are enabled (Would allow players to build outside the plot)
Config.BOUNDS_TOGGLE_GAMEPASS = 0       -- ID of the gamepass required to turn bounds off (Only works if ALLOW_BOUNDS_DISABLE is true. Leave 0 for no gamepass)

Config.ALLOW_COLLISIONS_OFF = true      -- Allow object collisions to be turned off
Config.COLLISIONS_TOGGLE_GAMEPASS = 0   -- ID of the gamepass required to turn collisions off (Leave 0 for no gamepass)

Config.BASEMENT_LEVELS = 1              -- Number of levels below the main floor players can go
Config.BASEMENT_GAMEPASS = 0            -- ID of gamepass required to build in basement levels (Leave 0 for no gamepass)

Config.UPPER_LEVELS = 4                 -- Number of levels above the main floor players can go
Config.UPPER_LEVELS_GAMEPASS = 0        -- ID of gamepass required to build on upper levels (Leave 0 for no gamepass)

-- Smoothing (Higher values = faster response / less "momentum")
Config.POSITION_SMOOTHING = 20
Config.ROTATION_SMOOTHING = 20
Config.PITCH_SMOOTHING = 10
Config.ZOOM_SMOOTHING = 10

Config.SMOOTH_FREECAM = true            -- If enabled, freecam will have simulated momentum and feel smoother

Config.LERP_ALPHA = .05                 -- The alpha value of the lerp function resulting in smoother placement
Config.SMOOTH_SNAPPING = true           -- If enabled, objects being placed will lerp between grid positions

-- Default Keybinds
Config.ROTATE_KEY = Enum.KeyCode.R
Config.PAINT_KEY = Enum.KeyCode.F
Config.DELETE_KEY = Enum.KeyCode.G
Config.COPY_KEY = Enum.KeyCode.C
Config.UNDO_KEY = Enum.KeyCode.Z
Config.REDO_KEY = Enum.KeyCode.Y
Config.TRANSFORM_KEY = Enum.KeyCode.T
Config.LEVEL_UP_KEY = Enum.KeyCode.PageUp
Config.LEVEL_DOWN_KEY = Enum.KeyCode.PageDown

Config.CAM_FORWARD_KEY = Enum.KeyCode.W
Config.CAM_BACKWARD_KEY = Enum.KeyCode.S
Config.CAM_LEFT_KEY = Enum.KeyCode.A
Config.CAM_RIGHT_KEY = Enum.KeyCode.D
Config.CAM_ROTATE_LEFT_KEY = Enum.KeyCode.Q
Config.CAM_ROTATE_RIGHT_KEY = Enum.KeyCode.E
Config.CAM_TOP_VIEW_KEY = Enum.KeyCode.Space

-- Freecam
Config.CAM_MOVE_SPEED = 50
Config.CAM_ROTATE_SPEED = 2
Config.CAM_ZOOM_SPEED = 5
Config.CAM_MOUSE_SENSITIVITY = .005
Config.MIN_CAM_ZOOM = 10
Config.MAX_CAM_ZOOM = 100
Config.CAM_HEIGHT = 20 -- In studs

return Config