local game = require "game"
local Object = require "object" 

local stateContainer = {}

function stateContainer.trainSkill(skill, amount)
    if (game.player.skills[skill]) then
        game.player.skills[skill] = game.player.skills[skill] + amount
    else
        game.player.skills[skill] = amount
    end
end

function stateContainer.challenge(difficulty, core, skills)
    local base = game.player.attributes[core]
    local bonus = 0
    for k, amnt in pairs(skills) do
        if (game.player.skills[k]) then
            bonus = bonus + game.player.skills[k] * amnt
        end
    end
    if (base + bonus >= difficulty) then
        return true
    end
    return false
end

function stateContainer.newObj(obj)
    table.insert(game.objects, obj)
end

function stateContainer.makeBookChapter()
    local type = math.random(1, 5)
    local chapter = {}
    if (type == 1) then
        chapter = {
            type = "recipe",
            name = "On strange magicks",
            -- generate random recipe piece
            reward = {description = "You gain knowledge of a magical imbuement!", effect = "", piece = 0},
            challenge = {core = "mind", difficulty = 10, skills = {}}
        }
    elseif (type == 2) then
        local lore = game.lore[math.random(1, #game.lore)]
        chapter = {
            type = "lore",
            name = lore.name,
            reward = {description = lore.description},
            challenge = lore.challenge
        }
    elseif (type == 3) then
        local skill = game.skills[math.random(1, #game.skills)]
        chapter = {
            type = "skill",
            name = "On subjects most interestinge",
            reward = {description = skill.." increases!", bonus = math.random(1, 6), skill = skill}
        }
    elseif (type == 4) then
        chapter = {
            type = "ritual",
            name = "On the deepest secrets of power",
            reward = {description = "You gain knowledge of a ritual!"}
        }
    elseif (type == 5) then
        chapter = {
            type = "portal",
            name = "On the Other Realms",
            reward = {description = "You gain knowledge of a portal realm!"}
        }
    end
    return chapter
end

function stateContainer.bookChapterEffect(chapter)
    local success = true
    if (chapter.challenge) then
        success = stateContainer.challenge(
            chapter.challenge.difficulty, chapter.challenge.core, chapter.challenge.skills
        )
    end
    if (success) then
        chapter.read = true
        if (chapter.reward.skill) then
            stateContainer.trainSkill(chapter.reward.skill, chapter.reward.bonus)
        end
        love.gameEvent("readBook")
        return chapter.reward.description
    end
    return "You cannot understand this chapter."
    
end

function stateContainer.randomBook(x, y, z)
    local obj = {}
    local numChapters = math.random(4, 10)
    obj.chapters = {}
    for i = 1, numChapters do
        obj.chapters[i] = stateContainer.makeBookChapter()
    end
    obj.mapPosX = x
    obj.mapPosY = y
    obj.mapPosZ = z
    obj.type = "book"
    obj.examine = true
    obj.pickup = true
    obj.read = true
    table.insert(game.objects, obj)
end

function stateContainer.prefabBook(name, x, y, z)
    local obj = game.prefabBooks[name]
    obj.mapPosX = x
    obj.mapPosY = y
    obj.mapPosZ = z
    table.insert(game.objects, obj)
end

function stateContainer.applyLock(obj, lockData)
    obj.lock = lockData
end

-- TODO: Design lock system in much more detail
function stateContainer.randomLock(obj)
    local type = math.random(1, 4)
    local lockData = {}
    if type == 1 then
        -- static
        lockData = {
            type = "static"
        }
    elseif type == 2 then
        -- timed
    elseif type == 3 then
        -- dynamic
    else
        -- monster
    end
end

function stateContainer.recipeGen()
    -- generate one recipe for each effect.
    for k, v in pairs(game.effects) do
        local essences = {}
        for i = 1, v.complexity do
            table.insert(essences, game.essences[math.random(1, #game.essences)])
        end
        game.recipes[k] = essences
    end
end

function stateContainer.mapGen()
    -- generate the types of rooms
    local level = 1
    local roomTypes = game.coreLayout
    -- make them real, add objects
    game.map[level] = {}
    for y = 1, #roomTypes do
        game.map[1][y] = {}
        for x = 1, #roomTypes[y] do
            local exits = {n = 0, e = 0, s = 0, w = 0, u = 0, d = 0}
            if (roomTypes[y-1] ~= nil and roomTypes[y-1][x] ~= 0) then
                exits.n = 1
            end
            if (roomTypes[y][x+1] ~= nil and roomTypes[y][x+1] ~= 0) then
                exits.e = 1
            end
            if (roomTypes[y+1] ~= nil and roomTypes[y+1][x] ~= 0) then
                exits.s = 1
            end
            if (roomTypes[y][x-1] ~= nil and roomTypes[y][x-1] ~= 0) then
                exits.w = 1
            end
            game.map[1][y][x] = {
                type = roomTypes[y][x],
                exits = {n = exits.n, e = exits.e, s = exits.s, w = exits.w, u = exits.u, d = exits.d},
            }
            -- we will populate the room with objects according to room type
            -- special rooms have unique type IDs and generate specific objects, other rooms are empty
            -- or gen random objects (e.g. Trove room)
            -- TODO: Consider moving data into game.lua and make a bit more of a systematic thing here
            if roomTypes[y][x] == 1 then
                stateContainer.newObj({
                    type = "vessel_phial",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    pickup = true,
                    use = true,
                    quality = ""
                })
            elseif roomTypes[y][x] == 2 then
                stateContainer.newObj({
                    type = "essence_"..game.essences[math.random(1, #game.essences)],
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    pickup = true,
                    use = true
                })
            elseif roomTypes[y][x] == 3 then
                stateContainer.newObj({
                    type = "portal_dangmar",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    enter = true,
                    use = true,
                    key = "INCANTATION"
                })
            elseif roomTypes[y][x] == 4 then
                stateContainer.newObj({
                    type = "workbench",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    use = true,
                    inventory = {},
                    container = true
                })
                stateContainer.newObj({
                    type = "workbench_lever",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    pull = true
                })
                stateContainer.newObj({
                    type = "crypt_key",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    use = true,
                    pickup = true
                })
            elseif roomTypes[y][x] == 8 then
                stateContainer.newObj({
                    type = "magic_sigil",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    use = true,
                    inventory = {},
                    container = true
                })
            elseif roomTypes[y][x] == 9 then
                stateContainer.newObj({
                    type = "bookshelf",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    use = true,
                    inventory = {},
                    container = true
                })
                stateContainer.randomBook(x, y, 1)
                stateContainer.randomBook(x, y, 1)
                stateContainer.randomBook(x, y, 1)
            elseif roomTypes[y][x] == 11 then
                stateContainer.newObj({
                    type = "old_grating",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    use = true,
                    key = "crypt_key"
                })
            end
        end
    end
end

function stateContainer.getPlayer()
    return game.player
end

function stateContainer.movePlayer(x, y, z)
    Object.changeRoom(game.player, x, y, z)
    -- if the player is not in the main map, they're in a dungeon and we should generate stuff!
    if (game.player.mapPosZ ~= 1) then
        stateContainer.dungeonRoomsGenerate()
    end
    love.gameEvent("roomChange", {})
end

function stateContainer.findObjects(x, y, z)
    local objects = {}
    for i = 1, #game.objects do
        local ob = game.objects[i]
        if (ob.mapPosX == x and ob.mapPosY == y and ob.mapPosZ == z) then
            table.insert(objects, ob)
        end
    end
    return objects
end

function stateContainer.getRoom(x, y, z)
    local room = game.map[z][y][x]
    return {
        type = room.type,
        exits = room.exits,
        objects = stateContainer.findObjects(x, y, z)
    }
end

function stateContainer.dungeonRoomsGenerate()
    local x = game.player.mapPosX
    local y = game.player.mapPosY
    local z = game.player.mapPosZ
    if (game.map[z][y][x].generated) then
        return
    end
    local numExits = math.random(2, 4)
    local dir = -1
    local roomsBuilt = 0
    local exits = {}
    -- tag this room as being fully generated
    game.map[z][y][x].generated = true
    while (roomsBuilt < numExits) do
        exits = {n = 0, e = 0, s = 0, w = 0}
        dir = math.random(1, 4)
        if (dir == 1) then
            game.map[z][y][x].exits.n = 1
            y = y - 1
            exits.s = 1
        elseif (dir == 2) then
            game.map[z][y][x].exits.e = 1
            x = x + 1
            exits.w = 1
        elseif (dir == 3) then
            game.map[z][y][x].exits.s = 1        
            y = y + 1
            exits.n = 1
        elseif (dir == 4) then
            game.map[z][y][x].exits.w = 1
            x = x - 1
            exits.e = 1
        end
        if (game.map[z][y] == nil) then game.map[z][y] = {} end
        if (game.map[z][y][x] == nil) then
            game.map[z][y][x] = {
                type = 1,
                exits = exits
            }
            if (math.random(1, 6) == 6) then
                stateContainer.newObj({
                    mapPosZ = z,
                    mapPosY = y,
                    mapPosX = x,
                    type = "dungeon_exit",
                    examine = true,
                    enter = true
                })
            end
            roomsBuilt = roomsBuilt + 1
        end
    end
end

function stateContainer.dungeonNew(z)
    game.map[z] = {}
    game.map[z][game.player.mapPosY] = {}
    game.map[z][game.player.mapPosY][game.player.mapPosX] = {
        type = 1,
        exits = {n = 0, e = 0, s = 0, w = 0}
    }
    game.player.mapPosZ = z
    game.player.enteredDungeonX = game.player.mapPosX
    game.player.enteredDungeonY = game.player.mapPosY
    stateContainer.dungeonRoomsGenerate()
end

function stateContainer.dungeonExit()
    -- return player to entry position
    game.player.mapPosX = game.player.enteredDungeonX
    game.player.mapPosY = game.player.enteredDungeonY
    game.player.mapPosZ = 1
end

function stateContainer.getVerbs()
    local immutable = {}
    for k, v in pairs(game.verbs) do
        immutable[k] = v
    end
    return immutable
end

function stateContainer.doVerb(verb, object, subject)
    local result = "failure"
    if (Object.hasVerb(object, verb)) then
        result = Object.doVerb(object, verb, subject)
    end
    love.gameEvent("verbResult", {verb = verb, object = object, result = result})
    love.gameEvent("roomChange", {})
end

-- TODO: Knowledge system needs much more design before it can be implemented
function stateContainer.acquireRecipePart(recipe, part)
    game.knownRecipes[recipe] = game.recipes[part]
end

return stateContainer