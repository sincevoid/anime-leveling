local Knit = require(game.ReplicatedStorage.Packages.Knit)
local RunsService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local Animator = Character.Humanoid.Animator :: Animator
local StateEvent = ReplicatedStorage.Events.StateChanged :: BindableEvent

local StateController = Knit.CreateController({
	Name = "StateController",
})
StateController.CurrentState = "Idle"
StateController.LastState = "Idle"

function StateController:ChangeState(new)
	StateController.LastState = StateController.CurrentState
	StateController.CurrentState = new

	StateEvent:Fire(StateController.LastState, StateController.CurrentState)
end

function StateController:GetLastState()
	return StateController.LastState
end

function StateController:GetCurrentState()
	return StateController.CurrentState
end

function StateController:Update()

	RunsService:BindToRenderStep("StateController", 300, function()
		--print(Animator:GetPlayingAnimationTracks())
		local XZVel = math.floor(Vector2.new(Character.PrimaryPart.AssemblyLinearVelocity.X, Character.PrimaryPart.AssemblyLinearVelocity.Z).Magnitude)
		if math.floor(Character.PrimaryPart.AssemblyLinearVelocity.Y) > 0 then
			self:ChangeState("Jumping")
		elseif math.floor(Character.PrimaryPart.AssemblyLinearVelocity.Y) < 0 then
			self:ChangeState("Falling")
		else
			self:ChangeState("Idle")
		end

		if XZVel > 0 then
			if XZVel < 16 then
				self:ChangeState("Walking")
			else
				self:ChangeState("Running")
			end
		end
	end)
end

function StateController.KnitStart()
	--StateController:Update()
end

return StateController
