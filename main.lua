-- - Window - --
local scrWidth, scrHeight = love.graphics.getDimensions()

-- - Saving - --
local Save = require("save")

-- - Custom Mouse - --
local customMouse = require("mouse")

-- - World - --
local wf = require("libraries/windfield")
local world
local gravity = 500

-- - Player - --
local Player = require("player")
local player
local playerSpawnX, playerSpawnY

-- - Animations - --
local anim8 = require("libraries/anim8")

-- - Sounds - --
local sounds = {}
sounds.complete = love.audio.newSource("assets/sounds/complete.wav", "static")

-- - Map - --
local sti = require("libraries/sti")

local map
local platforms = {}
local redPlatforms = {}
local bluePlatforms = {}
local yellowPlatforms = {}

local levels = { "level1", "level2", "level3", "level4", "level5" }
local currentLevel = levels[1]

-- - Camera - --
local Camera = require("libraries/camera")
local cam

-- - Menu - --
local Menu = require("menu")

-- - Pause Menu - --
local PauseMenu = require("pausemenu")

-- - Timer - --
local Timer = require("timer")

-- - Level Completion Sensor - --
local sensor
local finish = true

-- - Shaders - --
local shader = require("shaders")
local canvas

-- - Debug - --
local debug = false


-- - Functions - --

-- Platform Collider Helper Function --
local function generateColliders()
    -- Normal Platforms --
    if map.layers["Colliders"] then -- check the type
        for i, object in pairs(map.layers["Colliders"].objects) do
            local platform = world:newRectangleCollider(object.x, object.y, object.width, object.height)

            platform:setType("static")
            platform:setCollisionClass("Ground")
            table.insert(platforms, platform) -- keep track of the objects
        end
    end
    -- Red Platforms --
    if map.layers["RedColliders"] then -- check the type
        for i, object in pairs(map.layers["RedColliders"].objects) do
            local redPlatform = world:newRectangleCollider(object.x, object.y, object.width, object.height)

            redPlatform:setType("static")
            redPlatform:setCollisionClass("RedPlatform")
            table.insert(redPlatforms, redPlatform) -- keep track of the objects
        end
    end

    -- Blue Platforms --
    if map.layers["BlueColliders"] then -- check the type
        for i, object in pairs(map.layers["BlueColliders"].objects) do
            local bluePlatform = world:newRectangleCollider(object.x, object.y, object.width, object.height)

            bluePlatform:setType("static")
            bluePlatform:setCollisionClass("BluePlatform")
            table.insert(bluePlatforms, bluePlatform) -- keep track of the objects
        end
    end

    -- Yellow Platforms --
    if map.layers["YellowColliders"] then -- check the type
        for i, object in pairs(map.layers["YellowColliders"].objects) do
            local yellowPlatform = world:newRectangleCollider(object.x, object.y, object.width, object.height)

            yellowPlatform:setType("static")
            yellowPlatform:setCollisionClass("YellowPlatform")
            table.insert(yellowPlatforms, yellowPlatform) -- keep track of the objects
        end
    end
end

-- - End of Level Helper Function - --
local function levelFinish()
	if map.layers["CompleteLevel"] then -- > check the layer
        for i, object in pairs(map.layers["CompleteLevel"].objects) do
            -- Sensor Parameteres --
            sensor = world:newRectangleCollider(object.x, object.y, object.width, object.height)

            sensor:setType("static")
            sensor:setCollisionClass("Finish")
		end
	end
end

-- Layer Generation Helper Function --
local function addLayer(color, x, y, width, height)
    -- Setting deafults --
    x = x or 0
    y = y or 0
    width = width or scrWidth
    height = height or scrHeight

    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width, height)
end

-- --- --


-- - Loading - --
function love.load()
    -- Create and Update Savefile --
    Save:new()
    Save:load()

    -- Sharpen the sprites --
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Map Specification --
    map = sti("assets/maps/" .. currentLevel .. ".lua")

    -- Initilazing World --
    world = wf.newWorld(0, gravity)

    world:addCollisionClass("Player")
    world:addCollisionClass("Ground")
    world:addCollisionClass("Finish", {ignores = {"Ground"}})

    world:addCollisionClass("RedPlatform")
    world:addCollisionClass("BluePlatform")
    world:addCollisionClass("YellowPlatform")

    generateColliders()
    levelFinish()

    -- Player Creation --
    player = Player:new(world, anim8, map, Save, Timer)
    playerSpawnX, playerSpawnY = player:getSpawn(map)

    -- Title Animation --
    Menu:loadTitle(anim8)

    -- Canvas Creation --
    canvas = love.graphics.newCanvas(scrWidth, scrHeight)

    -- Camera Creation --
    cam = Camera()
end

-- - Single Imputs - --
function love.keypressed(key)
    -- Player Jump --
    if not PauseMenu:isPaused() then player:keypressed(key) end

    -- Exit Fullscreen --
    if key == "f11" then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
        love.window.setPosition(scrWidth / 4, scrHeight / 4)
        return
    end

    -- Toogle Debug --
    if key == "f3" and not debug then
        debug = true
    elseif key == "f3" and debug then
        debug = false
    end

    -- Toggle Pause --
    if key == "escape" and Menu:isStarted() then
        PauseMenu:toggle()
    end

    -- Reset --
    if key == "r" and PauseMenu:isPaused() then
        PauseMenu:toggle()
        player.collider:setPosition(player:getSpawn(map))
        player.collider:setLinearVelocity(0, 0)
        player.color = "red"
        player.direction = "right"
        Timer:reset()
    end
end

-- - Upadating - --
function love.update(dt)
    if not PauseMenu:isPaused() then
        player:update(dt, map)
        world:update(dt)
        player:updateAnimation(dt)
        Timer:update(dt)

        -- Detection --
        if player:isComplete() and finish then
            Menu:finish()
            Timer:stop()
            sounds.complete:play()
            finish = false
        end

        if player.y <= playerSpawnY + 700 then
            cam:lookAt(player.x, player.y)
        end
    end

    Menu:update(dt, shader, Timer)
    customMouse:update()
end

-- - Rendering - --
function love.draw()
    love.graphics.setCanvas(canvas) -- > drawing to canvas

    -- Adding Background --
    addLayer({ 0, 0, 0 })

    love.graphics.setColor(1, 1, 1, 1) -- > resetting color

    cam:attach()

    -- Rendering Map --
    map:drawLayer(map.layers["Ground"])

    if player.color == "red" then
        map:drawLayer(map.layers["Red"])
    end

    if player.color == "blue" then
        map:drawLayer(map.layers["Blue"])
    end

    if player.color == "yellow" then
        map:drawLayer(map.layers["Yellow"])
    end

    -- Render Player --
    player:draw()

    -- Render hitboxes if debug --
    if debug then world:draw() end

    cam:detach()

    -- Render Timer --
    Timer:draw(scrWidth, scrHeight)


    -- Complete Text --
    if player:isComplete() then love.graphics.print("you won", scrWidth/2, 400) end


    -- Render Pause Menu --
    PauseMenu:draw(scrWidth, scrHeight)

    -- Render Starting Menu and Shader--
    love.graphics.setShader(shader.ping)
    Menu:draw(scrWidth, scrHeight)
    love.graphics.setShader()

    love.graphics.setCanvas()

    -- Rendering Canvas and Applieing Shaders --
    love.graphics.setColor(1, 1, 1, 1) -- > resetting the color

    love.graphics.setShader(shader.crt)
    love.graphics.draw(canvas)
    love.graphics.setShader()

    -- Rendering Custom Mouse --
    customMouse:draw()

end
