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

-- - Map - --
local sti = require("libraries/sti")
local map
local platfroms = {}

-- - Camera - --
local Camera = require("libraries/camera")
local cam

-- - Debug - --
local debug = true


-- - Functions - --

-- Platform Collider Helper Function --
local function generateColliders()
    if map.layers["Colliders"] then -- check the type
        for i, object in pairs(map.layers["Colliders"].objects) do
            local platform = world:newRectangleCollider(object.x, object.y, object.width, object.height)

            platform:setType("static")
            platform:setCollisionClass("Ground")
            table.insert(platfroms, platform) -- keep track of the objects
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

    generateColliders()

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

    -- Rendering Map --
    map:drawLayer(map.layers["Ground"])

    -- Render hitboxes if debug --
    if debug then world:draw() end

    cam:detach()

end
