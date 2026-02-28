AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/props_c17/concrete_barrier001a.mdl" -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 2400
ENT.SightDistance = 50
ENT.HullType = HULL_HUMAN
ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.SightAngle = 90 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.LastSeenEnemyTimeUntilReset = 60 -- Time until it resets its enemy if its current enemy is not visible
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Oil" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasBloodDecal = false
ENT.PlayerFriendly = true -- Makes the SNPC friendly to the player and HL2 Resistance
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
-- Miscellaneous ---------------------------------------------------------------------------------------------------------------------------------------------
-- ====== Other Variables ====== --
ENT.RunAwayOnUnknownDamage = false -- Should run away on damage
ENT.HasRangeAttack = false -- Should the SNPC have a range attack?
ENT.HasFootStepSound = false
ENT.SoundTbl_FootStep = {}
ENT.CanTurnWhileStationary = false
ENT.HasOnPlayerSight = true

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

ENT.SoundTbl_Alert = {
	
}
ENT.SoundTbl_RangeAttack = {
	
}

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
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	timer.Simple(0, function()
		timer.Simple(0.1, function()
			HORDE:DropTurret(self)
		end)
	end)
end

function ENT:CustomOnMeleeAttack_AfterChecks( hitEnt, isProp )
	if isProp then return end
	if self:Horde_Debuff_Active[HORDE.Status_Ignite] then
		local e = EffectData()
		e:SetOrigin( self:GetPos() )
		for _, ent in pairs( ents.FindInSphere( self:GetPos(), 150 ) ) do
			if not ent:IsPlayer() then
				local Trace = util.TraceLine( {
					start = self:WorldSpaceCenter(),
					endpos = ent:WorldSpaceCenter(),
					mask = MASK_SOLID_BRUSHONLY
				} )
				if not Trace.HitWorld then
					ent:Horde_AddDebuffBuildup( HORDE.Status_Ignite, 50, self )
				end
			end
		end
		sound.Play( "ambient/energy/newspark07.wav", self:GetPos() )
	end
end
function ENT:CustomOnTakeDamage_BeforeDamage( dmginfo, hitgroup )
	if HORDE:IsFireDamage( dmginfo ) then
		dmginfo:ScaleDamage( 1.5 )
	elseif HORDE:IsShockDamage( dmginfo ) then
		dmginfo:ScaleDamage( 0 )
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/

VJ.AddNPC("Wood Barricade","npc_vj_horde_barricade_wood", "Horde")
ENT.Horde_TurretMinion = true

function ENT:Follow(ply)
	if self:GetNWEntity("HordeOwner") ~= ply then return end

	self:GetPhysicsObject():EnableMotion(true)
	ply:PickupObject(self)
end