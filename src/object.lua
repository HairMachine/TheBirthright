local Object = {}

function Object.changeRoom(ob, x, y, z)
    ob.mapPosX = ob.mapPosX + x
    ob.mapPosY = ob.mapPosY + y
    ob.mapPosZ = ob.mapPosZ + z
end

-- TODO: Making sure these return values are not just strings, but can have different params so the UI can react better
function Object.examine(ob, sub)
    return "description"
end

function Object.enter(ob, sub)
    if (ob.key == nil) then
        if (ob.type == "old_grating") then
            gamestate.dungeonNew(2)
        elseif (ob.type == "portal_dangmar") then
            gamestate.dungeonNew(3)
        elseif (ob.type == "dungeon_exit") then
            gamestate.dungeonExit()
        end
        love.gameEvent("roomChange", {})
        return "open"
    end
    return "blocked"
end

-- TODO: Objects do not transfer from containers properly
function Object.pickup(ob, sub)
    table.insert(sub.inventory, ob)
    ob.index = #sub.inventory
    ob.held = true
    ob.drop = true
    ob.pickup = nil
    love.gameEvent("roomChange", {})
    return "pickup"
end

function Object.drop(ob, sub)
    table.remove(sub.inventory, ob.index)
    ob.held = false
    ob.drop = nil
    ob.pickup = true
    ob.mapPosX = sub.mapPosX
    ob.mapPosY = sub.mapPosY
    ob.mapPosZ = sub.mapPosZ
    love.gameEvent("roomChange", {})
    return "dropped"
end

function Object.transfer(to, ob)
    table.insert(to.inventory, ob)
    if (ob.drop) then
        table.remove(gamestate.getPlayer().inventory, ob.index)
        ob.index = #to.inventory
        ob.drop = nil
        ob.pickup = true
    else
        ob.held = true
    end
end

-- TODO: Return the results of the usage combination (requires a small refactor).
-- TODO: Maximum capacity (for magic sigil particularly)
function Object.use(ob, sub)
    if (sub.container and (ob.pickup or ob.drop)) then
        Object.transfer(sub, ob)
    end
    if (ob.container and (sub.pickup or sub.drop)) then
        Object.transfer(ob, sub)
    end
    -- unlockable
    if (ob.key and sub.type == ob.key) then
        ob.key = nil
        ob.enter = true
        table.remove(gamestate.getPlayer().inventory, sub.index)
        love.gameEvent("roomChange")
        return "unlocked"
    end
    if (sub.key and ob.type == sub.key) then
        sub.key = nil
        sub.enter = true
        table.remove(gamestate.getPlayer().inventory, ob.index)
        love.gameEvent("roomChange")
        return "unlocked"
    end
end

function Object.pull(ob, sub)
    -- TODO: Similar situation to above.
    if (sub.type == "workbench") then
        print("Check a recipe")
    end
    if (ob.type == "workbench") then
        print("Check a recipe")
    end
    return "pulled"
end

function Object.read(ob, sub)
    love.gameEvent("readBook", ob)
end

function Object.drink(ob, sub)
    print("Yum!")
end

function Object.fire(ob, sub)
    print("Bang!")
end

function Object.wear(ob, sub)
    print("Cool...")
end

function Object.hasVerb(ob, verb)
    return ob[verb] ~= nil
end

function Object.doVerb(ob, verb, sub)
    if (Object.hasVerb(ob, verb) == false) then
        return
    end
    return Object[verb](ob, sub)
end

return Object