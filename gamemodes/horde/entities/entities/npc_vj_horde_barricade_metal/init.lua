AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/props_c17/concrete_barrier001a.mdl" -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 2400
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
ENT.HasMeleeAttack = true
ENT.NextAnyAttackTime_Melee = 0.5
ENT.MeleeAttackDistance = 35 -- How close does it have to be until it attacks?
ENT.MeleeAttackAngleRadius = 100 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageDistance = 35 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.1 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 15
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

ENT.VJFriendly = false
-- ====== Sounds ====== --
ENT.HasSounds = true
ENT.SoundTbl_CombatIdle = {
	
}
ENT.SoundTbl_Idle = {
	
}
ENT.SoundTbl_Pain = {
	"physics/metal/metal_sheet_impact_hard2.wav",
	"physics/metal/metal_sheet_impact_hard6.wav",
	"physics/metal/metal_sheet_impact_hard8.wav"
}

ENT.SoundTbl_Death = {
	"physics/metal/metal_large_debris1.wav"
}
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
	"npc_manhack"
}

ENT.Horde_Immune_Status = {
	[HORDE.Status_Bleeding] = true,
	[HORDE.Status_Frostbite] = true,
	[HORDE.Status_Ignite] = true,
	[HORDE.Status_Break] = true,
	[HORDE.Status_Necrosis] = true,
	[HORDE.Status_Hemorrhage] = true,
}
ENT.Immune_AcidPoisonRadiation = true

function ENT:CustomOnInitialize()
	self.MeleeAttackDamageType = DMG_SLASH
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
ENT.CriticalState = false
function ENT:CustomOnThink()
	if self.Critical then
		if not self.CriticalState then
			self.HasMeleeAttack = false
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:AddFlags(FL_NOTARGET)
			self:SetColor(Color(150, 0, 0))
			self.CriticalState = true
		else
			if self:Health() > self:GetMaxHealth() / 2 
		then
        		self.Critical = false
			end
		end
	else
		if self.CriticalState then
			self.CriticalState = false
			self:SetColor(Color(255, 255, 255))
			self.HasMeleeAttack = true
			self:RemoveFlags(FL_NOTARGET)
			self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		end




	end
end
ENT.Critical = false
function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
    if not self.Critical and self:Health() < self:GetMaxHealth() / 4 then
        self.Critical = true
    end
end

function ENT:CustomOnMeleeAttack_AfterChecks( hitEnt, isProp )
	if isProp then return end

	if self.Horde_Debuff_Active[HORDE.Status_Shock] then
		hitEnt:Horde_AddDebuffBuildup( HORDE.Status_Shock, 50, self )
		
		sound.Play( "", self:GetPos() )
	end
end
function ENT:CustomOnTakeDamage_BeforeDamage( dmginfo, hitgroup )
	if not self.Critical then
		if HORDE:IsFireDamage( dmginfo ) then
			dmginfo:ScaleDamage( 0 )
		elseif HORDE:IsLightningDamage( dmginfo ) then
			dmginfo:ScaleDamage( 1.5 )
		end
	else
		dmginfo:ScaleDamage( 0 )
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/

VJ.AddNPC("Metal Barricade","npc_vj_horde_barricade_metal", "Horde")
ENT.Horde_TurretMinion = true

function ENT:Follow(ply)
	if self:GetNWEntity("HordeOwner") ~= ply then return end

	self:GetPhysicsObject():EnableMotion(true)
	ply:PickupObject(self)
end