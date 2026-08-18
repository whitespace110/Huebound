-- - Window - --
local scr_width, scr_height = 1280, 720
love.window.setMode(scr_width, scr_height)

-- - World - --
local wf = require("libraries/windfield")
local world
local gravity = 500

local ground

-- - Player - --
local Player = require("player")
local player

-- - Camera - --
local Camera = require("libraries/camera")
local cam

-- - Debug - --
local debug = true

-- - Loading - --
function love.load()
    -- Initilazing World --
    world = wf.newWorld(0, gravity)

    world:addCollisionClass("Player")
    world:addCollisionClass("Ground")

    ground = world:newRectangleCollider(scr_width / 4, scr_height / 1.5, 600, 100)
    ground:setType("static")
    ground:setCollisionClass("Ground")

    -- Player Creation --
    player = Player:new(world)

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

    cam:lookAt(player.x, player.y)
end

-- - Rendering - --
function love.draw()
    cam:attach()
    if debug then world:draw() end
    cam:detach()

    -- Render hitboxes if debug --
end
