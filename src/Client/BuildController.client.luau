local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerScripts = player.PlayerScripts

local BuildService = require(PlayerScripts:WaitForChild("BuildService"))

-- Create button to trigger build mode
--[[

button.MouseButton1Click:Connect(function()
    BuildService:RequestSessionStart()
end)

]]

BuildService.Warning:Connect(function(warning: string)
    warn("[BuildService] - " .. warning)
end)