local Particles = {}

-- - Grouping Particles - --
Particles.list = {}

-- - Minimum and Maximum Number of Particles - --
Particles.min = 10
Particles.max = 22

-- - Getting Color - --
function Particles:getColor(color)
    local pColor

    if color == "red" then
        pColor = { 171 / 255, 82 / 255, 54 / 255}
    elseif color == "blue" then
        pColor = { 94 / 255, 108 / 255, 168 / 255}
    elseif color == "yellow" then
        pColor = { 1, 240 / 255, 36 / 255}
    end

    return pColor
end

-- - Particle Spawning - --
function Particles:spawn(x, y, color)
    for i = 1, math.random(self.min, self.max) do
        table.insert(self.list, {
            x = x,
            y = y,
            vx = math.random(-80, 80),
            vy = math.random(-160, 60),
            lifespan = 0.3,
            opacity = 1,
            color = color
        })
    end
end

-- - Particle Updating - --
function Particles:update(dt)
    for i = #self.list, 1, -1 do -- cycling through every partcle where i is the particle
        local particle = self.list[i]

        -- Updating prticle position --
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt

        particle.vy = particle.vy + 180 * dt

        -- Lowering lifespan and fading --
        particle.lifespan = particle.lifespan - dt

        if particle.lifespan <= 0 then
            particle.opacity = particle.opacity - dt
            if particle.opacity <= 0 then
                table.remove(self.list, i)
                particle.opacity = 1
            end
        end
    end
end

-- - Rendering Particles - --
function Particles:draw()
    love.graphics.setColor(1, 1, 1) -- > resetting color

	for _, particle in ipairs(self.list) do
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], particle.opacity)
        love.graphics.rectangle("fill", particle.x, particle.y, 5, 5)
	end
end

return Particles
