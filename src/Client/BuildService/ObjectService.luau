local ObjectService = {}

function ObjectService:Highlight(object: Model)
    local highlight = Instance.new("Highlight", object)
    highlight.FillColor = Color3.new(1,1,1)
    highlight.FillTransparency = .75
    highlight.OutlineTransparency = 1
end

return ObjectService