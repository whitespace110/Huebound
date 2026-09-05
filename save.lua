local Save = {}

-- - Serializer - --
require("libraries/TSerial")

local data = {
    level1 = {
        unlocked = true,
        best_time = nil,
        attempts = 0
    },

    level2 = {
        unlocked = false,
        best_time = nil,
        attempts = 0
    },

    level3 = {
        unlocked = false,
        best_time = nil,
        attempts = 0
    },

    level4 = {
        unlocked = false,
        best_time = nil,
        attempts = 0
    },

    level5 = {
        unlocked = false,
        best_time = nil,
        attempts = 0
    }
}

-- - Creating New Save File (if needed) - --
function Save:new()
    if love.filesystem.getInfo("savefile.lua") ~= nil then -- check if the file exists
        Save.savefile = love.filesystem.newFile("savefile.lua")
    else
        -- Create the File --
        Save.savefile = love.filesystem.newFile("savefile.lua", "w")
        Save.savefile:write(TSerial.pack(data))
        Save.savefile:close()
    end
end

-- - Loading Save - --
function Save:load()
    Save.savefile:open("r")
    data = TSerial.unpack(Save.savefile:read())
    Save.savefile:close()
end

-- - Resetting Save File - --
function Save:freshFile()
    local levels = { "level1", "level2", "level3", "level4", "level5" }

    for i, level in ipairs(levels) do
        data[level].unlocked = false
        data[level].best_time = nil
        data[level].attempts = 0
    end

    data.level1.unlocked = true -- > unlocking level 1

    Save.savefile:open("w")
    Save.savefile:write(TSerial.pack(data))
    Save.savefile:close()
end

-- - Updating Save - --
function Save:update(level, time, attempts)
    local levels = { "level1", "level2", "level3", "level4", "level5" }

    -- Finding the Next level --
    local nextLvl
    for i, lvl in ipairs(levels) do
        if lvl == level and level ~= "level5" then
            nextLvl = levels[i + 1]
        end
    end

    -- Finding Best Time --
    local bestTime
    if data[level].best_time ~= nil then
        if data[level].best_time >= time then
            bestTime = time
        end
    elseif data[level].best_time == nil then
        bestTime = time
    end

    -- Setting the values --
    if nextLvl ~= nil then data[nextLvl].unlocked = true end
    if bestTime ~= nil then data[level].best_time = bestTime end
    data[level].attempts = data[level].attempts + attempts

    -- Updating --
    Save.savefile:open("w")
    Save.savefile:write(TSerial.pack(data))
    Save.savefile:close()
end

return Save
