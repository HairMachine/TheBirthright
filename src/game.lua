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
    hp = 25,
    maxHp = 25
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
        type = "shambler",
        attacks = {
            {
                type = "damage",
                chance = 10,
                challenge = nil,
                min = 3,
                max = 6
            }
        }
    },
    shaft = {
        name = "Shaft",
        type = "trap",
        attacks = {
            {
                type = "damage",
                chance = 1,
                challenge = {
                    core = "body",
                    difficulty = 7,
                    skills = {actrobatics = 1}
                },
                min = 2,
                max = 8
            }
        }
    }
}

game.verbs = {
    "examine", "enter", "pickup", "drop", "pull", "use", "read", "drink", "wear", "fire"
}

game.essenceNames = {
    "pthan", "draka", "rhul", "cyna", "gel", "rikt", "tkil", "svorn"
}

game.essenceProps = {
    "ruby", "jade", "amber", "slimy", "clouded", "gelatinous", "sparkling", "glowing"
}

game.essences = {}

game.vessels = {
    "phial", "wand", "rod", "staff", "ring", "amulet"
}

game.effects = {
    {type = "blasting", complexity = 4},
    {type = "freezing", complexity = 3},
    {type = "poisoning", complexity = 2},
    {type = "confusing", complexity = 1},
    {type = "healing", complexity = 2}
}

game.commonItems = {
    {
        type = "item_shotgun",
        fire = true
    }
}

game.recipes = {}

game.knowledge = {
    recipes = {},
    objects = {}
}

game.prefabBooks = {
    uncle_diary = {
        
    }
}

game.lore = {
    {name = "Ode to the Death Worms", description = "Deep beneath the surface of YRRA delve the death worms... deep, and dark, and deadly...", challenge = nil}
}

game.dungeons = {
    {},
    {
        {
            chance = 10,
            type = "nothing"
        },
        {
            chance = 1,
            type = "object",
            object = {
                type = "dungeon_exit",
                examine = true,
                enter = true
            }
        },
        {
            chance = 2,
            type = "lock",
            name = "ghast"
        },
        {
            chance = 3,
            type = "lock",
            name = "shaft"
        },
        {
            chance = 1,
            type = "magic_item"
        },
        {
            chance = 3,
            type = "essence"
        }
    }
}

return game