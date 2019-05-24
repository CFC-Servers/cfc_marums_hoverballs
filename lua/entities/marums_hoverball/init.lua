AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

function ENT:Initialize()
    self.wireCInputs = { "Hover Distance", "Hover Force", "Air Resistance", "Rotation Damping", "Detect Water"}

    --self:SetModel( "models/dav0r/hoverball.mdl" )
    --self:SetModel( self.model )
    self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
    self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
    self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    self:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
    self.delayedForce = 0
    --self.hoverdistance = cvars.Number( "mhb_height" )
    --self.hoverforce = cvars.Number( "mhb_force" )
    --self.damping = cvars.Number( "mhb_air_resistance" )
    --self.rotdamping = cvars.Number( "mhb_angular_damping" )
    --self.detectswater = cvars.Bool( "mhb_detects_water" )
    self.mask = MASK_NPCWORLDSTATIC
    --self.constrainedEntities = constraint.GetAllConstrainedEntities( self )
    --if (istable(self.constrainedEntities)) then
    --  table.insert(self.constrainedEntities, self)
    --else
    --  --self.constrainedEntities = {self}
    --end
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
        phys:SetDamping( 0.4, 1 )
        phys:SetMass(50)
    end
    if WireLib then
        self.Inputs = WireLib.CreateInputs( self.Entity, self.wireCInputs)
    end
    local options = {
        hoverdistance = self.hoverdistance,
        hoverforce    =  self.hoverforce,
        damping       =  self.damping,
        rotdamping    =  self.rotdamping,
        detectswater  =  self.detectswater
    }

    duplicator.StoreEntityModifier( self, "cfc_marums_hoverball_options", options )
end

local function applyModifiers(ply, entity, data)
   if not data then return end
   table.Merge(entity, data)
end

duplicator.RegisterEntityModifier( "cfc_marums_hoverball_options", applyModifiers)

function ENT:TriggerInput(iname, value)
    if (iname == "Hover Distance") then
        self.hoverdistance = math.Clamp(value, 0, 32750)
    elseif (iname == "Hover Force") then
        self.hoverforce = math.Clamp(value, 0, 5000)
    elseif (iname == "Air Resistance") then
        self.damping = math.Clamp(value, 0, 50)
    elseif (iname == "Rotation Damping") then
        self.rotdamping = math.Clamp(value, 0, 120)
    elseif (iname == "Detect Water") then
        if( math.Round(value) == 0 || not (value == value)) then
            self.detectswater = 0
        else
            self.detectswater = 1
        end
    end
end

--function ENT:Think()
--  self.constrainedEntities = constraint.GetAllConstrainedEntities( self )
--  if (istable(self.constrainedEntities)) then
--      table.insert(self.constrainedEntities, self)
--  else
--      self.constrainedEntities = {self}
--  end
--  self:NextThink(CurTime()+1)
--  return true
--end

function ENT:PhysicsUpdate()
    if (self.detectswater) then
        self.masker = self.mask+MASK_WATER
    else
        self.masker = self.mask
    end

    local hoverdistance = self.hoverdistance
    local hoverforce = self.hoverforce
    local force = 0
    local phys = self:GetPhysicsObject()
    local detectmask = self.masker

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
