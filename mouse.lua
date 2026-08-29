local Mouse = {}

local mouseSprite = love.graphics.newImage("assets/images/ui/mouse.png")
local x, y = 0, 0

function Mouse:update()
    love.mouse.setVisible(false)
    x, y = love.mouse.getPosition()
end

function Mouse:draw()
	love.graphics.draw(mouseSprite, x, y)
end

return Mouse
