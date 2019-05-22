AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

function ENT:Initialize()
    self.wireCInputs = { "Hover Distance", "Hover Force", "Damping", "Rotation Damping", "Detect Water"}
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
	self.delayedForce = 0
	self.mask = MASK_NPCWORLDSTATIC
	if (self.detectswater) then
		self.mask = self.mask+MASK_WATER
	end
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetDamping( 0.4, 1 )
		phys:SetMass(50)
	end

    if WireLib then
        self.Inputs = WireLib.CreateInputs( self.Entity, self.wireCInputs)
        
end

function ENT:PhysicsUpdate()

	local hoverdistance = self.hoverdistance
	local hoverforce = self.hoverforce
	local force = 0
	local phys = self:GetPhysicsObject()
	local detectmask = self.mask

	if not ( self.damping and self.rotdamping ) then return end

	phys:SetDamping( self.damping, self.rotdamping )
	local tr = util.TraceLine( {
	start = self:GetPos(),
	endpos = self:GetPos()+Vector(0,0,-hoverdistance*2),
	filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return false end end,
	mask = detectmask
	} )

	local distance = self:GetPos():Distance(tr.HitPos)

	if (distance < hoverdistance) then
		force = -(distance-hoverdistance)*hoverforce
		phys:ApplyForceCenter(Vector(0,0,-phys:GetVelocity().z*8))
	else
		force = 0
	end

	if (force > self.delayedForce) then
		self.delayedForce = (self.delayedForce*2+force)/3
	else
		self.delayedForce = self.delayedForce*0.7
	end
	phys:ApplyForceCenter(Vector(0,0,self.delayedForce))
end
