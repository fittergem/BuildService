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

```lua
BuildService:RequestSessionStart() --> [bool]
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

## BuildRequest RemoteFunction
