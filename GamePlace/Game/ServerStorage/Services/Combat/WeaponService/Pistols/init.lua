local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Default
local Knit = require(ReplicatedStorage.Packages.Knit)
local FastCast = require(game.ReplicatedStorage.Modules.FastCastRedux)
local Request = ReplicatedStorage.Events:WaitForChild("Requests") :: RemoteFunction
local WeaponService
local HitboxService
local DamageService
local DebounceService
local CharacterService
local HotbarService
local AnimationService
local RenderService
local RagdollService
local DebugService

local Validate = require(game.ReplicatedStorage.Validate)

Pistols = {
    Attack = function(Character : Model, Data)
        local Player = game.Players:GetPlayerFromCharacter(Character)
        local PlayerMouseInfo = Request:InvokeClient(Player, "GetMouseInfo") ---- achar um jeito melhor de fazer isso dps
        local Humanoid = Character.Humanoid
		local Tool = HotbarService:GetEquippedTool(Character)
		if not Tool then
			return
		end
		if not Validate:CanAttack(Humanoid) then
			return
		end
		local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)

		-- AnimationService:StopM1Animation(Humanoid)
		local Counter = Humanoid:GetAttribute("ComboCounter")

		local AnimationPath: Animation = AnimationsFolder.Hit[Counter]
		local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(AnimationPath)
        local Speed = Animation.Length/1.3
		Animation.Priority = Enum.AnimationPriority.Action
		Animation.Name = "M1_" .. tostring(Counter)
		Animation:Play()
        Animation:AdjustSpeed(1.4)
        
		local SwingSpeed = Tool:GetAttribute("SwingSpeed") or 0.3
		DebounceService:AddDebounce(Humanoid, "AttackCombo", Speed, true)
		Humanoid:SetAttribute("LastAttackTick", tick())

		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)

		local Damage = Tool:GetAttribute("Damage") or 5

        if PlayerMouseInfo.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
            
            local Ti = TweenInfo.new(Animation.Length * .3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(Character.PrimaryPart, Ti, {CFrame = CFrame.new(Character.PrimaryPart.Position) * CFrame.Angles(0,select(2, PlayerMouseInfo.MouseCFrame:ToEulerAnglesYXZ()),0)})
            tween:Play()
        end

        local Markers = AnimationService:GetAllAnimationEventNames(AnimationPath.AnimationId)

        WeaponService:IncreaseComboCounter(Humanoid)

        if #Markers > 0 then
            Animation:GetMarkerReachedSignal("Shot"):Once(function(p)
                local Origin = Tool:FindFirstChild("Origin", true)
                if p == "Right" or p == "Left" then
                    if p == "Right" then
                        Origin = Tool:WaitForChild("RightArm"):FindFirstChild("Origin", true)
                    else
                        Origin = Tool:WaitForChild("LeftArm"):FindFirstChild("Origin", true)
                    end
                end
                local shotRenderData = RenderService:CreateRenderData(Character.Humanoid, "Shots", "Default", {Origin = Origin})
                RenderService:RenderForPlayers(shotRenderData)
                local RaycastParam = RaycastParams.new()
                RaycastParam.FilterType = Enum.RaycastFilterType.Exclude
                RaycastParam.FilterDescendantsInstances = {Character, workspace:WaitForChild("Debug")}
                PlayerMouseInfo = Request:InvokeClient(Player, "GetMouseInfo")
                
                local Result = Workspace:Spherecast(Origin.Position,.1,(PlayerMouseInfo.MouseCFrame.Position - Origin.Position).Unit * 1000, RaycastParam)
                if Result then
                    local enemies = HitboxService:GetCharactersInCircleArea(Result.Position, .1)
                    
                    for _, Enemy in enemies do
                        
                        DebounceService:AddDebounce(Humanoid, "HitboxStart", 0.05)
                        WeaponService:TriggerHittedEvent(Enemy.Humanoid, Humanoid)
                        DamageService:TryHit(Enemy.Humanoid, Humanoid, Damage, "None")
                    end

                end      
                
            end)
        end
    end
}


Pistols.Start = function(default)
    Default = default

    DebugService = Knit.GetService("DebugService")
    RagdollService = Knit.GetService("RagdollService")
    RenderService = Knit.GetService("RenderService")
	WeaponService = Knit.GetService("WeaponService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	DebounceService = Knit.GetService("DebounceService")
	CharacterService = Knit.GetService("CharacterService")
	HotbarService = Knit.GetService("HotbarService")
	AnimationService = Knit.GetService("AnimationService")
end

return Pistols