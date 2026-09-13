local Player = {}

Player.__index = Player

-- - Creating particles --
local Particles = require("particles")

-- - Player Spawn Point - --
function Player:getSpawn(map)
    local x, y

    if map.layers["Spawn"] then
        for i, spawnPoint in pairs(map.layers["Spawn"].objects) do
            x, y = spawnPoint.x, spawnPoint.y
            break -- > break after the spawn is found
        end
    end

    return x, y
end

-- - Create Player - --
function Player:new(world, anim8, map, save, timer, currentLevel)
    local self = setmetatable({}, Player)

    self.x, self.y = self:getSpawn(map)

    self.width = 32
    self.height = 48

    self.velX = 2500
    self.velY = -950
    self.maxVel = 320

    -- Physics Object --
    self.cut = 6
    self.collider = world:newBSGRectangleCollider(
        self.x,
        self.y,
        self.width,
        self.height,
        self.cut
    )
    self.collider:setFixedRotation(true)
    self.collider:setFriction(4)
    self.collider:setCollisionClass("Player")

    self.grounded = false
    self.moving = false
    self.complete = false
    self.direction = "right"
    self.color = "red"

    self.attempts = 1
    self.level = currentLevel

    -- Physics Updates --
    self.collider:setPreSolve(function(collider1, collider2, contact)
        -- Platform Collision Detection --
        local nx, ny = contact:getNormal()

        if collider2.collision_class == "Finish" then
            if not self.complete then save:update(self.level, timer.time, self.attempts) end
            timer:stop()
            self.complete = true
        end

        local validPlatform =
            collider2.collision_class == "Ground"
            or collider2.collision_class == "RedPlatform" and self.color == "red"
            or collider2.collision_class == "BluePlatform" and self.color == "blue"
            or collider2.collision_class == "YellowPlatform" and self.color == "yellow"

        if not validPlatform then
            contact:setEnabled(false)
            return
        end

        -- Ground Collision Detection --
        if math.abs(ny) == 1 and collider2.collision_class ~= "Finish" then
            self.grounded = true
        end
    end)

    -- Animations --
    self.spriteSheet = love.graphics.newImage("assets/images/player_spritesheet.png")
    self.grid = anim8.newGrid(32, 48, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.animations = { red = { right = {}, left = {} }, blue = { right = {}, left = {} }, yellow = { right = {}, left = {} } }
    self.animationSpeed = 0.2

    -- Right Animations --
    -- red --
    self.animations.red.right.idle = anim8.newAnimation(self.grid('1-4', 1), self.animationSpeed)
    self.animations.blue.right.idle = anim8.newAnimation(self.grid('1-4', 4), self.animationSpeed)
    self.animations.yellow.right.idle = anim8.newAnimation(self.grid('1-4', 7), self.animationSpeed)

    -- blue --
    self.animations.red.right.walk = anim8.newAnimation(self.grid('1-4', 2), self.animationSpeed)
    self.animations.blue.right.walk = anim8.newAnimation(self.grid('1-4', 5), self.animationSpeed)
    self.animations.yellow.right.walk = anim8.newAnimation(self.grid('1-4', 8), self.animationSpeed)

    -- yellow --
    self.animations.red.right.jump = anim8.newAnimation(self.grid('1-4', 3), self.animationSpeed)
    self.animations.blue.right.jump = anim8.newAnimation(self.grid('1-4', 6), self.animationSpeed)
    self.animations.yellow.right.jump = anim8.newAnimation(self.grid('1-4', 9), self.animationSpeed)

    -- Left Animations --
    -- red --
    self.animations.red.left.idle = anim8.newAnimation(self.grid('1-4', 10), self.animationSpeed)
    self.animations.blue.left.idle = anim8.newAnimation(self.grid('1-4', 13), self.animationSpeed)
    self.animations.yellow.left.idle = anim8.newAnimation(self.grid('1-4', 16), self.animationSpeed)

    -- blue --
    self.animations.red.left.walk = anim8.newAnimation(self.grid('1-4', 11), self.animationSpeed)
    self.animations.blue.left.walk = anim8.newAnimation(self.grid('1-4', 14), self.animationSpeed)
    self.animations.yellow.left.walk = anim8.newAnimation(self.grid('1-4', 17), self.animationSpeed)

    -- yellow --
    self.animations.red.left.jump = anim8.newAnimation(self.grid('1-4', 12), self.animationSpeed)
    self.animations.blue.left.jump = anim8.newAnimation(self.grid('1-4', 15), self.animationSpeed)
    self.animations.yellow.left.jump = anim8.newAnimation(self.grid('1-4', 18), self.animationSpeed)

    self.anim = self.animations.red.right.idle

    -- Sound Effects --
    self.sfx = {}
    self.sfx.jump = love.audio.newSource("assets/sounds/jump.wav", "static")
    self.sfx.switch = love.audio.newSource("assets/sounds/color_change.wav", "static")
    self.sfx.death = love.audio.newSource("assets/sounds/dead.wav", "static")

    return self
end

-- - Has the Player Completed the Level - --
function Player:isComplete()
	return self.complete
end

-- - Update Player - --
function Player:update(dt, map)
    -- Player Movement --
    self.moving = false -- > resseting movement indicator

    if love.keyboard.isDown("a") then
        self.collider:applyForce(-self.velX, 0)
        self.moving = true
        self.direction = "left"
    elseif love.keyboard.isDown("d") then
        self.collider:applyForce(self.velX, 0)
        self.moving = true
        self.direction = "right"
    end

    -- Setting max speed --
    local vx, vy = self.collider:getLinearVelocity() -- > current velocity

    if vx >= self.maxVel then -- > check if the speed is larger than the maximum velocity
        self.collider:setLinearVelocity(self.maxVel, vy) -- > slow down
    elseif vx <= -self.maxVel then
        self.collider:setLinearVelocity(-self.maxVel, vy)
    end

    -- Matching the player cordiates with its collider
    self.x = self.collider:getX() - self.width / 2
    self.y = self.collider:getY() - self.height / 2

    self.collider:setAwake(true)
    self.grounded = false -- > resetting grounded every frame
    Particles:update(dt)

    -- Player Death --
    local sx, sy = self:getSpawn(map)
    local deadzone = sy + 1440

    if self.y >= deadzone then
        self.sfx.death:play()
        self.attempts = self.attempts + 1
        self.collider:setPosition(sx, sy)
        self.collider:setLinearVelocity(0, 0)
        self.color = "red"
        self.direction = "right"
    end
end

-- - Update player animations - --
function Player:updateAnimation(dt)
    if not self.moving and self.grounded then
        self.anim = self.animations[self.color][self.direction].idle
    elseif self.moving and self.grounded then
        self.anim = self.animations[self.color][self.direction].walk
    elseif not self.grounded then
        self.anim = self.animations[self.color][self.direction].jump
    end

    self.anim:update(dt)
end

-- - Render Player - --
function Player:draw()
    love.graphics.setColor(1, 1, 1, 1) -- > resetting coloring
    Particles:draw()
    love.graphics.setColor(1, 1, 1, 1) -- > resetting coloring
    self.anim:draw(self.spriteSheet, self.x, self.y)
end

-- - Player Single Imputs - --
function Player:keypressed(key)
    -- Player jumping --
    if key == "w" and self.grounded then
        self.collider:applyLinearImpulse(0, self.velY)
        self.sfx.jump:play()
    end

    -- Player changing colors --
    if key == "left" and self.color ~= "red" then
        self.color = "red"
        self.sfx.switch:play()
        Particles:spawn(self.x + self.width / 2, self.y + self.height / 2, Particles:getColor(self.color))
    elseif key == "up" and self.color ~= "blue" then
        self.color = "blue"
        self.sfx.switch:play()
        Particles:spawn(self.x + self.width / 2, self.y + self.height / 2, Particles:getColor(self.color))
    elseif key == "right" and self.color ~= "yellow" then
        self.color = "yellow"
        self.sfx.switch:play()
        Particles:spawn(self.x + self.width / 2, self.y + self.height / 2, Particles:getColor(self.color))
    end
end

return Player
