local Config = {

    -- NOTE: THESE ARE ALL DEFAULT VALUES
    -- Most values can be updated per-player by updating the Values.luau module
    -- For example, customizing keybinds, smooth snapping, freecam settings, etc. can all be done by updating the Values.luau module
    -- This module is for DEFAULT values or server-defined unchangeables (Constants)

    -- Server constants
    GRID_SIZES = {4, 2, 1},          -- In studs (First entry is the default size)
    GRID_TEXTURE_ID = 0,             -- ID of the grid texture
    ALLOW_GRID_TOGGLE = false,       -- Allow players to toggle the grid on and off
    GRID_TOGGLE_GAMEPASS = 0,        -- ID of the gamepass required to turn the grid off (Only works if ALLOW_GRID_TOGGLE is true. Leave 0 for no gamepass)

    BOUNDS_ENABLED = true,           -- Allows players to build outside of the plot
    ALLOW_DISABLED_BOUNDS = false,   -- Allow players to turn bounds off even if bounds are enabled (Would allow players to build outside the plot)
    BOUNDS_TOGGLE_GAMEPASS = 0,      -- ID of the gamepass required to turn bounds off (Only works if ALLOW_BOUNDS_DISABLE is true. Leave 0 for no gamepass)

    ALLOW_COLLISIONS_OFF = true,     -- Allow object collisions to be turned off
    COLLISIONS_TOGGLE_GAMEPASS = 0,  -- ID of the gamepass required to turn collisions off (Leave 0 for no gamepass)

    BASEMENT_LEVELS = 1,             -- Number of levels below the main floor players can go
    BASEMENT_GAMEPASS = 0,           -- ID of gamepass required to build in basement levels (Leave 0 for no gamepass)

    UPPER_LEVELS = 4,                -- Number of levels above the main floor players can go
    UPPER_LEVELS_GAMEPASS = 0,       -- ID of gamepass required to build on upper levels (Leave 0 for no gamepass)

    -- Smoothing (Higher values = faster response / less "momentum")
    POSITION_SMOOTHING = 20,
    ROTATION_SMOOTHING = 20,
    PITCH_SMOOTHING = 10,
    ZOOM_SMOOTHING = 10,

    SMOOTH_FREECAM = false,           -- If enabled, freecam will have simulated momentum and feel smoother

    LERP_ALPHA = .05,                -- The alpha value of the lerp function resulting in smoother placement
    SMOOTH_SNAPPING = false,          -- If enabled, objects being placed will lerp between grid positions

    -- Default Keybinds
    ROTATE_KEY = Enum.KeyCode.R,
    PAINT_KEY = Enum.KeyCode.F,
    DELETE_KEY = Enum.KeyCode.G,
    COPY_KEY = Enum.KeyCode.C,
    UNDO_KEY = Enum.KeyCode.Z,
    REDO_KEY = Enum.KeyCode.Y,
    TRANSFORM_KEY = Enum.KeyCode.T,
    LEVEL_UP_KEY = Enum.KeyCode.PageUp,
    LEVEL_DOWN_KEY = Enum.KeyCode.PageDown,

    CAM_FORWARD_KEY = Enum.KeyCode.W,
    CAM_BACKWARD_KEY = Enum.KeyCode.S,
    CAM_LEFT_KEY = Enum.KeyCode.A,
    CAM_RIGHT_KEY = Enum.KeyCode.D,
    CAM_ROTATE_LEFT_KEY = Enum.KeyCode.Q,
    CAM_ROTATE_RIGHT_KEY = Enum.KeyCode.E,
    CAM_TOP_VIEW_KEY = Enum.KeyCode.Space,

    -- Freecam
    CAM_MOVE_SPEED = 50,
    CAM_ROTATE_SPEED = 2,
    CAM_ZOOM_SPEED = 5,
    CAM_MOUSE_SENSITIVITY = .005,
    MIN_CAM_ZOOM = 10,
    MAX_CAM_ZOOM = 100,
    CAM_HEIGHT = 20, -- In studs

    -- Wait Times
    MAX_PLOT_WAIT_TIME = 5, -- In seconds

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