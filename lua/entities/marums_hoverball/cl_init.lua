include('shared.lua')

function ENT:Draw()
    self:DrawModel() -- Draws Model Client Side
    if WireLib then Wire_Render(self.Entity) end
end
