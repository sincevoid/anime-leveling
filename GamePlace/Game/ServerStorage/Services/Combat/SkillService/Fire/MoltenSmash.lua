local MoltenSmash = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService
local RenderService
local SkillService
local DebounceService
local DamageService
local WeaponService
local EffectService
local RagdollService


local Validate = require(game.ReplicatedStorage.Validate)

local Cooldown = 5
function MoltenSmash.Charge(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    DebounceService:AddDebounce(Humanoid, "MoltenSmash", Cooldown, true)
	SkillService:SetSkillState(Humanoid, "MoltenSmash", "Charge")

    local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "MoltenSmash", "Charge")
	RenderService:RenderForPlayers(ChargeRenderData)

    local Animation: AnimationTrack =
	Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Animations.Skills.Fire.MoltenSmash.MoltenSmashCharge)
	Animation.Priority = Enum.AnimationPriority.Action
	Animation:Play()

    DebounceService:AddDebounce(Humanoid, "UsingSkill", 0.85)
    WeaponService:Stun(Humanoid.Parent, 0.85)
    task.wait(0.6)
    MoltenSmash.Stomp(Humanoid, Data)
end

function MoltenSmash.Stomp(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    local RootPart = Humanoid.RootPart
    local state = SkillService:GetSkillState(Humanoid, "MoltenSmash")
	local Damage = Data.Damage or 15
	if state == nil then
		return
	end
    SkillService:SetSkillState(Humanoid, "MoltenSmash", "Stomp")

    local initialSize = 1
    local finalSize = 16
    local steps = 2
    local stepPosition = 5
    local startOffSet = 5

    local stepSize = (finalSize - initialSize) / steps

    local initialPosition = Data.CasterCFrame

    for i = 0, steps, 1 do
        local position = initialPosition * CFrame.new(0,0,-(startOffSet + (stepPosition * (i*3))))
        local size = Vector3.new(initialSize + (stepSize * i), initialSize + (stepSize * i), initialSize + (stepSize * i))

        local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "MoltenSmash", "Stomp", {
            position = position,
            size = size
        })
        RenderService:RenderForPlayers(ChargeRenderData)

        HitboxService:CreateFixedHitbox(position, size * 2, 1, function(Enemy)
            if Enemy == RootPart.Parent then
                return
            end

            WeaponService:TriggerHittedEvent(Enemy.Humanoid, Humanoid)
            if DamageService:GetHitContext(Enemy.Humanoid) == "Hit" then
                RagdollService:Ragdoll(Enemy, 1)
                Enemy.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,150,0)  * WeaponService:GetModelMass(Enemy)
                EffectService:AddEffect(Enemy.Humanoid, "MoltenSmashBurn", "Burn", 3, "int", 5)
            end
            DamageService:TryHit(Enemy.Humanoid, Humanoid, Damage)
        end)
        task.wait(.35)
    end



end

function MoltenSmash.Cancel(Humanoid: Humanoid)
    DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
end
--------
function MoltenSmash.Caller(Humanoid: Humanoid, Data: { any })
    if Validate:CanUseSkill(Humanoid, false) and not DebounceService:HaveDebounce(Humanoid, "MoltenSmash") then
		MoltenSmash.Charge(Humanoid, Data)
	end
end

function MoltenSmash.Start()
    EffectService = Knit.GetService("EffectService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
    RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return MoltenSmash