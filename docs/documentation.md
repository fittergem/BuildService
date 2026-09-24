Welcome to the BuildService API. This page serves to provide every detail about BuildService, including it's functions, properties, values, and how BuildService works. Thank you for choosing BuildService

## BuildService Client

All of the client module properties and methods

### .Collision

```
BuildService.Collision   [RBXScriptSignal]
```

A signal that is fired every time a placement is attempted, but the placing object collides with an object that was already placed. This makes it easy to implement UI-based warnings to the player about collisions.

Example usage:

```lua
local lastCollision = 0

BuildService.Collision:Connect(function()
    warningLabel.Visible = true
    lastCollision = tick()

    task.wait(3)

    if tick() - lastCollision >= 3 then
        warningLabel.Visible = false
    end
end)
```

!!! warning

    It's important to note that this event is fired **every** time a client attempts to place an object and there is a collision error. Repeated placement could result in several connections happening very frequently. If not handled properly, timed UI-based warnings could break.

### .Error

```
BuildService.Error   [RBXScriptSignal]
```

A signal that is fired every time an error is raised from BuildService on the client.

Example usage:

```lua
BuildService.Error:Connect(function(warning: string)
    error("[BuildService] - " .. warning)
end)
```

!!! note

    Typically, BuildService errors should not happen. The only reason these errors might occur is because of definition errors in the configuration module. If you are getting errors from BuildService, please check that the configuration paths are correct.

### .SessionActive

```
BuildService.SessionActive   [bool] (read-only)
```

A read-only value that external scripts can read to view the session status. If the value is `true`, a session is currently active. If the value is `false`, a session is not currently active.

### .SessionChanged

```
BuildService.SessionChanged   [RBXScriptSignal]
```

