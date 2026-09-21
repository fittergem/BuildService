local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local BuildService = require(ServerScriptService.BuildService)

BuildService.Warning:Connect(function(warning: string)
    print("[BuildService] - " .. warning)
end)

Players.PlayerAdded:Connect(function(player)
    local approved = BuildService.PlayerAdded(player)
end)