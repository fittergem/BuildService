# BuildService Documentation

Welcome to the BuildService documentation. This page serves to provide every detail about BuildService, including it's functions, properties, values, and how BuildService works. Thank you for choosing BuildService

# BuildService Client

All of the client module functions and values

## Summary

### Properties
| `SessionActive`: `boolean` |
| `Warning`: `RBXScriptSignal` |
| `Error`: `RBXScriptSignal` |
| `Collision`: `RBXScriptSignal` |

### `:RequestSessionStart()`

Sends a request to the server through the [BuildRequest RemoteFunction](#buildrequest-remotefunction), which returns either `true` or `false` depending on the result of the server's validation.

If the [BuildRequest RemoteFunction](#buildrequest-remotefunction) returns `true`, the function will update [BuildService.SessionActive]() to `true` and start the [freecam]() if it's enabled in the [BuildConfig Module](#buildconfig-module).

### `:RequestSessionStop()`

Sends a request to the server through the [BuildRequest RemoteFunction](#buildrequest-remotefunction), which returns either `true` or `false` depending on the result of the server's validation.

### `:SelectObject()`

**Parameters:** 
* `objectName`: `string`

Attempts to start object placement given the `objectName` parameter. The function will attempt to find the object model from the `objectName` parameter in the `objectsFolder` defined in the [BuildConfig Module](#buildconfig-module).

### `:SelectWall()`



## BuildService Server

## BuildConfig Module

## BuildRequest RemoteFunction