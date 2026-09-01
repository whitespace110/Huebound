local PauseMenu = {}

PauseMenu.paused = false

-- - Sprites - --
local pauseButton = love.graphics.newImage("assets/images/ui/icons/pause.png")
local pauseMenu = love.graphics.newImage("assets/images/ui/pause_menu.png")
local ecscapeButtonIcon = love.graphics.newImage("assets/images/ui/icons/return_to_menu.png")
local restartButtonIcon = love.graphics.newImage("assets/images/ui/icons/restart.png")
local continueButton = love.graphics.newImage("assets/images/ui/icons/continue.png")

-- - Sound Effects - --
local sounds = {}
sounds.pause = love.audio.newSource("assets/sounds/pause.wav", "static")
sounds.paused = love.audio.newSource("assets/sounds/pause_background.mp3", "stream")
sounds.paused:setLooping(true)


local pauseFont = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 25)

-- - Get the Current Pause Status - --
function PauseMenu:isPaused()
    return self.paused
end

-- - Toggle Pause - --
function PauseMenu:toggle()
    self.paused = not self.paused
    sounds.pause:play()

    if self.paused then
        sounds.paused:play()
    else
        sounds.paused:stop()
    end
end

-- - Rendering Pause and Pause Menu - --
function PauseMenu:draw(width, height)
    local x = width / 7 - pauseButton:getWidth() / 2
    local y = height / 6 - pauseButton:getHeight() / 2

    if self:isPaused() then
        -- Darkening Layer --
        love.graphics.setColor(90/255, 90/255, 90/255, 0.1)
        love.graphics.rectangle("fill", 0, 0, width, height)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(pauseFont)

        -- Continue Button --
        love.graphics.draw(continueButton, x, y)

        love.graphics.setColor(50/255, 50/255, 70/255, 0.8)

        local continueText = "ESC"
        local continueTextX = x + (continueButton:getWidth() / 2)
            - pauseFont:getWidth(continueText) / 2

        love.graphics.print(
            continueText,
            continueTextX,
            y + continueButton:getHeight() + 5
        )

        -- Restart Button --
        local restartX = width / 7 - continueButton:getWidth() / 2
        local restartY = height / 1.2 - restartButtonIcon:getHeight()

        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(
            restartButtonIcon,
            restartX,
            restartY
        )

        love.graphics.setColor(50/255, 50/255, 70/255, 0.8)

        local restartText = "R"
        local restartTextX = restartX
            + restartButtonIcon:getWidth() / 2
            - pauseFont:getWidth(restartText) / 2

        love.graphics.print(
            restartText,
            restartTextX,
            restartY + restartButtonIcon:getHeight() + 5
        )
        love.graphics.setColor(1, 1, 1, 1)

        -- Return to Menu Button --
        local menuX = restartX + restartButtonIcon:getWidth() + 50
        local menuY = restartY

        love.graphics.draw(
            ecscapeButtonIcon,
            menuX,
            menuY
        )

        love.graphics.setColor(50/255, 50/255, 70/255, 0.8)

        local menuText = "H"
        local menuTextX = menuX
            + ecscapeButtonIcon:getWidth() / 4
            - pauseFont:getWidth(menuText) / 2

        love.graphics.print(
            menuText,
            menuTextX,
            menuY + ecscapeButtonIcon:getHeight() + 5
        )

        love.graphics.setColor(1, 1, 1, 1)
        return
    end

    -- Normal Pause Button --
    love.graphics.draw(pauseButton, x, y)
    local oldFont = love.graphics.getFont()

    love.graphics.setColor(50/255, 50/255, 70/255, 0.8)
    love.graphics.setFont(pauseFont)

    local pauseText = "ESC"
    local pauseTextX = x + (continueButton:getWidth() / 2)
        - pauseFont:getWidth(pauseText) / 2

    love.graphics.print(
        pauseText,
        pauseTextX,
        y + continueButton:getHeight() + 5
    )

    love.graphics.setFont(oldFont)
end

return PauseMenu
