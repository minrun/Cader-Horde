AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/props_furniture/bakery_counter3.mdl" -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 2400
ENT.CriticalHealthPoint = 100 -- The point in which the entity is disabled
ENT.SightDistance = 500
ENT.HullType = HULL_WIDE_SHORT
ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.SightAngle = 180 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.LastSeenEnemyTimeUntilReset = 60 -- Time until it resets its enemy if its current enemy is not visible
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY","CLASS_COMBINE"} -- NPCs with the same class with be allied to each other
ENT.FriendsWithAllPlayerAllies = true
ENT.PlayerFriendly = true
ENT.BloodColor = "Oil" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasBloodDecal = false


ENT.DisableDefaultMeleeAttackDamageCode = true
ENT.HasMeleeAttack = true
ENT.NextAnyAttackTime_Melee = 0.5
ENT.MeleeAttackDistance = 60 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 60 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.1 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 30
ENT.BonusDebuffDamage = 60
ENT.MeleeAttackBleedEnemy = false -- Should the player bleed when attacked by melee
ENT.MeleeAttackDamageType = DMG_SLASH


-- Miscellaneous ---------------------------------------------------------------------------------------------------------------------------------------------
-- ====== Other Variables ====== --
ENT.RunAwayOnUnknownDamage = false -- Should run away on damage
ENT.HasRangeAttack = false -- Should the SNPC have a range attack?
ENT.HasFootStepSound = false
ENT.SoundTbl_FootStep = {}
ENT.CanTurnWhileStationary = false
ENT.HasOnPlayerSight = true
ENT.HasAllies = true
ENT.HasDeathRagdoll = false 
ENT.VJFriendly = false
-- ====== Sounds ====== --
ENT.HasSounds = true
ENT.SoundTbl_CombatIdle = {
	
}
ENT.SoundTbl_Idle = {
	
}
ENT.SoundTbl_Pain = {
	"physics/wood/wood_box_impact_bullet3.wav",
	"physics/wood/wood_solid_impact_bullet1.wav",
	"physics/wood/wood_solid_impact_bullet3.wav"
}

ENT.SoundTbl_Death = {
	"common/bugreporter_failed.wav"
}
--	"physics/wood/wood_furniture_break1.wav",
--	"physics/wood/wood_furniture_break2.wav"
ENT.SoundTbl_MeleeAttack = {
	"physics/metal/metal_chainlink_impact_soft2.wav",
	"physics/metal/metal_chainlink_impact_soft3.wav",
	"physics/metal/metal_chainlink_impact_soft1.wav"
}
ENT.SoundTbl_MeleeAttackMiss = {

}
ENT.EntitiesToNoCollide = {
	"player",
	"npc_vj_horde_spectre",
	"npc_vj_horde_antlion",
	"npc_vj_horde_smg_turret",
	"npc_vj_horde_shotgun_turret",
	"npc_vj_horde_rocket_turret",
	"npc_vj_horde_laser_turret",
	"npc_vj_horde_class_survivor",
	"npc_vj_horde_class_assault",
	"npc_vj_horde_vortigaunt",
	"npc_vj_horde_shadow_hulk",
	"npc_vj_horde_combat_bot",
	"npc_manhack",
	"npc_vj_horde_barricade_metal",
	"npc_vj_horde_barricade_wood"
}-- Really need to make a variable that can be called for all allied NPCs that want it cause im certain this won't work unless the others have us in it aswell... or one call makes em all nocollided? dunno

ENT.Horde_Immune_Status = {
	[HORDE.Status_Bleeding] = true,
	[HORDE.Status_Frostbite] = true,
	[HORDE.Status_Ignite] = false,
	[HORDE.Status_Break] = true,
	[HORDE.Status_Necrosis] = true,
	[HORDE.Status_Hemorrhage] = true,
	[HORDE.Status_Shock] = true,
}
ENT.Immune_AcidPoisonRadiation = true

function ENT:CustomOnInitialize()
	self.Horde_Owner = self:GetNWEntity("HordeOwner")
	self:SetHealth(self.StartHealth)
	self:AddRelationship("npc_manhack D_LI 99")
 
	timer.Simple(0, function()
		timer.Simple(0.1, function()
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			HORDE:DropTurret(self)
		end)
	end)
end


ENT.CriticalState = false -- What health state are we in
function ENT:CustomOnThink()
	if self.Critical then
		-- We are Critically Injured
		if not self.CriticalState then
			-- We Just went Crit
			sound.Play( "physics/wood/wood_furniture_break1.wav", self:GetPos() )
			-- Make a dying gasp
			self.HasMeleeAttack = false 
			--We can nolonger fight
			self:SetCollisionGroup(COLLISION_GROUP_WORLD) -- specifically for barricades
			self:AddFlags(FL_NOTARGET) -- Stop Attacking us
			self:SetColor(Color(150, 0, 0)) -- replace with or add wireframe material or bodygroup, if available
			self.CriticalState = true --
		else
			-- We still are
			if self:Health() > self:GetMaxHealth() / 2 then -- get back in the fight
        		self.Critical = false 
			end
		end
	else
		-- We are not Critical
		if self.CriticalState then -- Reset Flags if we just returned from crit
			self.CriticalState = false
			self:SetColor(Color(255, 255, 255))
			self.HasMeleeAttack = true
			self:RemoveFlags(FL_NOTARGET) -- we are alive again, attack us
			self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)-- specifically for barricades
		end
		--Everything else in a normal custom think goes down here


		
	end
	-- any thing you want to happen regardless of condition?
end


ENT.Critical = false -- Did we hit the health threshold
function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
    if not self.Critical and self:Health() <= self.CriticalHealthPoint then
        self.Critical = true
    end
end

function ENT:CustomOnMeleeAttack_AfterChecks( hitEnt, isProp )
	if isProp then return end
	local dmg = DamageInfo()
	dmg:SetAttacker( self.Horde_Owner )
	dmg:SetInflictor(self)
	dmg:SetDamage( self.MeleeAttackDamage )
	dmg:SetDamageType( self.MeleeAttackDamageType )
	if self.Horde_Debuff_Active and self.Horde_Debuff_Active[HORDE.Status_Ignite] then
		hitEnt:Horde_AddDebuffBuildup( HORDE.Status_Ignite, 50, self )
		dmg:AddDamage( self.BonusDebuffDamage )
		dmg:SetAttacker( self )
		dmg:SetDamageType( DMG_BURN )
		sound.Play( "ambient/fire/mtov_flame2.wav", self:GetPos() )
	end
	dmg:SetDamagePosition(hitEnt:GetPos() + hitEnt:OBBCenter())
	hitEnt:TakeDamageInfo(dmg)
end

function ENT:CustomOnTakeDamage_BeforeDamage( dmginfo, hitgroup )
	if HORDE:IsFireDamage( dmginfo ) 
	then
		dmginfo:ScaleDamage( 1.5 )
	elseif HORDE:IsLightningDamage( dmginfo ) 
	then
		dmginfo:ScaleDamage( 0 )
	end
	dmginfo:SetMaxDamage(math.floor(self:Health() - 100))
end

VJ.AddNPC("Wood Barricade","npc_vj_horde_barricade_wood", "Horde")
ENT.Horde_TurretMinion = true

function ENT:Follow(ply)
	if self:GetNWEntity("HordeOwner") ~= ply then return end

	self:GetPhysicsObject():EnableMotion(true)
	ply:PickupObject(self)
end