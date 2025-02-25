local DefaultStrongAttack = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService
local RenderService
local SkillService
local DebounceService
local CharacterService
local AnimationService
local HotbarService
local DamageService
local WeaponService
local EffectService
local RagdollService


local Validate = require(game.ReplicatedStorage.Validate)

function DefaultStrongAttack.Stomp(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    DebounceService:AddDebounce(Humanoid, "DefaultStrongAttack", 5, true)


    local Tool = HotbarService:GetEquippedTool(Humanoid.Parent)
		
	if not Tool then
		return
	end
	if not Validate:CanAttack(Humanoid) then
		return
	end
	local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)
    local AnimationPath: Animation = AnimationsFolder:FindFirstChild("Critical")
	local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(AnimationPath)
    local Markers = AnimationService:GetAllAnimationEventNames(AnimationPath.AnimationId)

    Animation.Priority = Enum.AnimationPriority.Action
    Animation:Play()
    DebounceService:AddDebounce(Humanoid, "IFrame", Animation.Length, true)
    DebounceService:AddDebounce(Humanoid, "StrongAttack", Animation.Length)
    Humanoid:SetAttribute("StrongAttack", true)
    CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)  

    if #Markers > 0 then
        Animation:GetMarkerReachedSignal("Hit"):Connect(function()
            local StompRenderData = RenderService:CreateRenderData(Humanoid, "DefaultStrongAttack", "Stomp",{
                Size = Vector3.new(16, 2, 16),
            })
	        RenderService:RenderForPlayers(StompRenderData)

            HitboxService:CreateFixedHitbox(Humanoid.Parent.PrimaryPart.CFrame, Vector3.new(16, 2, 16) * 2, 1, function(Enemy)
                if Enemy == Humanoid.Parent.PrimaryPart then
                    return
                end
                WeaponService:TriggerHittedEvent(Enemy.Humanoid, Humanoid)
                if DamageService:GetHitContext(Enemy.Humanoid) == "Hit" then
                    RagdollService:Ragdoll(Enemy, 1)
                    local EnemyPrimaryPartPosition = Enemy.PrimaryPart.Position :: Vector3
                    local PrimaryPartPos = Humanoid.Parent.PrimaryPart.Position :: Vector3
                    local deltaZ = EnemyPrimaryPartPosition.Z - PrimaryPartPos.Z
                    local deltaX = EnemyPrimaryPartPosition.X - PrimaryPartPos.X
                    Enemy.PrimaryPart.AssemblyLinearVelocity = Vector3.new(50/deltaX,10,50/deltaZ)  * WeaponService:GetModelMass(Enemy)
                end
                DamageService:TryHit(Enemy.Humanoid, Humanoid, 20)
            end)

        end)
    end

    local Conn
    Conn = Animation.Stopped:Connect(function()
        Humanoid:SetAttribute("StrongAttack", nil)
        CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
        Conn:Disconnect()
    end)
end


function DefaultStrongAttack.Caller(Humanoid, Data)
    if Validate:CanUseSkill(Humanoid, false) and not DebounceService:HaveDebounce(Humanoid, "DefaultStrongAttack") then
		DefaultStrongAttack.Stomp(Humanoid, Data)
	end
end

function DefaultStrongAttack.Start()
    EffectService = Knit.GetService("EffectService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
    CharacterService = Knit.GetService("CharacterService")
    AnimationService = Knit.GetService("AnimationService")
    HotbarService = Knit.GetService("HotbarService")
	SkillService = Knit.GetService("SkillService")
    RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return DefaultStrongAttack