A signal that is fired every time the [`BuildService.SessionActive`](#sessionactive) value is changed.

Example usage:

```lua
BuildService.SessionChanged:Connect(function(active: boolean)
    sessionStatusValue.Text = active and "Active" or "Inactive"
end)
```

### .Warning

```
BuildService.Warning   [RBXScriptSignal]
```

A signal that is fired every time a warning is raised from BuildService on the client.

Example usage:

```lua
BuildService.Warning:Connect(function(warning: string)
    warn("[BuildService] - " .. warning)
end)
```

!!! note

    BuildService warnings are not fatal. Script execution should not halt due to warnings. The system handles the events that cause the warnings to occur automatically.

### :RequestSessionStart()

```
BuildService:RequestSessionStart()
```

Sends a request to the server through the [BuildRequest RemoteFunction](#buildrequest-remotefunction).

If the [BuildRequest RemoteFunction](#buildrequest-remotefunction) returns `true`, the function will update [BuildService.SessionActive](#sessionactive) to `true` and start the [freecam]() if it's enabled in the [BuildConfig Module](#buildconfig-module).

If there is a problem starting a session, the [BuildService.Warning](#warning) event will be fired with the problem details.

Example usage:

```lua
startButton.MouseButton1Down:Connect(function()
    BuildService:RequestSessionStart()
end)
```

### :RequestSessionStop()

```
BuildService:RequestSessionStop()
```

Sends a request to the server through the [BuildRequest RemoteFunction](#buildrequest-remotefunction).

If the [BuildRequest RemoteFunction](#buildrequest-remotefunction) returns `true`, the function will update [BuildService.SessionActive](#sessionactive) to `false` and stop the [freecam]().

If there is a problem stopping the session, the [BuildService.Warning](#warning) event will be fired with the problem details.

Example usage:

```lua
stopButton.MouseButton1Down:Connect(function()
    BuildService:RequestSessionStop()
end)
```

### :SelectObject()

```
BuildService:SelectObject(objectName: string)
```

Attempts to start object placement given the `objectName` parameter. The function will attempt to find the object model from the `objectName` parameter in the `objectsFolder` defined in the [BuildConfig Module](#buildconfig-module).

Any problems that occur while selecting an object, such as an object not being found, will fire the [BuildService.Warning](#warning) event with the problem details.

Example usage:

```lua
objectButton.MouseButton1Down:Connect(function()
    BuildService:SelectObject(objectButton.Name)
end)
```

!!! note

    In the above example, the system is set up to select objects based on the clicked button's name.

### :SelectWall()

```
BuildService:SelectWall()
```

Attempts to start wall placement, using the configuration for wall placement defined in the [BuildConfig Module](#buildconfig-module).

Any problems that occur while placing walls will fire the [BuildService.Warning](#warning) event with the problem details.

Example usage:

```lua
wallButton.MouseButton1Down:Connect(function()
    BuildService:SelectWall()
end)
```

## BuildService Server

## BuildConfig Module

A module containing all of the defualt configurations for BuildService. This module is **read-only**, meaning that external scripts can only read information from it, but cannot write new information to it.

### GRID_SIZES

```
Config.GRID_SIZES   [table] -- {number}
```

A table of numbers representing grid sizes, in studs, that can be cycled through.

!!! note

    To disable the grid, set the only size to be `0`.

    ```lua
    Config.GRID_SIZES = {0}
    ```

### GRID_TEXTURE_ID

```
Config.GRID_TEXTURE_ID   [number] -- Image ID
```

The image ID of the grid texture to be displayed on the plot during placement sessions.

!!! note

    Set the ID to `0` to disable the grid texture.

### ALLOW_GRID_TOGGLE

```
Config.ALLOW_GRID_TOGGLE   [bool]
```

Allow players to toggle the grid. If enabled, players can toggle between placing objects freely in the plot or snapping objects to a grid.

### GRID_TOGGLE_GAMEPASS

```
Config.GRID_TOGGLE_GAMEPASS   [number] -- Gamepass ID
```

If players are able to toggle the grid on and off, this is an optional gamepass that players would be required to own before toggling the grid.

!!! note

    Set the ID to 0 to disable the gamepass requirement

### BOUNDS_ENABLED

### ALLOW_DISABLED_BOUNDS

### BOUNDS_TOGGLE_GAMEPASS

### ALLOW_COLLISIONS_OFF

### COLLISIONS_TOGGLE_GAMEPASS

### BASEMENT_LEVELS

### BASEMENT_GAMEPASS

### POSITION_SMOOTHING

### ROTATION_SMOOTHING

### PITCH_SMOOTHING

### ZOOM_SMOOTHING

### SMOOTH_FREECAM

### LERP_ALPHA

### SMOOTH_SNAPPING

### HIGHLIGHT_COLOR

### COLLISION_COLOR

### DELETE_COLOR

### PAINT_COLOR

### COPY_COLOR

### TRANSFORM_COLOR

### HIGHLIGHT_FILL_TRANSPARENCY

### HIGHLIGHT_OUTLINE_TRANSPARENCY

### ROTATE_KEY

### PAINT_KEY

### DELETE_KEY

### COPY_KEY

### UNDO_KEY

### REDO_KEY

### TRANSFORM_KEY

### LEVEL_UP_KEY

### LEVEL_DOWN_KEY

### CAM_FORWARD_KEY

### CAM_BACKWARD_KEY

### CAM_LEFT_KEY

### CAM_RIGHT_KEY

### CAM_ROTATE_LEFT_KEY

### CAM_ROTATE_RIGHT_KEY

### CAM_TOP_VIEW_KEY

### CAM_MOVE_SPEED

### CAM_ROTATE_SPEED

### CAM_ZOOM_SPEED

### CAM_MOUSE_SENSITIVITY

### MIN_CAM_ZOOM

### MAX_CAM_ZOOM

### CAM_HEIGHT

### DRAG_PLACEMENT

### POLE_DIAMETER

### WALL_HEIGHT

### WALL_THICKNESS

### CURRENT_POLE_COLOR

### START_POLE_COLOR

### POLE_MATERIAL

### POLE_TRANSPARENCY

### DEFAULT_WALL_COLOR

### DEFUALT_WALL_MATERIAL

### WALL_TRANSPARENCY

### MAX_PLOT_WAIT_TIME

## BuildRequest RemoteFunction

### start_session

### stop_session

### request_object_placement

### request_plot

### request_wall_placement
