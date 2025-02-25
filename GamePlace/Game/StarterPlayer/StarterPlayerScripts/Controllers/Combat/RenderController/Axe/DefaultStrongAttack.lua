local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local TweenService = game:GetService("TweenService")
local VFX = require(game.ReplicatedStorage.Modules.VFX)
local SFX = require(game.ReplicatedStorage.Modules.SFX)
local CraterModule = require(game.ReplicatedStorage.Modules.CraterModule)
local Assets = game.ReplicatedStorage.VFX.Fire.MoltenSmash


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

    local Explosion = Assets.Explosion:Clone()

    local ExplosionCFrame = RenderData.casterRootCFrame * CFrame.new(0, -1.5, 0)
    Explosion:PivotTo(ExplosionCFrame)
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


    CraterModule:Spawn({
		Position = Explosion:GetPivot().Position, --> Position
		AmountPerUnit = 1, --> Amount of Rocks Per Unit (1 would appear a single rock per angle step.)
		Amount = 30, --> Amount of rocks that will exist in the circle. (360 / Amount)
		Angle = {10, 30}, --> Random Angles (Y) axis.
		Radius = {16, 17}, --> Random Radius;
		Size = {8, 9}, --> Random Size (number only);

		Offset = {
			X = 0,
			Y = 0.5,
			Z = 0,
		}, --> Random offset (Y);

		DespawnTime = 2, --> Despawn Time
	})

    CraterModule:ExplosionRocks({
		Position = ExplosionCFrame.Position, --> Position;
		Amount = 10, --> Amount of Rocks;
		Radius = {
			X = 2,
			Y = -2,
			Z = 2,
		},
		Size = {Vector3.one, Vector3.one},
		Force = {
			X = {-45, 45},
			Y = {30, 50},
			Z = {-45, 45},
		},

		DebrisTemplate = game.ReplicatedStorage.VFX.Debris.OnFire,
		Trail = true, --> Enable / Disable
		Direction = casterRootCFrame, --> Direction (Gets 'LookVector', 'UpVector' and 'RightVector' automatically)
		DespawnTime = 1, --> Despawn Time.
	})


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