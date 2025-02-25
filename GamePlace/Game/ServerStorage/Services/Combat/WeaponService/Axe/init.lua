local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Validate = require(game.ReplicatedStorage.Validate)
local GameData = require(ServerStorage.GameData)
local WeaponService
local HitboxService
local DamageService
local DebounceService
local CharacterService
local HotbarService
local AnimationService
local SkillService
local RagdollService


local Default
Sword = {
	Attack = function(...)
		Default.Attack(...)
	end,

	StrongAttack = function(Character, Data)
		local Humanoid = Character.Humanoid
        SkillService:UseSkill(Humanoid, "DefaultStrongAttack", Data)
	end,
}

function Sword.Start(default)
    HotbarService = Knit.GetService("HotbarService")
    AnimationService = Knit.GetService("AnimationService")
    DebounceService = Knit.GetService("DebounceService")
    CharacterService = Knit.GetService("CharacterService")
    SkillService = Knit.GetService("SkillService")
	Default = default
end

return Sword
