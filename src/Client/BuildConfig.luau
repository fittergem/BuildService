local Config = {}

Config.GRID_SIZES = {4, 2, 1} -- In studs (First entry is the default size)
Config.GRID_TEXTURE_ID = 0 -- ID of the grid texture

Config.BOUNDS_ENABLED = true -- Allows platers to build outside of the plot
Config.ALLOW_BOUNDS_DISABLE = false -- Allow players to turn bounds off even if bounds are enabled (Would allow players to build outside the plot)
Config.BOUNDS_TOGGLE_GAMEPASS = 0 -- ID of the gamepass required to turn boudns off (Only works ALLOW_BOUNDS_DISABLE is true. Leave 0 for no gamepass)

Config.ALLOW_COLLISIONS_OFF = true -- Allow object collisions to be turned off
Config.COLLISIONS_TOGGLE_GAMEPASS = 0 -- ID of the gamepass required to turn collisions off (Leave 0 for no gamepass)

Config.BASEMENT_LEVELS = 1 -- Number of levels below the main floor players can go
Config.BASEMENT_GAMEPASS = 0 -- ID of gamepass required to build in basement levels (Leave 0 for no gamepass)

Config.UPPER_LEVELS = 4 -- Number of levels above the main floor players can go
Config.UPPER_LEVELS_GAMEPASS = 0 -- ID of gamepass required to build on upper levels (Leave 0 for no gamepass)

Config.SMOOTH_SNAPPING = true -- When placing, objects will lerp between their snapped positions

return Config