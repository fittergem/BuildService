local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerScripts = player.PlayerScripts
local PlayerGui = player.PlayerGui

local ui = PlayerGui:WaitForChild("ScreenGui")
local button = ui:WaitForChild("Button")
local object = ui:WaitForChild("Object")
local wall = ui:WaitForChild("Wall")
local floor = ui:WaitForChild("Floor")

local BuildService = require(PlayerScripts:WaitForChild("BuildService"))

button.MouseButton1Click:Connect(function()
    if BuildService.ActiveSession then
        BuildService:RequestSessionCancel()
        button.Text = "Start"
    else
        BuildService:RequestSessionStart()
        button.Text = "End"
    end
end)

object.MouseButton1Click:Connect(function()
    BuildService:SelectObject("Bed")
end)

wall.MouseButton1Click:Connect(function()
    BuildService:SelectWall()
end)

floor.MouseButton1Click:Connect(function()
    BuildService:SelectFloor()
end)

BuildService.Warning:Connect(function(warning: string)
    warn("[BuildService] - " .. warning)
end)