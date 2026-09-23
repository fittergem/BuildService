local Config = {

    -- NOTE: THESE ARE ALL DEFAULT VALUES
    -- Most values can be updated per-player by updating the Values.luau module
    -- For example, customizing keybinds, smooth snapping, freecam settings, etc. can all be done by updating the Values.luau module
    -- This module is for DEFAULT values or server-defined unchangeables (Constants)

    -- Server constants
    GRID_SIZES = {4, 2, 1},         -- In studs (First entry is the default size)
    GRID_TEXTURE_ID = 0,            -- ID of the grid texture
    ALLOW_GRID_TOGGLE = false,      -- Allow players to toggle the grid on and off
    GRID_TOGGLE_GAMEPASS = 0,       -- ID of the gamepass required to turn the grid off (Only works if ALLOW_GRID_TOGGLE is true. Leave 0 for no gamepass)

    BOUNDS_ENABLED = true,          -- Allows players to build outside of the plot
    ALLOW_DISABLED_BOUNDS = false,  -- Allow players to turn bounds off even if bounds are enabled (Would allow players to build outside the plot)
    BOUNDS_TOGGLE_GAMEPASS = 0,     -- ID of the gamepass required to turn bounds off (Only works if ALLOW_BOUNDS_DISABLE is true. Leave 0 for no gamepass)

    ALLOW_COLLISIONS_OFF = true,    -- Allow object collisions to be turned off
    COLLISIONS_TOGGLE_GAMEPASS = 0, -- ID of the gamepass required to turn collisions off (Leave 0 for no gamepass)

    BASEMENT_LEVELS = 1,            -- Number of levels below the main floor players can go
    BASEMENT_GAMEPASS = 0,          -- ID of gamepass required to build in basement levels (Leave 0 for no gamepass)

    UPPER_LEVELS = 4,               -- Number of levels above the main floor players can go
    UPPER_LEVELS_GAMEPASS = 0,      -- ID of gamepass required to build on upper levels (Leave 0 for no gamepass)

    -- Smoothing (Higher values = faster response / less "momentum")
    POSITION_SMOOTHING = 10,
    ROTATION_SMOOTHING = 10,
    PITCH_SMOOTHING = 10,
    ZOOM_SMOOTHING = 10,

    SMOOTH_FREECAM = true,         -- If enabled, freecam will have simulated momentum and feel smoother

    LERP_ALPHA = .2,               -- The alpha value of interpolation (Recommended between .1 and .5)
    SMOOTH_SNAPPING = true,        -- If enabled, objects being placed will lerp between grid positions

    -- Colors
    HIGHLIGHT_COLOR = Color3.new(1,1,1),
    COLLISION_COLOR = Color3.new(1,0,0),
    DELETE_COLOR = Color3.new(1,0,0),
    PAINT_COLOR = Color3.new(0,.5,1),
    COPY_COLOR = Color3.new(1,.5,0),
    TRANSFORM_COLOR = Color3.new(.5,1,.5),

    -- Highlights
    HIGHLIGHT_FILL_TRANSPARENCY = .75,
    HIGHLIGHT_OUTLINE_TRANSPARENCY = 1,

    -- Default Keybinds
    ROTATE_KEY = Enum.KeyCode.R,                -- Rotate objects
    PAINT_KEY = Enum.KeyCode.F,                 -- Paint objects
    DELETE_KEY = Enum.KeyCode.G,                -- Delete objects
    COPY_KEY = Enum.KeyCode.C,                  -- Copy objects
    UNDO_KEY = Enum.KeyCode.Z,                  -- Undo action
    REDO_KEY = Enum.KeyCode.Y,                  -- Redo action
    TRANSFORM_KEY = Enum.KeyCode.T,             -- Transform object
    LEVEL_UP_KEY = Enum.KeyCode.PageUp,         -- Move up a level
    LEVEL_DOWN_KEY = Enum.KeyCode.PageDown,     -- Move down a level

    CAM_FORWARD_KEY = Enum.KeyCode.W,           -- Move freecam forward
    CAM_BACKWARD_KEY = Enum.KeyCode.S,          -- Move freecam backward
    CAM_LEFT_KEY = Enum.KeyCode.A,              -- Move freecam left
    CAM_RIGHT_KEY = Enum.KeyCode.D,             -- Move freecam right
    CAM_ROTATE_LEFT_KEY = Enum.KeyCode.Q,       -- Rotate freecam left (Left yaw)
    CAM_ROTATE_RIGHT_KEY = Enum.KeyCode.E,      -- Rotate freecam right (Right yaw)
    CAM_TOP_VIEW_KEY = Enum.KeyCode.Space,      -- Perpendicular freecam (Top view)

    -- Freecam
    CAM_MOVE_SPEED = 50,                -- Higher = faster
    CAM_ROTATE_SPEED = 2,               -- Higher = faster
    CAM_ZOOM_SPEED = 5,                 -- Higher = faster
    CAM_MOUSE_SENSITIVITY = .005,       -- Higher = faster
    MIN_CAM_ZOOM = 10,                  -- Studs away from plot base
    MAX_CAM_ZOOM = 100,                 -- Studs away from plot base
    CAM_HEIGHT = 20,                    -- In studs

    -- Wall Building
    DRAG_PLACEMENT = true,      -- Click and drag to build walls. If false, click twice to build walls.

    POLE_DIAMETER = .5,         -- In studs
    WALL_HEIGHT = 15,           -- In studs
    WALL_THICKNESS = .5,        -- In studs

    CURRENT_POLE_COLOR = Color3.new(0,1,1),             -- Color of the current selected pole
    START_POLE_COLOR = Color3.new(0,1,0),               -- Color of the previous pole
    POLE_MATERIAL = Enum.Material.Neon,                   -- Material of the pole when placing
    POLE_TRANSPARENCY = 0,                               -- Transparency of pole when placing

    DEFAULT_WALL_COLOR = Color3.new(.75,.75,.75),          -- Wall color when wall placement is complete
    DEFAULT_WALL_MATERIAL = Enum.Material.SmoothPlastic,  -- Wall material
    WALL_TRANSPARENCY = .5,                               -- Transparency of the wall when placing

    -- Wait Times
    MAX_PLOT_WAIT_TIME = 5,     -- In seconds

}

local function DeepFreeze(tbl)
    for _, v in pairs(tbl) do
        if type(v) == "table" and not table.isfrozen(tbl) then
            DeepFreeze(v)
        end
    end

    return table.freeze(tbl)
end

return DeepFreeze(Config)