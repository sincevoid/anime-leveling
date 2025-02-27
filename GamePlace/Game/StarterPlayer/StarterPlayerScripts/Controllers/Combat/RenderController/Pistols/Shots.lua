local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shots = {}

local RenderController

function Shots.Default(RenderData)
    local arguments = RenderData.arguments
    local origin = arguments.Origin :: BasePart
    local shotVFX = ReplicatedStorage.VFX.Pistols.Shot.Attachment:Clone() :: Attachment
    shotVFX.Parent = origin
    shotVFX.WorldCFrame = origin.CFrame

    RenderController:EmitParticles(shotVFX, true)
    
end

function Shots.Caller(RenderData)
    if not RenderData then
        return
    end

    if Shots[RenderData.effect] then
        Shots[RenderData.effect](RenderData)
    else
        Shots.Default(RenderData)
    end
end

function Shots.Start()
    RenderController = Knit.GetController("RenderController")
end

return Shots