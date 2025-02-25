local Knit = require(game.ReplicatedStorage.Packages.Knit)

local AnimationService = Knit.CreateService({
	Name = "AnimationService",
})

local AnimationsFolder = game.ReplicatedStorage.Animations
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

function AnimationService:StopAllAnimations(Humanoid: Humanoid, transition: number?, ignore: string?)
	local Animator: Animator = Humanoid:WaitForChild("Animator")
	for _, anim in Animator:GetPlayingAnimationTracks() do
		if anim.Name == ignore or anim.Name == "LocalAnimation" then
			continue
		end
		anim:Stop(transition or 0.1)
	end
end

function AnimationService:GetAllAnimationEventNames(animID: string): table
	local markers: table = {}
	local ks: KeyframeSequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(animID)
	local function recurse(ks)
		for _, child : Keyframe in pairs(ks:GetKeyframes()) do
			if #child:GetMarkers() > 0 then
				for i,v in pairs(child:GetMarkers()) do
					table.insert(markers, v)
				end
			end
		end
	end
	recurse(ks)
	return markers
end


function AnimationService:GetWeaponAnimationFolder(Humanoid: Humanoid)
	local WeaponName = AnimationsFolder:FindFirstChild(Humanoid:GetAttribute("WeaponName") or "")
	local WeaponType = AnimationsFolder:FindFirstChild(Humanoid:GetAttribute("WeaponType") or "")
	return WeaponName or WeaponType
end

function AnimationService:StopAnimationMatch(Humanoid: Humanoid, pattern: string, transition: number?)
	if not pattern then
		return
	end
	local Animator: Animator = Humanoid.Animator

	for _, anim: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
		if anim.Name:find(pattern) then
			anim:Stop(transition or 0.1)
		end
	end
end

function AnimationService:StopM1Animation(Humanoid: Humanoid)
	local Animator: Animator = Humanoid.Animator

	for _, anim: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
		if anim.Name:find("M1_") then
			anim:Stop()
		end
	end
end

function AnimationService.KnitStart() end

return AnimationService
