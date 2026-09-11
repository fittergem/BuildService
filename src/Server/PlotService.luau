local Workspace = game:GetService("Workspace")

local PlotService = {}

local plotsFolder = Workspace.Plots

function PlotService:GetAllPlots()
	return plotsFolder:GetChildren()
end

function PlotService:GetAvailablePlots()
	
end

function PlotService:AssignPlot(plot: Model, player: Player)
	
end

function PlotService:UnassignPlot(plot: Model)
	
end

function PlotService:SetPlotValue(value: number)
	
end

function PlotService:GetPlayerPlot(player: Player)
	for i, plot in pairs(plotsFolder:GetChildren()) do
		if plot:GetAttribute("OwnerId") == player.UserId then
			return plot
		end
	end
end

return PlotService
