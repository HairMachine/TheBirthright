local utility = require("hairlib/hairutility")

local tilemap = {}
function tilemap.get(map, glyph)
    for i,v in ipairs(map) do
        if v.glyph == glyph then
            return v
        end
    end
    error("Glyph "..string.byte(glyph).." does not have associated tile")
end

local hairboard = {}

hairboard.xsize = 1
hairboard.ysize = 1
hairboard.grid = {}

function hairboard:load(filename, tmap)
    local raw = utility.fileRead(filename)
    local xcount = 1
    local ycount = 1
    self.grid[self.ysize] = {}
    for i = 1, #raw do
        local c = raw:sub(i, i)
        if c == "\n" then
            ycount = ycount + 1
            xcount = 1
            self.grid[ycount] = {}
        -- TODO: Character exclusion list for things that will break the map loading
        elseif c ~= "\r" then
            local data = tilemap.get(tmap, c)
            self.grid[ycount][xcount] = data.tile
            if data.thing ~= nil then
                print("Adding "..data.thing.name)
                things.add(data.thing, xcount - 1, ycount - 1)
            end
            xcount = xcount + 1
        end
    end
    self.xsize = xcount - 1
    self.ysize = ycount
end

function hairboard:getTile(x, y)
    return self.grid[y + 1][x + 1]
end

return hairboard