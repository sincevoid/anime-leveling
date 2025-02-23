local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ClientEvent = ReplicatedStorage.Events:FindFirstChild("MainEvents") :: RemoteEvent
local ClientRequest = ReplicatedStorage.Events:WaitForChild("Requests") :: RemoteFunction
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Player = game.Players.LocalPlayer

local ListenerController = Knit.CreateController({
	Name = "ListenerController",
})

local TutorialController

local Requests_Handler = {
	["GetMouseInfo"] = function(Data)
		return {
			["MouseCFrame"] = Player:GetMouse().Hit,
			["MouseBehavior"] = UserInputService.MouseBehavior,
			["MouseTarget"] = Player:GetMouse().Target,
		}
	end
}

local Handler = {
	["CheckLoot"] = function(Data)
		print(Data)
	end,
}

ClientRequest.OnClientInvoke = function(Request, Data)
	if Requests_Handler[Request] then
		return Requests_Handler[Request](Data)
	else
		warn("Request not found")
	end
end

ClientEvent.OnClientEvent:Connect(function(callbackName, Data)
	if Handler[callbackName] then
		Handler[callbackName](Data)
	else
		warn("Event Handler not found")
	end
end)

function ListenerController.KnitStart()
	TutorialController = Knit.GetController("TutorialController")
	--TutorialController:StartTutorial(game.Players.LocalPlayer)
end

return ListenerController
