-- TODO: Fix conflation between data and behaviour in hairthings

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local list = {}

things = {}

function things.add(params, x, y)
    assert(params ~= nil, "Passed thing definition does not exist")
    local thing = deepcopy(params)
    thing.x = x
    thing.y = y
    table.insert(list, thing)
end

function things.remove(index)
    assert(list[index] ~= nil, "thinglist does not contain an entry at index"..index)
    table.remove(list, index)
end

function things.get(index)
    assert(type(index) == "number", "Index must be a number, "..type(index).." given")
    assert(list[index] ~= nil, "thinglist does not contain an entry at index "..index)
    return list[index]
end

function things.getField(index, field)
    local t = things.get(index)
    assert(type(field) == "string", "Field must be string, "..type(field).." given")
    return t[field]
end

function things.setField(index, field, value)
    local t = things.get(index)
    t[field] = value
end

function things.getAll()
    return list
end

function things.count()
    return #list
end

-- TODO: changeStat may not belong in hairthings; could be changeField, which would work but requires rf
function things.changeStat(stat, amount)
    stat.val = stat.val + amount
    if stat.val > stat.max then
        stat.val = stat.max
    end
end

return things