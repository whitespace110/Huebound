local LevelMenu = {}

LevelMenu.levelIndex = 1
LevelMenu.selected = false
LevelMenu.secondaryOpacity = 1
LevelMenu.opacity = 1
LevelMenu.clickCooldown = 0
LevelMenu.drawn = true

-- - Data - --
local save = require("save")

-- - Sprites - --
local levelButton = love.graphics.newImage("assets/images/ui/button2.png")
local lockedlevelButton = love.graphics.newImage("assets/images/ui/button2_locked.png")
local rightButton = love.graphics.newImage("assets/images/ui/right.png")
local leftButton = love.graphics.newImage("assets/images/ui/left.png")
local popup = love.graphics.newImage("assets/images/ui/popup.png")
local resetButton = love.graphics.newImage("assets/images/ui/icons/restart.png")
local homeButton = love.graphics.newImage("assets/images/ui/icons/return_to_menu.png")

-- - Sounds - --
local tick = love.audio.newSource("assets/sounds/tick.wav", "static")
local select = love.audio.newSource("assets/sounds/select.wav", "static")

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

    if not LevelMenu.selected then
        if love.mouse.isDown(1) then
            -- Level Selection --
            if mouseX >= buttonX
                and mouseX <= buttonX + levelButton:getWidth() * 1.5
                and mouseY >= buttonY
                and mouseY <= buttonY + levelButton:getHeight() * 1.5
                and data["level" .. LevelMenu.levelIndex].unlocked then
                LevelMenu.selected = true
                LevelMenu.drawn = false
                select:play()
            end

            -- Left Arrow --
            if mouseX >= leftX - 160
                and mouseX <= leftX - 160 + leftButton:getWidth() * 1.5
                and mouseY >= arrowY
                and mouseY <= arrowY + leftButton:getHeight() * 1.5
                and LevelMenu.clickCooldown <= 0 then
                if LevelMenu.levelIndex ~= 1 then
                    LevelMenu.levelIndex = LevelMenu.levelIndex - 1
                    tick:play()
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
                    tick:play()
                    LevelMenu.clickCooldown = 0.4
                end
                mapload("level" .. LevelMenu.levelIndex)
            end
        end
    end

    -- Redraw if Necesery --
    if LevelMenu.drawn then
        LevelMenu:redraw(dt, timer)
        LevelMenu.selected = false
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

-- - Rerendering the Levelmenu - --
function LevelMenu:redraw(dt, timer)
    if not LevelMenu.selected then
        LevelMenu.opacity = LevelMenu.opacity + dt
        if LevelMenu.opacity >= 1 then
            LevelMenu.opacity = 1
            LevelMenu.secondaryOpacity = LevelMenu.secondaryOpacity + dt
        end

        -- Resset Timer --
        if LevelMenu.secondaryOpacity >= 1 then
            LevelMenu.secondaryOpacity = 1
            timer:stop()
            timer:reset()
        end
    end
end

-- - Rendering the Endscreen - --
function LevelMenu:endscreen(width, height, timer, attempts, isfinished)
    if isfinished then
        love.graphics.setColor(1, 1, 1, 1)

        local scale = 2
        local popupWidth = popup:getWidth() * scale
        local popupHeight = popup:getHeight() * scale

        local x = (width - popupWidth) / 2
        local y = (height - popupHeight) / 2

        love.graphics.draw(popup, x, y, 0, scale, scale)

        -- Title
        love.graphics.setFont(font)

        local title = "LEVEL COMPLETE"
        local titleWidth = font:getWidth(title)

        love.graphics.print(
            title,
            x + (popupWidth - titleWidth) / 2,
            y + 35
        )

        -- Stats
        love.graphics.setFont(statFont)

        local timeText = string.format("Time: %.2f", timer.time)
        local attemptsText = "Attempts: " .. attempts

        local timeWidth = statFont:getWidth(timeText)
        local attemptsWidth = statFont:getWidth(attemptsText)

        love.graphics.print(
            timeText,
            x + (popupWidth - timeWidth) / 2,
            y + 115
        )

        love.graphics.print(
            attemptsText,
            x + (popupWidth - attemptsWidth) / 2,
            y + 155
        )

        -- Buttons
        local buttonScale = 1.5

        local resetX = x + popupWidth / 2 - resetButton:getWidth() * buttonScale - 10
        local resetY = y + popupHeight - resetButton:getHeight() * buttonScale - 30

        local homeX = x + popupWidth / 2 + 10
        local homeY = resetY

        love.graphics.draw(resetButton, resetX, resetY, 0, buttonScale, buttonScale)
        love.graphics.draw(homeButton, homeX, homeY, 0, buttonScale, buttonScale)
    end
end

-- - Endscreen Buttons - --
function LevelMenu:keypressed(key, isfinished, player, map, timer, loadLevel)
    if not isfinished then
        return
    end

    if key == "r" then
        loadLevel("level" .. LevelMenu.levelIndex)

    elseif key == "h" then
        player.collider:setPosition(player:getSpawn(map))
        player.collider:setLinearVelocity(0, 0)
        player.color = "red"
        player.direction = "right"
        timer:stop()
        timer:reset()
        player.complete = false
        LevelMenu.drawn = true
    end
end

return LevelMenu
