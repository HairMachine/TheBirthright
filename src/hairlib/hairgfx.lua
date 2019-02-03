hairgfx = {}

function hairgfx.makeTileset(store, file, tilesize)
    store.img = love.graphics.newImage(file)
    store.tiles = {}
    store.count = 0
    local width, height = store.img:getDimensions()
    for y = 0, height - tilesize, tilesize do
        for x = 0, width - tilesize, tilesize do
            local quad = love.graphics.newQuad(x, y, tilesize, tilesize, width, height)
            store.tiles[store.count] = quad
            store.count = store.count + 1
        end
    end
end

return hairgfx