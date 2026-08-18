local Player = {}

Player.__index = Player

-- - Create Player - --
function Player:new(world)
    local self = setmetatable({}, Player)

    self.x = 640
    self.y = 360

    self.width = 42
    self.height = 48

    self.velX = 1500
    self.velY = -2000
    self.maxVel = 300

    self.cut = 10
    self.collider = world:newBSGRectangleCollider(
                    self.x,
                    self.y,
                    self.width,
                    self.height,
                    self.cut
    )
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass("Player")

    self.grounded = false

    return self
end

-- - Update Player - --
function Player:update(dt)
    -- Player Movement --
    if love.keyboard.isDown("a") then
        self.collider:applyForce(-self.velX, 0)
    elseif love.keyboard.isDown("d") then
        self.collider:applyForce(self.velX, 0)
    end

    -- Matching the player cordiates with its collider
    self.x = self.collider:getX() - self.width / 2
    self.y = self.collider:getY() - self.height / 2

    -- Ground Collision Detetcion --
    self.grounded = false -- > resetting grounded every frame

    self.collider:setPreSolve(function(collider1, collider2, contact)
        local nx, ny = contact:getNormal() -- > getting normals

        if collider2.collision_class == "Ground" then
            if ny < 0 then -- > ny == -1 -> below ground
                self.grounded = true
            end
        end
    end)

end

-- - Player Jumping - --
function Player:keypressed(key)
    if key == "space" and self.grounded then
        self.collider:applyLinearImpulse(0, self.velY)
    end
end

return Player
