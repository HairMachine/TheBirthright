-- empty tables are randomly generated in the stateContainer.

local game = {}

game.player = {
    type = "player",
    mapPosX = 3,
    mapPosY = 6,
    mapPosZ = 1,
    inventory = {},
    use = true,
    attributes = {
        body = math.random(1, 6),
        mind = math.random(1, 6),
        spirit = math.random(1, 6)
    },
    skills = {
        acrobatics = math.random(1, 6),
        fighting = math.random(1, 6),
        lore = math.random(1, 6)
    },
    hp = math.random(1, 10),
    maxHp = math.random(1, 10)
}

game.skills = {
    "acrobatics", "lore", "fighting", "skulduggery"
}

game.coreLayout = {
    { 2,  1,  9,  1,  8},
    { 1,  0,  2,  1,  1},
    { 1,  2,  3,  0,  0},
    { 1,  1,  2,  0,  1},
    { 2,  0,  6,  1,  4},
    { 0,  0,  5,  0,  0},
    {10, 10, 10, 10, 10},
    {10,  0, 10,  0, 10},
    {10, 10, 10, 10, 10},
    {10,  0, 10,  0, 10},
    {11, 10, 10, 10, 10},
}

game.map = {}

game.objects = {}

game.locks = {
    shoggoth = {
        name = "Shoggoth",
        type = "shambler",
        attacks = {
            {
                type = "damage",
                chance = 10,
                challenge = nil,
                min = 5,
                max = 20
            }
        }
    },
    ghast = {
        name = "Ghast",
        type = "hunter",
        attacks = {
            {
                type = "damage",
                chance = 10,
                challenge = nil,
                min = 3,
                max = 6
            }
        }
    }
}

game.verbs = {
    "examine", "enter", "pickup", "drop", "pull", "use", "read"
}

game.essences = {
    "pthan", "draka", "rhul", "cyna", "gel", "rikt", "tkil", "svorn"
}

game.effects = {
    {type = "blasting", complexity = 4},
    {type = "freezing", complexity = 3},
    {type = "poisoning", complexity = 2},
    {type = "confusing", complexity = 1},
    {type = "healing", complexity = 2}
}

game.recipes = {}

game.knownRecipes = {}

game.prefabBooks = {
    uncle_diary = {
        
    }
}

game.lore = {
    {name = "Test Lore", description = "Blah blah blah", challenge = nil}
}

return game