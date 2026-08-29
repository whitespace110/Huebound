local Timer = {}

Timer.time = 0
Timer.running = false
love.graphics.setDefaultFilter("nearest", "nearest")

-- - Creating Font - --
local timerFont = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 48)

-- - Timer Start - --
function Timer:start()
    self.running = true
end

-- - Timer Stop - --
function Timer:stop()
    self.running = false
end

-- - Timer Reset - --
function Timer:reset()
    self.time = 0
end

-- - Timer Start - --
function Timer:update(dt)
    if self.running then self.time = self.time + dt end
end

-- - Render Timer - --
function Timer:draw(width, height)
    local mainFont = love.graphics.getFont()

    love.graphics.setFont(timerFont)

    local text = string.format("%.2f", self.time)
    love.graphics.print(text, width / 2 - 20, height / 6 - timerFont:getHeight() / 2)

    love.graphics.setFont(mainFont)
end

return Timer
