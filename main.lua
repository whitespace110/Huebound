-- - Window - --
local scr_width, scr_height = 1280, 720
love.window.setMode(scr_width, scr_height)

-- - World - --
local wf = require("libraries/windfield")
local world
local gravity = 500

-- - Player - --
local Player = require("player")
local player

-- - Animations - --
local anim8 = require("libraries/anim8")

-- - Map - --
local sti = require("libraries/sti")
local map
local platforms = {}
local redPlatforms = {}
local bluePlatforms = {}
local yellowPlatforms = {}

-- - Camera - --
local Camera = require("libraries/camera")
local cam

-- - Debug - --
local debug = true


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

-- --- --


-- - Loading - --
function love.load()
    -- Sharpen the sprites --
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Map Specification --
    map = sti("assets/maps/first_map.lua")

    -- Initilazing World --
    world = wf.newWorld(0, gravity)

    world:addCollisionClass("Player")
    world:addCollisionClass("Ground")

    world:addCollisionClass("RedPlatform")
    world:addCollisionClass("BluePlatform")
    world:addCollisionClass("YellowPlatform")

    generateColliders()

    -- Player Creation --
    player = Player:new(world, anim8)

    -- Camera Creation --
    cam = Camera()
end

-- - Single Imputs - --
function love.keypressed(key)
    -- Player jump --
    player:keypressed(key)

    -- Toogle debug --
    if key == "f3" and not debug then
        debug = true
    elseif key == "f3" and debug then
        debug = false
    end
end

-- - Upadating - --
function love.update(dt)
    player:update(dt)
    world:update(dt)
    player:updateAnimation(dt)

    cam:lookAt(player.x, player.y)
end

-- - Rendering - --
function love.draw()

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
end
