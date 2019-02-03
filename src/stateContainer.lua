local game = require "game"
local Object = require "object" 
local Lock = require "lock"

local stateContainer = {}

-- player / character

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
    love.gameEvent("playerTurnEnd", {})
end

-- generic objects

function stateContainer.newObj(obj)
    table.insert(game.objects, obj)
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

function stateContainer.moveObj(obj, x, y, z)
    obj.mapPosX = x
    obj.mapPosY = y
    obj.mapPosZ = z
    love.gameEvent("roomChange", {})
end

-- locks

function stateContainer.getLock(lockName)
    return game.locks[lockName]
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

-- books

function stateContainer.makeBookChapter()
    local type = math.random(1, 6)
    local chapter = {}
    if (type == 1) then
        local effect = game.effects[math.random(1, #game.effects)]
        local piece = math.random(1, #game.recipes[effect.type])
        local learning = "the "..effect.type.." spell requires a "..game.recipes[effect.type][piece].." essence"    
        chapter = {
            type = "recipe",
            name = "On strange magicks",
            reward = {
                description = "You learn that "..learning..".", 
                knowledge = {
                    type = "recipes",
                    name = effect.type,
                    slot = piece,
                    content = game.recipes[effect.type][piece]
                }
            },
            challenge = {core = "mind", difficulty = 2, skills = {}}
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
            reward = {
                description = "You gain knowledge of a portal realm!"
            }
        }
    elseif (type == 6) then
        local essence = game.essences[game.essenceNames[math.random(1, #game.essenceNames)]]
        chapter = {
            type = "essence",
            name = "On the Essences",
            reward = {
                description = "You discover that the "..essence.name.." essence is "..essence.prop.."!",
                knowledge = {
                    type = "objects",
                    name = "essence_"..essence.name,
                    slot = 1,
                    content = essence.prop
                }
            }
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
        elseif (chapter.reward.knowledge) then
            local kn = chapter.reward.knowledge
            stateContainer.knowledgeLearn(kn.type, kn.name, kn.slot, kn.content)
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

-- essences

function stateContainer.essenceGen()
    local r = math.random(#game.essenceProps)
    local name = game.essenceProps[r]
    table.remove(game.essenceProps, r)
    return name
end

function stateContainer.essencesGen()
    local prop = ""
    for k, v in ipairs(game.essenceNames) do
        prop = stateContainer.essenceGen()
        game.essences[v] = {name = v, prop = prop}
    end
end

function stateContainer.getEssence(name)
    return game.essences[name]
end

-- recipes

function stateContainer.recipeGen()
    -- generate one recipe for each effect.
    for k, v in pairs(game.effects) do
        local essences = {}
        for i = 1, v.complexity do
            table.insert(essences, game.essenceNames[math.random(1, #game.essenceNames)])
        end
        game.recipes[v.type] = essences
    end
end

-- items

function stateContainer.magicItemRandom(obj)
    -- TODO: Some kind of likelihood
    local vessel = game.vessels[math.random(#game.vessels)]
    local effect = game.effects[math.random(#game.effects)]
    obj.type = "item_"..vessel
    obj.vessel = vessel
    obj.effect = effect.type
    if (vessel == "phial") then obj.drink = true end
    if (vessel == "ring" or vessel == "amulet") then obj.wear = true end
    if (vessel == "wand" or vessel == "rod" or vessel == "staff") then obj.use = true end
    obj.pickup = true
    stateContainer.newObj(obj)
end

function stateContainer.commonItemRandom(obj)
    local template = game.commonItems[math.random(1, #game.commonItems)]
    for k, v in pairs(template) do
        obj[k] = v
    end
    obj.pickup = true
    stateContainer.newObj(obj)
end

function stateContainer.magicItemGetName()
    return "something"
end

-- maps

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
                -- TODO: sometimes generate some random item.
            elseif roomTypes[y][x] == 2 then
                -- TODO: sometimes generate some random item.
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
            elseif roomTypes[y][x] == 6 then
                -- TODO: Temporary; we're generating useful items in the entrance hall for debug purposes
                stateContainer.newObj({
                    type = "item_lantern",
                    mapPosX = x,
                    mapPosY = y,
                    mapPosZ = 1,
                    examine = true,
                    pickup = true,
                    turnOn = true,
                    fuel = 100
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
                -- TODO: Generate Uncle's Journal
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

function stateContainer.getRoom(x, y, z)
    local room = game.map[z][y][x]
    room.objects = stateContainer.findObjects(x, y, z) 
    return room
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
                exits = exits,
                dark = true
            }
            local tchance = 0
            for k,v in ipairs(game.dungeons[z]) do
                tchance = tchance + v.chance
            end
            local roll = math.random(1, tchance)
            local cchance = 0
            for k, v in ipairs(game.dungeons[z]) do
                cchance = cchance + v.chance
                if (cchance >= roll) then
                    if (v.type == "object") then
                        local newObj = v.object
                        newObj.mapPosX = x
                        newObj.mapPosY = y
                        newObj.mapPosZ = z
                        stateContainer.newObj(newObj)
                    elseif (v.type == "lock") then
                        stateContainer.newObj({
                            type = v.name,
                            mapPosX = x,
                            mapPosY = y,
                            mapPosZ = z,
                            examine = true,
                            lock = game.locks[v.name],
                            statusEffects = {}
                        })
                    elseif (v.type == "magic_item") then
                        stateContainer.magicItemRandom({
                            mapPosX = x,
                            mapPosY = y,
                            mapPosZ = z,         
                        })
                    elseif (v.type == "essence") then
                        stateContainer.newObj({
                            type = "essence_"..game.essenceNames[math.random(1, #game.essenceNames)],
                            mapPosX = x,
                            mapPosY = y,
                            mapPosZ = z,
                            examine = true,
                            pickup = true    
                        })
                    elseif (v.type == "common_item") then
                        stateContainer.commonItemRandom({
                            mapPosX = x,
                            mapPosY = y,
                            mapPosZ = z
                        })
                    elseif (v.type == "book") then
                        stateContainer.randomBook(x, y, z)
                    end
                    -- leave loop now
                    break
                end
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

-- knowledge

function stateContainer.knowledgeLearn(type, name, slot, content)
    if (not game.knowledge[type][name]) then
        game.knowledge[type][name] = {}
    end
    game.knowledge[type][name][slot] = content
end

function stateContainer.isKnown(type, obj)
    if (game.knowledge[type][obj.type]) then
        return true
    end
    return false
end

function stateContainer.knowledgeGet()
    return game.knowledge
end

-- doom

function stateContainer.increaseDoom(amnt)
    game.doom.counter = game.doom.counter + amnt
    if (game.doom.counter > 100 - game.doom.level) then
        game.doom.level = game.doom.level + 1
        game.doom.counter = 0
        love.gameEvent("doomIncreased")
    end
end

-- verbs

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
    print(result)
    love.gameEvent("verbResult", {verb = verb, object = object, result = result})
    love.gameEvent("roomChange", {})
    love.gameEvent("playerTurnEnd", {})
end

-- status effects

function stateContainer.statusTick(obj)
    for effect, duration in pairs(obj.statusEffects) do
        print(effect)
        if (Object[effect.."Status"]) then
            print("apply status effect "..effect)
            Object[effect.."Status"](obj)
        end
        if (duration > 0) then
            obj.statusEffects[effect] = obj.statusEffects[effect] - 1
        elseif (duration == 0) then
            Object.removeStatus(obj, effect)
        end
    end
end

-- system

function stateContainer:event(event, result)
    if (event == "playerTurnEnd") then
        for k, obj in pairs(game.objects) do
            if (obj.lock) then
                Lock.behaviourCheck(obj)
            end
            if (obj.lit) then
                obj.fuel = obj.fuel - 1
                if (obj.fuel <= 0) then
                    obj.lit = nil
                    game.player.light = false
                end
            end
            -- Process any status effects and reduce duration
            if (obj.statusEffects and #obj.statusEffects > 0) then
                stateContainer.statusTick(obj)
            end
        end
        stateContainer.statusTick(game.player)
        stateContainer.increaseDoom(1)
    elseif (event == "damageDone") then
        if (game.player.hp <= 0) then
            love.gameEvent("gameOver", {result = "playerDied", message = "You died."})
        end
    elseif (event == "doomIncreased") then
        stateContainer.newObj({
            type = "hunter",
            mapPosX = game.player.mapPosX,
            mapPosY = game.player.mapPosY,
            mapPosZ = game.player.mapPosZ,
            examine = true,
            lock = game.locks["hunter"]
        })
    end
end

return stateContainer