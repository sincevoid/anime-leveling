local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DamageService = Knit.CreateService({
	Name = "DamageService",
})

local DebounceService
local SkillService
local PostureService
local AnimationService
local RenderService
local CharacterService
local WeaponService
local RagdollService
local PlayerService
local CombatService

function DamageService:DealDamage(HumanoidToDamage: Humanoid, Damage: number, Humanoid: Humanoid?)
	HumanoidToDamage:TakeDamage(Damage)

	if HumanoidToDamage.Health <= 0 and not HumanoidToDamage:GetAttribute("Died") then
		HumanoidToDamage:SetAttribute("Died", true)
		CombatService:RegisterHumanoidKilled(Humanoid.Parent, HumanoidToDamage)
	end

	PlayerService:SetHumanoidInCombat(HumanoidToDamage)
end

-- força um hit, ignorando o block
function DamageService:Hit(
	HumanoidHitted: Humanoid,
	Humanoid: Humanoid,
	Damage: number,
	HitEffect: string,
	ShouldStun: boolean?
)
	if ShouldStun == nil then
		ShouldStun = true
	end
	SkillService:TryCancelSkillsStates(HumanoidHitted)
	if ShouldStun then
		DebounceService:AddDebounce(HumanoidHitted, "Hit", 1)
		HumanoidHitted:SetAttribute("Running", false)
		AnimationService:StopM1Animation(HumanoidHitted)
	end

	DamageService:DealDamage(HumanoidHitted, Damage, Humanoid)

	task.delay(1, function()
		if not DebounceService:HaveDebounce(HumanoidHitted, "Hit") then
			CharacterService:UpdateWalkSpeedAndJumpPower(HumanoidHitted)
		end
	end)

	PostureService:RemovePostureDamage(Humanoid, Damage / 2.5)
	local hitEffectRenderData = RenderService:CreateRenderData(HumanoidHitted, "HitEffects", HitEffect or "None")
	RenderService:RenderForPlayers(hitEffectRenderData)
end

function DamageService:BlockHit(HumanoidHitted: Humanoid, Humanoid: Humanoid, BlockPostureDamage: number)
	-- if HumanoidHitted:GetAttribute("Hit") then
	-- 	WeaponService:Block(HumanoidHitted.Parent, false)
	-- 	return false
	-- end

	HumanoidHitted:SetAttribute("HitCounter", 0)

	-- DebounceService:AddDebounce(Humanoid, "Blocked", 0.35, true)
	PostureService:AddPostureDamage(HumanoidHitted, Humanoid, BlockPostureDamage)

	local blockEffectRenderData = RenderService:CreateRenderData(HumanoidHitted, "HitEffects", "Blocked")
	RenderService:RenderForPlayers(blockEffectRenderData)
	return false
end

function DamageService:DeflectHit(HumanoidHitted: Humanoid, Humanoid: Humanoid, DeflectPostureDamage: number)
	local Tool1, Tool2 = HumanoidHitted.Parent:FindFirstChildOfClass("Tool"), Humanoid.Parent:FindFirstChildOfClass("Tool")
	if Tool1 then
		local Type1, Type2 = Tool1:GetAttribute("Type"), Tool2:GetAttribute("Type")
		if Type1 == "Katana" and Type2 == "Pistols" then
			HumanoidHitted:SetAttribute("HitCounter", 0)
			DamageService:Hit(Humanoid, HumanoidHitted, 10, "Dagger", false)
			HumanoidHitted:SetAttribute("BlockEndLag", false)
			AnimationService:StopM1Animation(Humanoid)
		else
			print(HumanoidHitted.Parent, Humanoid.Parent)
			print(Type1,Type2)
			HumanoidHitted:SetAttribute("HitCounter", 0)
			DebounceService:AddDebounce(HumanoidHitted, "DeflectTime", 0.125)
			PostureService:RemovePostureDamage(HumanoidHitted, 10)
			Humanoid:SetAttribute("Deflected", true)
			PostureService:AddPostureDamage(Humanoid, HumanoidHitted, DeflectPostureDamage, true)
			DebounceService:RemoveDebounce(HumanoidHitted, "Hit")
			Humanoid:SetAttribute("ComboCounter", 0)
			HumanoidHitted:SetAttribute("BlockEndLag", false)
			AnimationService:StopM1Animation(Humanoid)
		end
	end

	task.delay(1, function()
		Humanoid:SetAttribute("Deflected", false)
	end)

	task.spawn(function()
		local deflectEffectRenderData = RenderService:CreateRenderData(HumanoidHitted, "HitEffects", "Deflect")
		RenderService:RenderForPlayers(deflectEffectRenderData)
	end)
