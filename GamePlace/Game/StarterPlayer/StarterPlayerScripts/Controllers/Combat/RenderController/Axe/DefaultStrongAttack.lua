local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local TweenService = game:GetService("TweenService")
local VFX = require(game.ReplicatedStorage.Modules.VFX)
local SFX = require(game.ReplicatedStorage.Modules.SFX)
local CraterModule = require(game.ReplicatedStorage.Modules.CraterModule)
local Assets = game.ReplicatedStorage.VFX.GroundSlam


local RenderController
local ShakerController

local Player = game.Players.LocalPlayer


local DefaultStrongAttack = {}

function DefaultStrongAttack.Stomp(RenderData)
    local arguments = RenderData.arguments
	local size: Vector3 = arguments.size

	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame
    local Character = Player.Character

    local Explosion = Assets:Clone() :: BasePart

    local ExplosionPos = RenderData.casterRootCFrame * CFrame.new(0, -3, -5)
    Explosion.Position = ExplosionPos.Position
    Explosion.Parent = workspace
    RenderController:EmitParticles(Explosion)

    local Distance = (Explosion:GetPivot().Position - Character:GetPivot().Position).Magnitude
    if Distance <= 32 then
        local Magnitude = (32/Distance) / 1.5
        ShakerController:ShakeOnce(Magnitude, 20, 0.1, 0.3)
    end
    SFX:Create(Explosion, "ExplosionLight", 0 , 72)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {workspace.Characters, workspace.Enemies, workspace.Test}



    Debris:AddItem(Explosion, 5)
end

function DefaultStrongAttack.Start()
    RenderController = Knit.GetController("RenderController")	
    ShakerController = Knit.GetController("ShakerController")
end

function DefaultStrongAttack.Caller(RenderData)
    local Effect = RenderData.effect

	if DefaultStrongAttack[Effect] then
		DefaultStrongAttack[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return DefaultStrongAttack