TOOL.Category = "Construction"
TOOL.Name = "Wire Marums HoverBall"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud
--hello
TOOL.ClientConVar[ "force" ] = "100"
TOOL.ClientConVar[ "height" ] = "100"
TOOL.ClientConVar[ "air_resistance" ] = "2"
TOOL.ClientConVar[ "angular_damping" ] = "10"
TOOL.ClientConVar[ "detects_water" ] = "true"
TOOL.ClientConVar[ "model" ] = "models/dav0r/hoverball.mdl"

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL:LeftClick( trace )
	local model = self:GetClientInfo( "model" )
	if (SERVER) then
		local entity = ents.Create( "marums_hoverball" )
		entity:SetPos( trace.HitPos )
		entity.hoverdistance = 		self:GetClientNumber( "height" )
		entity.hoverforce = 		self:GetClientNumber( "force" )
		entity.damping = 			self:GetClientNumber( "air_resistance" )
		entity.rotdamping = 		self:GetClientNumber( "angular_damping" )
		entity.detectswater = 		self:GetClientNumber( "detects_water" )
		entity:SetModel(	self:GetClientInfo( "model" ) )
		entity:Spawn()
		if (IsValid(trace.Entity)) then
			local weld = constraint.Weld( entity, trace.Entity, 0, trace.PhysicsBone, 0, true , false )
		end
		undo.Create( "Marums HoverBall Wire" )
			undo.AddEntity( entity )
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()
	end
end

function TOOL:RightClick( trace )
    if(trace.Hit) then
        if(trace.Entity and IsValid(trace.Entity) and !trace.Entity:IsPlayer()) then
            self:GetOwner():ChatPrint("Hoverball Model is now set to: " .. trace.Entity:GetModel())
            TOOL.ClientConVar[ "model" ] = trace.Entity
        end
    end
end

function TOOL.BuildCPanel( panel )

	panel:AddControl("Header", { Text = "Client Options", Description = "HoverBall Model" })

	panel:AddControl( "PropSelect", { Label = "Model", ConVar = "the_wire_ball_spawner_model", Models = list.Get( "MarumsHoverballModels" ), Height = 5 } )

	panel:AddControl("Header", { Text = "Client Options", Description = "HoverBall Settings" })

	panel:AddControl("Slider", {
	    Label = "Force",
	    Type = "Float",
	    Min = "0",
	    Max = "2500",
	    Command = "the_wire_ball_spawner_force"
	})

	panel:AddControl("Slider", {
	    Label = "Height",
	    Type = "Float",
	    Min = "0",
	    Max = "37650",
	    Command = "the_wire_ball_spawner_height"
	})

	panel:AddControl("Slider", {
	    Label = "Air Resistance",
	    Type = "Float",
	    Min = "0",
	    Max = "30",
	    Command = "the_wire_ball_spawner_air_resistance"
	})

	panel:AddControl("Slider", {
	    Label = "Angular Damping",
	    Type = "Float",
	    Min = "0",
	    Max = "120",
	    Command = "the_wire_ball_spawner_angular_damping"
	})

	panel:AddControl("checkbox", {
		Label = "Hovers over water",
		Command = "the_wire_ball_spawner_detects_water"
	})
end
if (CLIENT) then
language.Add( "tool.the_wire_ball_spawner.name", "Marum's Hoverball Wire Rendition" )
language.Add( "tool.the_wire_ball_spawner.desc", "These hoverballs go up and down ramps and hills, like hovercrafts. Wiremod compatible." )
language.Add( "tool.the_wire_ball_spawner.0", "Left-click: Spawn a hoverball. Spawn on an entity to weld it. Right-click to set a model." )
language.Add( "undone.the_wire_ball_spawner", "Undone Marum's wire hoverball" )
end

list.Set( "MarumsHoverballModels", "models/dav0r/hoverball.mdl", {} )
list.Set( "MarumsHoverballModels", "models/maxofs2d/hover_basic.mdl", {} )
list.Set( "MarumsHoverballModels", "models/maxofs2d/hover_classic.mdl", {} )
list.Set( "MarumsHoverballModels", "models/maxofs2d/hover_plate.mdl", {} )
list.Set( "MarumsHoverballModels", "models/maxofs2d/hover_propeller.mdl", {} )
list.Set( "MarumsHoverballModels", "models/maxofs2d/hover_rings.mdl", {} )
list.Set( "MarumsHoverballModels", "models/Combine_Helicopter/helicopter_bomb01.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_junk/sawblade001a.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_wasteland/prison_lamp001c.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_junk/PropaneCanister001a.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_junk/plasticbucket001a.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_phx/wheels/drugster_front.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_phx/wheels/metal_wheel1.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_phx/smallwheel.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_phx/wheels/magnetic_small.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_phx/wheels/magnetic_medium.mdl", {} )
list.Set( "MarumsHoverballModels", "models/props_phx/wheels/magnetic_large.mdl", {} )
list.Set( "MarumsHoverballModels", "models/mechanics/wheels/wheel_smooth_24f.mdl", {} )
list.Set( "MarumsHoverballModels", "models/mechanics/wheels/wheel_smooth_48.mdl", {} )
list.Set( "MarumsHoverballModels", "models/mechanics/wheels/wheel_smooth_72.mdl", {} )
list.Set( "MarumsHoverballModels", "models/mechanics/wheels/wheel_smooth_18r.mdl", {} )
list.Set( "MarumsHoverballModels", "models/mechanics/wheels/wheel_smooth_24.mdl", {} )
list.Set( "MarumsHoverballModels", "models/mechanics/wheels/wheel_rounded_36s.mdl", {} )
