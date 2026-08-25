local Menu = {}

-- - Menu Parametres - --
local backgroundOpacity = 1
local opacity = 1
local started = false
love.graphics.setDefaultFilter("nearest", "nearest")

-- - Creating Font - --
local font = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 60)
love.graphics.setFont(font)

-- - Creating Title - --
local spriteSheet = love.graphics.newImage("assets/images/ui/huebound_spritesheet.png")
local titleGrid
local titleAnimation

-- - Button - --
local buttonSprite = love.graphics.newImage("assets/images/ui/button1.png")
local buttonScale = 2
local buttonX, buttonY = 0, 0
local buttonWidth = buttonSprite:getWidth() * buttonScale
local buttonHeight = buttonSprite:getHeight() * buttonScale

-- - Load Title - --
function Menu:loadTitle(anim8)
    local titleWidth = spriteSheet:getWidth() / 3
    local titleHeight = spriteSheet:getHeight()

    titleGrid = anim8.newGrid(
        titleWidth,
        titleHeight,
        spriteSheet:getWidth(),
        spriteSheet:getHeight()
    )

    titleAnimation = anim8.newAnimation(
        titleGrid("1-3", 1),
        1
    )
end

-- - Update Main Menu - --
function Menu:update(dt)
    -- Updating Blackscreen --
    if started then opacity = opacity - dt end
    if started and opacity <= 0 then backgroundOpacity = backgroundOpacity - dt end

    -- Updating Mouse --
    local mouseX, mouseY = love.mouse.getPosition()

    if not started then
        if love.mouse.isDown(1)
            and mouseX >= buttonX
            and mouseX <= buttonX + buttonWidth
            and mouseY >= buttonY
            and mouseY <= buttonY + buttonHeight then -- > checking if the moue is above the button
            started = true -- > starting indicator
        end
    end

    -- Upadte Title --
    if not started and backgroundOpacity >= 0 then titleAnimation:update(dt) end
end

-- - Render Main Menu - --
function Menu:draw(width, height)
    -- Rendering Black screen --
    love.graphics.setColor(0, 0, 0, backgroundOpacity)
    love.graphics.rectangle("fill", 0, 0, width, height)

    -- Rendering Tilte --
    love.graphics.setColor(1, 1, 1, opacity) -- > resetting color

    local titleWidth = spriteSheet:getWidth() / 3
    local titleHeight = spriteSheet:getHeight()
    local titleScale = 2

    titleAnimation:draw(
        spriteSheet,
        width / 2 - (titleWidth * titleScale) / 2,
        height / 3 - (titleHeight * titleScale) / 2,
        0,
        titleScale
    )

    -- Rendering Button --
    love.graphics.setColor(1, 1, 1, opacity) -- > resetting color

    buttonX = width / 2 - buttonWidth / 2
    buttonY = height / 1.5 - buttonHeight / 2

    love.graphics.draw(
        buttonSprite,
        buttonX,
        buttonY,
        0,
        buttonScale
    )

    -- text --
    local text = "Play"
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()

    local textX = buttonX + (buttonWidth - textWidth) / 2
    local textY = buttonY + (buttonHeight - textHeight) / 2

    love.graphics.print(text, textX, textY)
end

return Menu
