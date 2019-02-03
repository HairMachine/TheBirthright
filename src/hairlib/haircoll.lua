coll = {}

coll.map = {}
coll.xsize = 0
coll.ysize = 0

function coll:init()
    for x = 1, self.xsize + 1, 1 do
        self.map[x] = {}
        for y = 1, self.ysize + 1, 1 do
            self.map[x][y] = {}
        end
    end
end

function coll:set(list)
    assert(list ~= nil, "Collision map was passed a non-existent list")
    self:init()
    for k, v in ipairs(list) do
        table.insert(self.map[v.x + 1][v.y + 1], k)
    end
end

function coll.get(x, y)
    assert(coll.map[x + 1] ~= nil, "Nil value for "..x..", "..y)
    return coll.map[x + 1][y + 1]
end

return coll