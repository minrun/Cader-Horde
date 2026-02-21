AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
    self:SetModel("models/props_combine/combine_light001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	self:SetMaxHealth(1200)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:EnableGravity(true)
        phys:SetMass(10)
    end
	
    self.Horde_NextThink = CurTime()
    self.Horde_Owner = self:GetNWEntity("HordeOwner")
    self.Horde_ThinkInterval = 5
    self.Horde_BarbedAttackInterval = 1
    self.Horde_LastMovePos = self:GetPos()
    self.Horde_IdleStart = CurTime()
    self.Horde_Idle = false
	
	ENT.Horde_Immune_Status = {
	[HORDE.Status_Bleeding] = true,
	[HORDE.Status_Frostbite] = true,
	[HORDE.Status_Ignite] = false,
	[HORDE.Status_Break] = true,
	[HORDE.Status_Necrosis] = true,
	[HORDE.Status_Hemorrhage] = true,
	[HORDE.Status_Shock] = true
	}
	ENT.Immune_AcidPoisonRadiation = true
end


function ENT:Think()
    local curTime = CurTime()

    if not self.Horde_Idle then
        local curPos = self:GetPos()
        if curPos:DistToSqr(self.Horde_LastMovePos) > 1 then
            self.Horde_IdleStart = curTime
            self.Horde_LastMovePos = curPos
        elseif curTime - self.Horde_IdleStart >= 5 then
            local phys = self:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
                self.Horde_Idle = true
            end
        end
    end
	
    if curTime >= self.Horde_NextThink + self.Horde_ThinkInterval then

    end


end