local LevelMenu = {}

LevelMenu.levelIndex = 1
LevelMenu.selected = false
LevelMenu.secondaryOpacity = 1
LevelMenu.opacity = 1
LevelMenu.clickCooldown = 0

-- - Data - --
local save = require("save")

-- - Sprites - --
local levelButton = love.graphics.newImage("assets/images/ui/button2.png")
local lockedlevelButton = love.graphics.newImage("assets/images/ui/button2_locked.png")
local rightButton = love.graphics.newImage("assets/images/ui/right.png")
local leftButton = love.graphics.newImage("assets/images/ui/left.png")

local buttonX
local buttonY

local leftX
local rightX
local arrowY

-- - Font - --
local font = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 70)
local statFont = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 30)

-- - Updating Level Menu - --
function LevelMenu:update(dt, timer, mapload)
    local mouseX, mouseY = love.mouse.getPosition()

    LevelMenu.clickCooldown = math.max(0, LevelMenu.clickCooldown - dt)
    local data = save:getData()

    if love.mouse.isDown(1) then
        -- Level Selection --
        if mouseX >= buttonX
            and mouseX <= buttonX + levelButton:getWidth() * 1.5
            and mouseY >= buttonY
            and mouseY <= buttonY + levelButton:getHeight() * 1.5
            and data["level" .. LevelMenu.levelIndex].unlocked then
            LevelMenu.selected = true
        end

        -- Left Arrow --
        if mouseX >= leftX - 160
            and mouseX <= leftX - 160 + leftButton:getWidth() * 1.5
            and mouseY >= arrowY
            and mouseY <= arrowY + leftButton:getHeight() * 1.5
            and LevelMenu.clickCooldown <= 0 then
            if LevelMenu.levelIndex ~= 1 then
                LevelMenu.levelIndex = LevelMenu.levelIndex - 1
                LevelMenu.clickCooldown = 0.4
            end
            mapload("level" .. LevelMenu.levelIndex)
        end

        -- Right Arrow --
        if mouseX >= rightX + 160
            and mouseX <= rightX + 160 + rightButton:getWidth() * 1.5
            and mouseY >= arrowY
            and mouseY <= arrowY + rightButton:getHeight() * 1.5
            and LevelMenu.clickCooldown <= 0 then
            if LevelMenu.levelIndex ~= 5 then
                LevelMenu.levelIndex = LevelMenu.levelIndex + 1
                LevelMenu.clickCooldown = 0.4
            end
            mapload("level" .. LevelMenu.levelIndex)
        end
    end

    -- Fade --
    if LevelMenu.selected then
        LevelMenu.secondaryOpacity = LevelMenu.secondaryOpacity - dt
        if LevelMenu.secondaryOpacity <= 0 then
            LevelMenu.secondaryOpacity = 0
            LevelMenu.opacity = LevelMenu.opacity - dt
        end

        -- Start Timer --
        if LevelMenu.opacity <= 0 then
            LevelMenu.opacity = 0
            timer:start()
        end
    end
end

-- - Rendering of the Level Menu - --
function LevelMenu:draw(width, height)
    love.graphics.setColor(1, 1, 1, 1) -- >resetting color
    love.graphics.setColor(0, 0, 0, LevelMenu.opacity)
    love.graphics.rectangle("fill", 0, 0, width, height)

    local oldFont = love.graphics.getFont()
    love.graphics.setFont(font)

    -- Rendering Level Button --
    love.graphics.setColor(1, 1, 1, LevelMenu.secondaryOpacity) -- >resetting color

    buttonX = (width - levelButton:getWidth() * 1.5) / 2
    buttonY = (height - levelButton:getHeight() * 1.5) / 2

    local data = save:getData()
    local stats = data["level" .. LevelMenu.levelIndex]

    local text = tostring(LevelMenu.levelIndex)
    local textWidth = font:getWidth(text)
    local buttonSprite
    local unlocked = true

    if stats.unlocked then
        buttonSprite = levelButton
        unlocked = true
    else
        buttonSprite = lockedlevelButton
        unlocked = false
    end

    love.graphics.draw(buttonSprite, buttonX, buttonY, 0, 1.5, 1.5)
    if unlocked then
        love.graphics.print(
            text,
            buttonX + (levelButton:getWidth() * 1.5 - textWidth) / 2,
            buttonY + (levelButton:getHeight() * 1.5 - font:getHeight()) / 2
        )
    end

    -- Render Stats --
    love.graphics.setFont(statFont)

    local statsX = width / 2
    local statsY = buttonY + levelButton:getHeight() * 1.5 + 30

    love.graphics.print("Attempts: " .. stats.attempts, statsX - statFont:getWidth("Attempts: ") / 2, statsY)

    if stats.best_time then
        love.graphics.print(
            string.format("Best Time: %.2f", stats.best_time),
            statsX - statFont:getWidth("Best Time: %.2f") / 2,
            statsY + statFont:getHeight() + 5
        )
    else
        love.graphics.print("Best Time: --", statsX - statFont:getWidth("Best time: --") / 2, statsY + statFont:getHeight() + 5)
    end

    -- Rendering Arrow Buttons --
    leftX = 258
    rightX = width - rightButton:getWidth() * 1.5 - 258
    arrowY = (height - rightButton:getHeight() * 1.5) / 2

    love.graphics.draw(rightButton, rightX, arrowY, 0, 1.5, 1.5)
    love.graphics.draw(leftButton, leftX, arrowY, 0, 1.5, 1.5)

    love.graphics.setFont(oldFont)
end

return LevelMenu
