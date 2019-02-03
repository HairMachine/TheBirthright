local Object = {}

-- TODO: Should probably be in a new "Effects" file
function Object.blasting(sub)
    local damage = math.random(10, 20)
    sub.hp = sub.hp - damage
    love.gameEvent("damageDone", {damage = damage})
    return "blasting"
end

function Object.blastingStatus(sub)
    if (math.random(1, 20) == 1) then
        Object.blasting(sub)
    end
end

function Object.freezing(sub)
    Object.applyStatus(sub, "freezing", math.random(1, 6))
    return "freezing"
end

function Object.poisoning(sub)
    Object.applyStatus(sub, "poisoning", math.random(8, 17))
    return "poisoning"
end

function Object.poisoningStatus(sub)
    sub.hp = sub.hp - 1
    love.gameEvent("damageDone", {damage = 1})
end

function Object.confusing(sub)
    Object.applyStatus(sub, "confusing", math.random(6, 16))
    return "confusing"
end

function Object.confusingStatus(sub)
    -- TODO: Object tries to move in a random direction (we need better movement handlers)
end

function Object.healing(sub)
    sub.hp = sub.hp + math.random(1, 8)
    if (sub.hp > sub.maxHp) then
        sub.hp = sub.maxHp
    end
    return "healing"
end

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
    -- has some magical effect
    -- TODO: Reduce number of charges.
    print(ob.effect)
    if (ob.effect) then
        return Object[ob.effect](sub)
    end
    print (sub.effect)
    if (sub.effect) then
        return Object[sub.effect](ob)
    end
end

function Object.turnOn(ob, sub)
    if (ob.fuel) then
        sub.light = true
        ob.lit = true
        love.gameEvent("roomChange")
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
    print("DRINK")
    -- TODO: Cleanup required, probably on turn end.
    table.remove(sub.inventory, ob.index)
    ob.removed = true
    love.gameEvent("roomChanged", {})
    if (ob.effect) then
        return Object[ob.effect](sub)
    end
end

function Object.wear(ob, sub)
    print("WEAR")
    if (ob.effect and ob.drop) then
        Object.applyStatus(sub, ob.effect, -1)
        ob.drop = nil
        ob.remove = true
        return ob.effect
    end
end

function Object.remove(ob, sub)
    if (ob.effect and ob.remove) then
        Object.removeStatus(sub, ob.effect)
        ob.drop = true
        ob.remove = nil
        return "remove"
    end
end

function Object.applyStatus(sub, effect, duration)
    if (not sub.statusEffects) then
        sub.statusEffects = {}
    end
    sub.statusEffects[effect] = duration
end

function Object.removeStatus(sub, effect)
    sub.statusEffects[effect] = nil
end

function Object.hasStatus(sub, effect)
    if (not sub.statusEffects) then
        return false
    end
    return sub.statusEffects[effect]
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