local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local FlashStrike = {}

local VFX = require(game.ReplicatedStorage.Modules.VFX)
local SFX = require(game.ReplicatedStorage.Modules.SFX)

local RenderController
local ShakerController

function FlashStrike.Charge(RenderData)
	local casterHumanoid = RenderData.casterHumanoid :: Humanoid

	RenderController:ExecuteForHumanoid(casterHumanoid, function()
		local Animation: AnimationTrack = RenderController:GetPlayingAnimationTrack(casterHumanoid, "FlashStrike")
		if not Animation then
			return
		end
		local connection
		connection = Animation:GetMarkerReachedSignal("attack"):Once(function()
			ShakerController:Shake(ShakerController.Presets.Bump)
		end)

		Animation.Ended:Once(function()
			connection:Disconnect()
		end)
		
		ShakerController:Shake(ShakerController.Presets.Bump2)
	end)
end

function FlashStrike.ImpactFrame()
	local Folder = Instance.new("Folder", game:GetService("Lighting"))
	local TargetFrames = 8
	local CurrentFrame = 0
	local BrightImpactFrame , DarkImpactFrame = ReplicatedStorage.VFX.ImpactFrames.BrightFlashStrike:Clone(), ReplicatedStorage.VFX.ImpactFrames.DarkFlashStrike:Clone()
	local ShowingImpact = false


	local ExecutionData = {
		{
			Frame = BrightImpactFrame,
			Secs = .03
		},
		{
			Frame = DarkImpactFrame,
			Secs = .05
		}
	}
	for i,v in pairs(game:GetService("Lighting"):GetChildren()) do
		if v == Folder then continue end
		v.Parent = Folder
	end

	BrightImpactFrame.Parent = game:GetService("Lighting")
	DarkImpactFrame.Parent = game:GetService("Lighting")

	for i,v in pairs(ExecutionData) do
		v.Frame.Enabled = true
		ShowingImpact = true
		task.wait(v.Secs)
		v.Frame:Destroy()
	end

	for i,v in pairs(Folder:GetChildren()) do
		v.Parent = game:GetService("Lighting")
	end
	Folder:Destroy()

end

function FlashStrike.Attack(RenderData)
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame
	local particle = VFX:CreateParticle(
		casterRootCFrame * CFrame.new(0, 0, -20) * CFrame.Angles(0, math.rad(-90), 0),
		"FlashStrikeDash",
		1
	)
	SFX:Create(casterHumanoid.RootPart, "FlashStrikeDash", 0, 76)
end

function FlashStrike.Hit(RenderData)
	local casterRootCFrame = RenderData.casterRootCFrame
	local FlashStrikeMultipleSlashes = game.ReplicatedStorage.VFX.Sword.FlashStrike.MultipleSlashes:Clone()
	FlashStrikeMultipleSlashes:PivotTo(casterRootCFrame)
	FlashStrikeMultipleSlashes.Parent = game.Workspace
	FlashStrikeMultipleSlashes.Main.CFrame = casterRootCFrame
	RenderController:EmitParticles(FlashStrikeMultipleSlashes.Main)
	RenderController:EmitParticles(FlashStrikeMultipleSlashes.Stars)
	
	if RenderData.arguments.EmitDelayed then
		RenderController:EmitParticles(FlashStrikeMultipleSlashes.Main2.DelayedHit)

		task.delay(2.15, function()
			task.delay(.13, function()
				ShakerController:ShakeOnce(10, 20, 0.1, 0.3)
				FlashStrike.ImpactFrame()
			end)
			SFX:Create(RenderData.casterHumanoid.RootPart, "FlashStrikeSlash", 0, 72)
		end)
	end

	task.delay(1.65, function()
		SFX:Create(RenderData.arguments.HumanoidWhoHitted.RootPart, "FlashStrikeSheath", 0, 64)
		
	end)

	Debris:AddItem(FlashStrikeMultipleSlashes, 5)
end

function FlashStrike.Cancel(RenderData) end

function FlashStrike.Start()
	RenderController = Knit.GetController("RenderController")
	ShakerController = Knit.GetController("ShakerController")
end

function FlashStrike.Caller(RenderData)
	local Effect = RenderData.effect

	if FlashStrike[Effect] then
		FlashStrike[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return FlashStrike
