local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local RaycastService = {}

local function Raycast(x: number, y: number, params: RaycastParams?)
    local unitRay = camera:ViewportPointToRay(x, y)
    return Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
end

function RaycastService:GetMouseHitPosition(params: RaycastParams?)
    local mouse = UserInputService:GetMouseLocation()
    local result = Raycast(mouse.X, mouse.Y, params)

    return result
end

return RaycastService