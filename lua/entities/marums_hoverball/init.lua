AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
-- wiremod inputs
local wireInputs = {}

function ENT:Initialize()

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
    if self.detectswater then
        self.mask = self.mask+MASK_WATER
    end

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetDamping( 0.4, 1 )
        phys:SetMass(50)
    end

    local options = {
        hoverdistance = self.hoverdistance,
        hoverforce    =  self.hoverforce,
        damping       =  self.damping,
        rotdamping    =  self.rotdamping,
        detectswater  =  self.detectswater
    }

    duplicator.StoreEntityModifier( self, "cfc_marums_hoverball_options", options )
    local inputNames = table.GetKeys( wireInputs )
    PrintTable( WireLib.CreateInputs( self, inputNames) )
end

local function applyModifiers(ply, entity, data)
   if not data then return end
   table.Merge(entity, data)
end

duplicator.RegisterEntityModifier( "cfc_marums_hoverball_options", applyModifiers)

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
local function traceFilter( ent )
    if ent:GetClass() == "prop_physics" then
        return false
    end
end


function ENT:PhysicsUpdate()

    local hoverdistance = self.hoverdistance
    local hoverforce = self.hoverforce
    local force = 0
    local phys = self:GetPhysicsObject()
    local detectmask = self.mask
    
    if not ( self.damping and self.rotdamping ) then return end
    
    phys:SetDamping( self.damping, self.rotdamping )
    local hoverOffset

    local traceDirection = Vector( 0, 0, 2 )
    local startpos = self:GetPos()
    local endpos = self:GetPos() - traceDirection * hoverdistance

    local tr = util.TraceLine{
        start = startpos,
        endpos = endpos,
        filter = traceFilter,
        mask = detectmask
    }

    local distance = self:GetPos():Distance( tr.HitPos )
    
    if distance < hoverdistance then
        force = -(distance - hoverdistance) * hoverforce
        phys:ApplyForceCenter( Vector( 0, 0, -phys:GetVelocity().z * 8 ) )
    else
        force = 0
    end
    
    if force > self.delayedForce then
        self.delayedForce = (self.delayedForce * 2 + force)/3
    else
        self.delayedForce = self.delayedForce * 0.7
    end
    phys:ApplyForceCenter( Vector( 0, 0, self.delayedForce ) )
end

-- define inputs

wireInputs["Force"] = function( ent, value )
    ent.hoverforce = value
end

wireInputs["Height"] = function( ent, value )
    ent.hoverdistance = value
end

wireInputs["Air Resistance"] = function( ent, value )
    ent.rotdamping = value
end

wireInputs["Angular Damping"] = function( ent, value )
    ent.rotdamping = value
end

function ENT:TriggerInput( iname, value )
    local inputFunction = wireInputs[iname]
    if inputFunction then
        inputFunction( self, value )
    end
end