end

-- função hit, possui verificações de block e dodge, além de aplicar debuffs de hit
function DamageService:TryHit(
	HumanoidHitted: Humanoid,
	Humanoid: Humanoid,
	_Damage: number,
	HitEffect: string?,
	ShouldStun: boolean?
)
	if HumanoidHitted == nil then
		return
	end
	
	if HumanoidHitted:GetAttribute("IFrame") then
		return
	end

	CharacterService:UpdateWalkSpeedAndJumpPower(HumanoidHitted)

	if _Damage == nil then
		return print("Damage is nil")
	end

	local Damage = _Damage
	local DeflectPostureDamage
	local BlockPostureDamage

	if typeof(Damage) == "table" then
		if Damage.Damage == nil then
			print("Table damage is nil")
			return
		end
		if Damage.Block == nil then
			print("Table block is nil")
			return
		end
		if Damage.Deflect == nil then
			print("Table deflect is nil")
			return
		end

		Damage = _Damage.Damage
		DeflectPostureDamage = _Damage.Deflect
		BlockPostureDamage = _Damage.Block
	elseif typeof(Damage) == "number" then
		DeflectPostureDamage = Damage
		BlockPostureDamage = Damage * 1.75
	end
	---not HumanoidHitted:GetAttribute("Unparryable")
	task.wait()
	if HumanoidHitted:GetAttribute("DeflectTime") and not HumanoidHitted:GetAttribute("Unparryable") then
		DamageService:DeflectHit(HumanoidHitted, Humanoid, DeflectPostureDamage)
		return false
	else
		if HumanoidHitted:GetAttribute("Block") and not HumanoidHitted:GetAttribute("Unparryable") then
			DamageService:BlockHit(HumanoidHitted, Humanoid, BlockPostureDamage)
			return false
		else
			DamageService:Hit(HumanoidHitted, Humanoid, Damage, HitEffect, ShouldStun)
		end
	end

	CharacterService:UpdateWalkSpeedAndJumpPower(HumanoidHitted)
end

-- retorna a ação que aconteceria caso um humanoid caso seja atacado
function DamageService:GetHitContext(HumanoidHitted: Humanoid)
	if HumanoidHitted:GetAttribute("IFrame") then
		return "IFrame"
	end
	if HumanoidHitted:GetAttribute("DeflectTime") and not HumanoidHitted:GetAttribute("Unparryable") then
		return "Deflect"
	else
		if HumanoidHitted:GetAttribute("Block") and not HumanoidHitted:GetAttribute("Unparryable") then
			return "Block"
		else -- if HumanoidHitted:GetAttribute("RollIFrame") then
			-- 	return "Dodge"
			-- else
			return "Hit"
		end
	end
end

function DamageService.KnitStart()
	CombatService = Knit.GetService("CombatService")
	PlayerService = Knit.GetService("PlayerService")
	RagdollService = Knit.GetService("RagdollService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
	PostureService = Knit.GetService("PostureService")
	AnimationService = Knit.GetService("AnimationService")
	RenderService = Knit.GetService("RenderService")
	CharacterService = Knit.GetService("CharacterService")
end

return DamageService
