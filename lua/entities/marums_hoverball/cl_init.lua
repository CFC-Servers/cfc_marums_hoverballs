include('shared.lua')

function ENT:Draw()
    -- self.BaseClass.Draw(self) -- Overrides Draw
    --self:DrawModel() -- Draws Model Client Side
    self.Entity:DrawModel() -- PewpewSafezone does this, so im gonna take an example.
end
