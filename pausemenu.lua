local PauseMenu = {}

PauseMenu.paused = false

-- - Sprites - --
local pauseButton = love.graphics.newImage("assets/images/ui/icons/pause.png")
local pauseMenu = love.graphics.newImage("assets/images/ui/pause_menu.png")
local ecscapeButton = love.graphics.newImage("assets/images/ui/button2.png")
local restartButton = love.graphics.newImage("assets/images/ui/button3.png")
local continueButton = love.graphics.newImage("assets/images/ui/button4.png")
local ecscapeButtonIcon = love.graphics.newImage("assets/images/ui/icons/return_to_menu.png")
local restartButtonIcon = love.graphics.newImage("assets/images/ui/icons/restart.png")
local continueButtonIcon = love.graphics.newImage("assets/images/ui/icons/continue.png")

local pauseFont = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 40)

-- - Get the Current Pause Status - --
function PauseMenu:isPaused()
    return self.paused
end

-- - Toggle Pause - --
function PauseMenu:toggle()
    self.paused = not self.paused
end

-- - Updating Pause Menu - --
function PauseMenu:update(dt, width, height)
    if self.paused then -- check if paused
        return
    end

    -- Clicking the Button Pauses --
    if not self.paused then
        local mouseX, mouseY = love.mouse.getPosition()

        local x = width / 7 - pauseButton:getWidth() / 2 - 90
        local y = height / 6 - pauseButton:getHeight() / 2 - 50

        if love.mouse.isDown(1)
            and mouseX >= x
            and mouseX <= x + pauseButton:getWidth()
            and mouseY >= y
            and mouseY <= y + pauseButton:getHeight()
        then
            self:toggle()
        end
    end

    -- Pause Menu Buttons --
    local menuX = width / 2 - pauseMenu:getWidth() / 2
    local menuY = height / 2 - pauseMenu:getHeight() / 2

    local buttonGap = 24
    local buttonsWidth = 64 * 3 + buttonGap * 2
    local buttonsX = menuX + pauseMenu:getWidth() / 2 - buttonsWidth / 2
    local buttonsY = menuY + pauseMenu:getHeight() - 115

    -- continue --
    local continueX = buttonsX + (64 + buttonGap) * 2

    local mouseX, mouseY = love.mouse.getPosition()

    if love.mouse.isDown(1)
        and mouseX >= continueX
        and mouseX <= continueX + 64
        and mouseY >= buttonsY
        and mouseY <= buttonsY + 64
    then
        self:toggle()
    end
end

-- - Rendering Pause and Pause Menu - --
function PauseMenu:draw(width, height)
    local x = width / 7 - pauseButton:getWidth() / 2
    local y = height / 6 - pauseButton:getHeight() / 2

    -- Rendering Pause Menu --
    if self:isPaused() then
        local menuX = width / 2 - pauseMenu:getWidth() / 2
        local menuY = height / 2 - pauseMenu:getHeight() / 2

        -- Main Menu --
        love.graphics.setColor(180/255, 180/255, 180/255, 0.1)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1, 0.85)
        love.graphics.draw(pauseMenu, menuX, menuY)

        -- text --
        local text = "LEVEL 0"
        local textX = menuX + pauseMenu:getWidth() / 2 - pauseFont:getWidth(text) / 2 - 10
        local textY = menuY + 50

        love.graphics.print(text, textX, textY)

        -- buttons --
        local buttonGap = 24

        local buttonsWidth = 64 * 3 + buttonGap * 2
        local buttonsX = menuX + pauseMenu:getWidth() / 2 - buttonsWidth / 2
        local buttonsY = menuY + pauseMenu:getHeight() - 120

        love.graphics.draw(ecscapeButton, buttonsX, buttonsY)
        love.graphics.draw(restartButton, buttonsX + 64 + buttonGap, buttonsY)
        love.graphics.draw(continueButton, buttonsX + (64 + buttonGap) * 2, buttonsY)

        -- icons --
        local iconSize = 32

        love.graphics.draw(
            ecscapeButtonIcon,
            buttonsX + 16,
            buttonsY + 16
        )

        love.graphics.draw(
            restartButtonIcon,
            buttonsX + 64 + buttonGap + 16,
            buttonsY + 16
        )

        love.graphics.draw(
            continueButtonIcon,
            buttonsX + (64 + buttonGap) * 2 + 16,
            buttonsY + 16
        )
    end

    -- Rendering Pause Button --
    if not self:isPaused() then
        love.graphics.draw(pauseButton, x, y)
    end
end

return PauseMenu
