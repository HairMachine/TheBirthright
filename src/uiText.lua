-- TODO: Split up the screens? Alternatively might actually rework it all to be in the same UI... need to decide

local hairgfx = require "hairlib/hairgfx"

local uiText = {}

uiText.lineHeight = 16
uiText.charWidth = 10

uiText.tileSize = 32

uiText.roomMaxX = 14
uiText.roomMaxY = 14

uiText.playerX = 7
uiText.playerY = 7

uiText.currentVerb = "examine"
uiText.usingItem = nil

uiText.container = nil
uiText.lastMessage = ""

uiText.currentBook = nil
uiText.currentChapter = ""

uiText.buttons = {}

uiText.screen = "explore"

uiText.objectMap = {}

uiText.screens = {
    explore = {
        setup = function(self)
            local player = gamestate.getPlayer()
            -- What is this terrible code? Surely there's a better way.
            if not uiText.objectMap[player.mapPosZ] then 
                uiText.objectMap[player.mapPosZ] = {} 
            end
            if not uiText.objectMap[player.mapPosZ][player.mapPosY] then 
                uiText.objectMap[player.mapPosZ][player.mapPosY] = {} 
            end
            if not uiText.objectMap[player.mapPosZ][player.mapPosY][player.mapPosX] then
                uiText.objectMap[player.mapPosZ][player.mapPosY][player.mapPosX] = {}
                for k, obj in ipairs(gamestate.findObjects(player.mapPosX, player.mapPosY, player.mapPosZ)) do
                    print("HABADUDI")
                    table.insert(
                        uiText.objectMap[player.mapPosZ][player.mapPosY][player.mapPosX],
                        {x = math.random(4, 8), y = math.random(4, 8), obj = obj}
                    )
                end
            end
        end,
        display = function(self)
            local player = gamestate.getPlayer()
		    local room = gamestate.getRoom(player.mapPosX, player.mapPosY, player.mapPosZ)            
            for y = 1, #uiText.roomTiles[room.type] do
                for x = 1, uiText.roomTiles[room.type][y]:len() do
                    local glyph = uiText.roomTiles[room.type][y]:sub(x, x)
                    local tileNo = uiText.tileMap[glyph]
                    love.graphics.draw(
                        uiText.tileset.img, 
                        uiText.tileset.tiles[tileNo], 
                        (x - 1) * uiText.tileSize, 
                        (y - 1) * uiText.tileSize
                    )
                end
            end
            for k, x in pairs(room.exits) do
                if k == "n" and x == 1 then
                    for x = 5, 9 do
                        for y = 0, 9 do
                            love.graphics.draw(
                                uiText.tileset.img, 
                                uiText.tileset.tiles[uiText.tileMap["0"]], 
                                x * uiText.tileSize, 
                                y * uiText.tileSize
                            )
                        end
                    end
                elseif k == "e" and x == 1 then
                    for x = 6, 14 do
                        for y = 5, 9 do
                            love.graphics.draw(
                                uiText.tileset.img, 
                                uiText.tileset.tiles[uiText.tileMap["0"]], 
                                x * uiText.tileSize, 
                                y * uiText.tileSize
                            )
                        end
                    end
                elseif k == "s" and x == 1 then
                    for x = 5, 9 do
                        for y = 6, 14 do
                            love.graphics.draw(
                                uiText.tileset.img, 
                                uiText.tileset.tiles[uiText.tileMap["0"]], 
                                x * uiText.tileSize, 
                                y * uiText.tileSize
                            )
                        end
                    end
                elseif k == "w" and x == 1 then
                    for x = 0, 9 do
                        for y = 5, 9 do
                            love.graphics.draw(
                                uiText.tileset.img, 
                                uiText.tileset.tiles[uiText.tileMap["0"]], 
                                x * uiText.tileSize, 
                                y * uiText.tileSize
                            )
                        end
                    end
                end
            end
            -- player
            love.graphics.draw(
                uiText.tileset.img,
                uiText.tileset.tiles[320],
                uiText.playerX * uiText.tileSize,
                uiText.playerY * uiText.tileSize
            )
            -- objects
            local objList = uiText.objectMap[player.mapPosZ][player.mapPosY][player.mapPosX]
            if objList then
                for k, mapObj in ipairs(objList) do
                    if not mapObj.obj.held then
                        love.graphics.draw(
                            uiText.tileset.img,
                            uiText.tileset.tiles[257],
                            mapObj.x * uiText.tileSize,
                            mapObj.y * uiText.tileSize
                        )
                    end
                end
            end
            -- describe o' box
            love.graphics.print("Location: "..uiText.roomDescriptions[room.type].name, 500, 0)
            -- inventory
            for k, item in ipairs(gamestate.getPlayer().inventory) do
                love.graphics.print(uiText.objectDescriptions[item.type].name, 500, uiText.lineHeight * (k + 2))
            end
        end
    },
    -- TODO: Deprecate
	debugExplore = {
		setup = function(self)
			self.buttons = {}
		    local player = gamestate.getPlayer()
		    local room = gamestate.getRoom(player.mapPosX, player.mapPosY, player.mapPosZ)
		    local exitStartX = 0
		    for k, v in pairs(room.exits) do
		        if (v == 1) then
		            local xm = 0
		            local ym = 0
		            if k == "n" then ym = -1 end
		            if k == "e" then xm = 1 end
		            if k == "s" then ym = 1 end
		            if k == "w" then xm = -1 end
		            self:addBtn({
		                text = self.dirDescriptions[k],
		                x = exitStartX,
		                y = self.lineHeight * 3,
		                width = self.dirDescriptions[k]:len() * self.charWidth,
		                height = self.lineHeight,
		                action = function()
		                    self.lastMessage = "Player goes "..self.dirDescriptions[k]
		                    gamestate.movePlayer(xm, ym, 0)
		                end        
		            })
		            exitStartX = exitStartX + (self.dirDescriptions[k]:len() * self.charWidth)
		        end
		    end
		    -- these are probably static and should not change on room gen actually but here because of my laziness
		    local verbs = gamestate.getVerbs()
		    local x = 0
		    for k, v in pairs(verbs) do
		        local text = self.verbDescriptions[v]
		        if (text == nil) then text = v end
		        self:addBtn({
		            text = text,
		            x = x,
		            y = self.lineHeight * 5,
		            width = text:len() * self.charWidth,
		            height = self.lineHeight,
		            action = function()
		                self.currentVerb = v
		            end
		        })
		        x = x + text:len() * self.charWidth
		    end
		    -- objectos!
		    -- TODO: Roll the player into the normal object list
		    self:addBtn({
		        text = "You",
		        x = 0,
		        y = self.lineHeight * 7,
		        width = 3 * self.charWidth,
		        height = self.lineHeight,
		        action = function()
		            if (self.currentVerb == "use" and self.usingItem ~= nil) then
		                gamestate.doVerb(self.currentVerb, player, self.usingItem)
		                self.usingItem = nil
		            end
		        end
		    })
            if (room.dark and not player.light) then
                return
            end
		    -- TODO: Make this a lot smaller by breaking up into sub-functions
		    x = 3 * self.charWidth
		    -- reset the room container in case there isn't one any more
		    self.container = nil
		    for k, ob in ipairs(room.objects) do
		        if (ob.held ~= true) then
		        	local text = ""
		        	local known = gamestate.isKnown("objects", ob)
		        	print("Getting description for "..ob.type)
		        	if (not known) then
		            	text = self.objectDescriptions[ob.type].name
		            else
		            	text = self.objectDescriptions[ob.type].trueName
		            end
		            if (text == nil) then text = ob.type end
		            self:addBtn({
		                text = text,
		                x = x,
		                y = self.lineHeight * 7,
		                width = text:len() * self.charWidth,
		                height = self.lineHeight,
		                action = function()
		                    -- TODO: rather than this garbage, allow verbs to be "socketed" to take other objects.
		                    if (self.currentVerb == "use" and self.usingItem == nil) then
		                        self.usingItem = ob
		                    elseif (self.currentVerb == "use") then
		                        gamestate.doVerb(self.currentVerb, ob, self.usingItem)
		                        self.usingItem = nil
		                    else
		                        gamestate.doVerb(self.currentVerb, ob, gamestate.getPlayer())
		                    end
		                end
		            })
		            -- if this is a container it gets a UI slot all of its own
		            if (ob.container) then
		                self.container = ob
		            end
		            x = x + text:len() * self.charWidth
		        end
		    end
		    -- ditto really static objects but are going here. WATCHA GONNA DOOOO
		    x = 0
		    for k, ob in pairs(gamestate.getPlayer().inventory) do
		        local text = ""
		    	local known = gamestate.isKnown("objects", ob)
		    	if (not known) then
		        	text = self.objectDescriptions[ob.type].name
		        else
		        	text = self.objectDescriptions[ob.type].trueName
		        end
		        self:addBtn({
		            text = text,
		            x = x,
		            y = self.lineHeight * 9,
		            width = text:len() * self.charWidth,
		            height = self.lineHeight,
		            action = function()
		                -- TODO: a better way of representing this; like a "compound" verb or something, or word sockets
		                if (self.currentVerb == "use" and self.usingItem == nil) then
		                    self.usingItem = ob
		                elseif (self.currentVerb == "use") then
		                    gamestate.doVerb(self.currentVerb, ob, self.usingItem)
		                    self.usingItem = nil
		                else
		                    gamestate.doVerb(self.currentVerb, ob, gamestate.getPlayer())
		                end
		            end
		        })
		        x = x + text:len() * self.charWidth
		    end
		    if (self.container ~= nil) then
		        x = 0
		        for k, ob in pairs(self.container.inventory) do
		            local text = ""
		        	local known = gamestate.isKnown("objects", ob)
		        	if (not known) then
		            	text = self.objectDescriptions[ob.type].name
		            else
		            	text = self.objectDescriptions[ob.type].trueName
		            end
		            self:addBtn({
		                text = text,
		                x = x,
		                y = self.lineHeight * 11,
		                width = text:len() * self.charWidth,
		                height = self.lineHeight,
		                action = function()
		                    -- TODO: a better way of representing this; like a "compound" verb or something, or word sockets
		                    if (self.currentVerb == "use" and self.usingItem == nil) then
		                        self.usingItem = ob
		                    elseif (self.currentVerb == "use") then
		                        gamestate.doVerb(self.currentVerb, ob, self.usingItem)
		                        self.usingItem = nil
		                    else
		                        gamestate.doVerb(self.currentVerb, ob, gamestate.getPlayer())
		                    end
		                end
		            })
		            x = x + text:len() * self.charWidth
		        end
		    end
		    self:addBtn({
		        text = "Notebook",
		        x = 0,
		        y = self.lineHeight * 13,
		        width = 8 * self.charWidth,
		        height = self.lineHeight,
		        action = function()
		        	love.gameEvent("knowledge")
		        end
        	})
		end,
		display = function(self)
			local player = gamestate.getPlayer()
		    local room = gamestate.getRoom(player.mapPosX, player.mapPosY, player.mapPosZ)
            if (room.dark and not player.light) then
                love.graphics.print("It is pitch dark.")
                return
            end
		    love.graphics.print(self.roomDescriptions[room.type].name)
		    love.graphics.print(self.roomDescriptions[room.type].description, 1, self.lineHeight * 1)
		    love.graphics.print("Exits:", 1, self.lineHeight * 2)
		    love.graphics.print("Verbs:", 1, self.lineHeight * 4)
		    love.graphics.print("On the floor:", 1, self.lineHeight * 6)
		    love.graphics.print("You are carrying:", 1, self.lineHeight * 8)
		    if (self.container) then
		        love.graphics.print("In "..self.objectDescriptions[self.container.type].name..":", 1, self.lineHeight * 10)
		    end
		    love.graphics.print(self.lastMessage, 1, self.lineHeight * 12)
		end
	},
	reading = {
		setup = function(self)
		    self.buttons = {}
		    for k, v in ipairs(self.currentBook.chapters) do
		        local disabled = v.read
		        self:addBtn({
		            text = k..") "..v.name,
		            x = 0,
		            y = k * uiText.lineHeight,
		            width = v.name:len() * uiText.charWidth,
		            height = uiText.lineHeight,
		            disabled = disabled,
		            action = function()
		                self.currentChapter = gamestate.bookChapterEffect(v)
		            end
		        })
		    end
		    self:addBtn({
		        text = "Done",
		        x = 0,
		        y = 15 * self.lineHeight,
		        width = 4 * self.charWidth,
		        height = self.lineHeight,
		        action = function()
		            self.screen = "explore"
		            self.currentBook = {}
		            love.gameEvent("roomChange")
		        end
		    })
		end,
		display = function(self)
			love.graphics.print(self.currentChapter, 300, 0)
		end
	},
	knowledge = {
		setup = function(self)
			self.buttons = {}
			self:addBtn({
		        text = "Done",
		        x = 0,
		        y = 15 * self.lineHeight,
		        width = 4 * self.charWidth,
		        height = self.lineHeight,
		        action = function()
		            self.screen = "explore"
		            self.currentBook = {}
		            love.gameEvent("roomChange")
		        end
		    })
	    end,
	    display = function(self)
	    	local knowledge = gamestate.knowledgeGet()
	    	local x = 0
	    	local y = 0
	    	for k, cat in pairs(knowledge) do
	    		love.graphics.print(k..": ", x, y)
	    		y = y + self.lineHeight * 2
	    		for k2, item in pairs(cat) do
	    			love.graphics.print(k2, x, y)
	    			y = y + self.lineHeight
	    			for k3, slot in ipairs(item) do
	    				love.graphics.print(slot, x, y)
	    				x = x + slot:len() * self.charWidth
	    			end
	    			x = 0
	    			y = y + self.lineHeight
	    		end
	    	end
		end

	},
	gameover = {
		setup = function(self)
	    	self.buttons = {}
	    	self:addBtn({
				text = "Quit",
				x = 0,
				y = 2 * uiText.lineHeight,
				width = 4 * uiText.charWidth,
				height = uiText.lineHeight,
				action = function()
					love.event.quit()
				end	
			})
		end,
		display = function(self)
			love.graphics.print("Game Over!", 0, 0)
    		love.graphics.print(self.lastMessage, 0, self.lineHeight)
		end
	}
}

function uiText:init()
    -- Import graphics
    uiText.tileset = {}
    hairgfx.makeTileset(uiText.tileset, "assets/UltimaV.png", 32)
    
    uiText.tileMap = {}
    uiText.tileMap["0"] = 64
    uiText.tileMap["1"] = 79
    
    uiText.roomDescriptions = {
        {
            name = "Empty Room",
            description = "This room has been cleared of any distinguishing features or furniture."
        },
        {
            name = "Corridor",
            description = "A narrow, crooked passage; one among many."
        },
        {
            name = "Portal room",
            description = "This otherwise bare room is dominated by seven huge mirrors. A faraway sound of flutes seems to hover on the edge of your hearing."
        },
        {
            name = "Workshop",
            description = "A well-used space cluttered with bric a brac and old tools. A large and odd-looking workbench is the centrepiece."
        },
        {
            name = "Drive",
            description = "A wide gravel path leads up to the front door of the manor."
        },
        {
            name = "Entrance Hall",
            description = "A high-ceilinged hall, it would have been a grand sight once. Now it is fading and ragged."
        },
        {
            name = "Trove Room",
            description = "This room is stuffed with curiosities, on shelves and low tables."
        },
        {
            name = "Ritual Room",
            description = "The wide space of this floor is dominated by a curious seven-pointed star."
        },
        {
            name = "Arcane Library",
            description = "A cramped space, stuffed with bookshelves overflowing with strange tomes. You hear a faint whispering."
        },
        {
            name = "Town street",
            description = "A winding cobbled street, made cramped by the crooked terraces crowding in on each side."
        },
        {
            name = "Old grating",
            description = "Almost hidden by an overgrown tangle, an old iron grating is fixed, leading into impenetrable darkness."
        }
    }
    
    uiText.roomTiles = {
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        },
        {
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
        },
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        },
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        },
        {
            "111111111111111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111110000011111",
            "111111111111111",
        },
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        },
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        },
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        },
        {
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
            "111111111111111",
        },
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        },
        {
            "111111111111111",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "100000000000001",
            "111111111111111"
        }
    }

    uiText.dirDescriptions = {
        n = "North",
        s = "South",
        e = "East",
        w = "West",
        u = "Up",
        d = "Down"
    }

    uiText.verbDescriptions = {
        examine = "Examine",
        kick = "Kick",
        enter = "Enter",
        pickup = "Pick Up",
        drop = "Drop",
        use = "Use",
        pull = "Pull",
        read = "Read",
        drink = "Drink",
        wear = "Wear",
        remove = "Remove",
        turnOn = "Turn On"
    }

    uiText.objectDescriptions = {
        player = {
            name = "you",
            trueName = "you",
            description = "It's you!",
            blasting = "Something blasts you!",
            freezing = "Something freezes you!",
            healing = "You feel better!",
            poisoning = "You feel sick!",
            confusing = "You feel befuddled!"
        },
        portal_dangmar = {
            name = "a shimmering mirror",
            trueName = "a Portal to Dangmar",
            description = "The mirror frame is of some blackened wood, notched and ancient. Bright white mists fog the glass.",
            blocked = "The mirror appears to be solid glass.",
            open = "It seems to be glass at first, but on closer inspection you realise what's on the other side is much larger than appears possible."
        },
        workbench = {
            name = "an uncanny workbench",
            trueName = "an uncanny workbench",
            description = "This almost looks like a normal workbench, except that it hurts your eyes to look at it. Mounted on the side is a large silver lever."
        },
        workbench_lever = {
            name = "a silver lever",
            trueName = "a silver lever",
            description = "A silver lever, rudimentary and slightly tarnished. It's connected to the workbench via some mechanism you can't see.",
            pulled = "You pull the lever."
        },
        magic_sigil = {
            name = "a magic sigil",
            trueName = "a magic sigil",
            description = "A large and complex seven pointed star; at each point is a kind of hollow or dimple."
        },
        bookshelf = {
            name = "some bookshelves",
            trueName = "bookshelves",
            description = "Crooked and bending under the weight of the myriad tomes crammed into them."
        },
        old_grating = {
            name = "old grating",
            trueName = "crypt entry",
            description = "On closer inspection, you see it is locked with an old fashioned iron padlock.",
            unlocked = "With an scraping creak, the grating opens, revealing the yawning black more beyond.",
            blocked = "The grate is locked.",
            open = "You step into the darkness. It closes in, greedily devouring you."
        },
        dungeon_exit = {
            name = "exit",
            trueName = "exit",
            description = "A way leading out of this place.",
            open = "You re-enter the light of day."
        },
        crypt_key = {
            name = "old iron key",
            trueName = "crypt key",
            description = "An huge iron iron key, clearly very old."
        },
        book = {
            name = "a book",
            trueName = "a book",
            description = "A tome of lore, filled with strange, half-mad writings.",
            read = "You read the book."
        },
        vessel_phial = {
            name = "a phial",
            trueName = "a phial",
            description = "A stoppered glass bottle, designed to hold a small amount of fluid.",
            pickup = "You pick up the vial.",
            dropped = "You drop the vial."
        },
        essence_pthan = {
            name = "a "..gamestate.getEssence("pthan").prop.." essence",
            trueName = "an essence of Pthan",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        essence_draka = {
            name = "a "..gamestate.getEssence("draka").prop.." essence",
            trueName = "an essence of Draka",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        essence_rhul = {
            name = "a "..gamestate.getEssence("rhul").prop.." essence",
            trueName = "an essence of Rhul",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        essence_cyna = {
            name ="a "..gamestate.getEssence("cyna").prop.." essence",
            trueName = "an essence of Cyna",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        essence_gel = {
            name = "a "..gamestate.getEssence("gel").prop.." essence",
            trueName = "an essence of Gel",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        essence_rikt = {
            name = "a "..gamestate.getEssence("rikt").prop.." essence",
            trueName = "an essence of Rikt",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        essence_tkil = {
            name ="a "..gamestate.getEssence("tkil").prop.." essence",
            trueName = "an essence of Tkil",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        essence_svorn = {
            name = "a "..gamestate.getEssence("svorn").prop.." essence",
            trueName = "an essence of Svorn",
            description = "A strange glowing substance, shimmering with weird power.",
            pickup = "You pick up the essence.",
            dropped = "You drop the essence."
        },
        item_phial = {
        	name = "a phial",
        	trueName = "a phial of "..gamestate.magicItemGetName(),
        	description = "A vial, filled with a mysterious glowing fluid.",
        	pickup = "You pick up the vial.",
        	dropped = "You drop the vial.",
            blasting = "Something blasts you!",
            freezing = "Something freezes you!",
            healing = "You feel better!",
            poisoning = "You feel sick!",
            confusing = "You feel befuddled!"
    	},
        item_wand = {
        	name = "a wand",
        	trueName = "a wand of "..gamestate.magicItemGetName(),
        	description = "A wand.",
        	pickup = "You pick up the wand.",
        	dropped = "You drop the wand."
    	},
        item_rod = {
        	name = "a rod",
        	trueName = "a rod of "..gamestate.magicItemGetName(),
        	description = "A rod.",
        	pickup = "You pick up the rod.",
        	dropped = "You drop the rod."
    	},
        item_staff = {
        	name = "a staff",
        	trueName = "a staff of "..gamestate.magicItemGetName(),
        	description = "A staff.",
        	pickup = "You pick up the staff.",
        	dropped = "You drop the staff."
    	},
        item_ring = {
        	name = "a ring",
        	trueName = "a ring of "..gamestate.magicItemGetName(),
        	description = "A mysterious ring.",
        	pickup = "You pick up the ring.",
        	dropped = "You drop the ring.",
            blasting = "You wear the ring.",
            freezing = "You put on the ring. Your limbs are stiffening!",
            healing = "You put on the ring.",
            poisoning = "You put on the ring. You feel very sick!",
            confusing = "You put on the ring. Your thoughts seem to tangle up into a knot!",
            remove = "You remove the ring."
    	},
        item_amulet = {
        	name = "an amulet",
        	trueName = "an amulet of "..gamestate.magicItemGetName(),
        	description = "A mysterious amulet.",
        	pickup = "You pick up the amulet.",
        	dropped = "You drop the amulet.",
            blasting = "You wear the amulet.",
            freezing = "You put on the amulet. Your limbs are stiffening!",
            healing = "You put on the amulet.",
            poisoning = "You put on the amulet. You feel very sick!",
            confusing = "You put on the amulet. Your thoughts seem to tangle up into a knot!",
            remove = "You remove the amulet."
    	},
    	item_shotgun = {
    		name = "a shotgun",
    		trueName = "a shotgun",
    		description = "Sturdy, wooden-stocked, doubled barrelled.",
    		pickup = "You pick up the shotgun.",
    		dropped = "You drop the shotgun."
    	},
        item_lantern = {
            name = "a lantern",
            trueName = "a lantern",
            description = "A brass oil lantern.",
            pickup = "You pick up the lantern.",
            dropped = "You drop the lantern."
        },
        shoggoth = {
            name = "a Shoggoth",
            trueName = "a Shoggoth",
            description = "An unbelievable nightmare; a vast, pulsating tangle of jelly from which sprout innumberable limbs, eyes and gaping maws."
        },
        ghast = {
        	name = "a Ghast",
        	trueName = "a Ghast",
        	description = "A gaunt, shambling figure in the darkness. You can't make out its features. You hear a faint hissing murmur as it crawls towards you."
    	},
        hunter = {
            name = "a Hunter",
            trueName = "a Hunter",
            description = "What pit of hell could have spawned this tangle of limbs and teeth?!"
        },
    	shaft = {
    		name = "a shaft",
    		trueName = "a shaft",
    		description = "A pitch black drop into who knows where."
    	}
    }
end

function uiText:addBtn(button)
    table.insert(self.buttons, button)
end

function uiText:findButton(x, y)
    for i = 1, #self.buttons do
        local btnX = self.buttons[i].x
        local btnY = self.buttons[i].y
        local btnMaxX = btnX + self.buttons[i].width
        local btnMaxY = btnY + self.buttons[i].height
        if (x >= btnX and y >= btnY and x <= btnMaxX and y <= btnMaxY) then
            return self.buttons[i]
        end
    end
end

function uiText:displayButtons()
    for i = 1, #self.buttons do
        local btn = self.buttons[i]
        if (not btn.disabled) then
            love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height)
        end
        love.graphics.print(btn.text, btn.x, btn.y)
    end
end

function uiText:event(event, result)
    if (event == "roomChange" and self.screen == "explore") then
        self.screens[self.screen].setup(self)
    elseif (event == "verbResult") then
        if (self.objectDescriptions[result.object.type] and self.objectDescriptions[result.object.type][result.result]) then
            self.lastMessage = self.objectDescriptions[result.object.type][result.result]
            print(self.lastMessage)
        else
            self.lastMessage = "Nothing happens."
        end
    elseif (event == "readBook") then
        self.screen = "reading"
        if (result) then
	        self.currentBook = result
	        self.currentChapter = ""
	    end
        self.screens[self.screen].setup(self)
    elseif (event == "enterShop") then
    	self.screen = "shopping"
    	self.currentShop = result
    	self.screens[self.screen].setup(self)
	elseif (event == "knowledge") then
		self.screen = "knowledge"
		self.screens[self.screen].setup(self)
	elseif (event == "damageDone") then
		self.lastMessage = "You are hit for "..result.damage.." damage!"
    elseif (event == "gameOver") then
    	self.screen = "gameover"
    	self.lastMessage = result.message
    	self.screens[self.screen].setup(self)
    end
end

function uiText:display()
    self.screens[self.screen].display(self)
    self:displayButtons()
end

function uiText:leftClick(x, y)
    local button = self:findButton(x, y)
    if (button and not button.disabled) then
        button.action()
    end
    local player = gamestate.getPlayer()
    local roomObjects = uiText.objectMap[player.mapPosZ][player.mapPosY][player.mapPosX]
    for k, ro in ipairs(roomObjects) do
        if x >= ro.x * self.tileSize and y >= ro.y * self.tileSize and x <= (ro.x + 1) * self.tileSize and y <= (ro.y + 1) * self.tileSize then
            gamestate.doVerb("pickup", ro.obj, player)
        end
    end
end

function uiText:keypressed(key)
    local player = gamestate.getPlayer()
    if key == "up" or key == "w" then
        self.playerY = self.playerY - 1
    elseif key == "right" or key == "d" then
        self.playerX = self.playerX + 1
    elseif key == "down" or key == "s" then
        self.playerY = self.playerY + 1
    elseif key == "left" or key == "a" then
        self.playerX = self.playerX - 1
    end
    
    if self.playerY < 0 then
        gamestate.movePlayer(0, -1, 0)
        self.playerY = self.roomMaxY
    elseif self.playerX > self.roomMaxX then
        gamestate.movePlayer(1, 0, 0)
        self.playerX = 0
    elseif self.playerY > self.roomMaxY then
        gamestate.movePlayer(0, 1, 0)
        self.playerY = 0
    elseif self.playerX < 0 then
        gamestate.movePlayer(-1, 0, 0)
        self.playerX = self.roomMaxX
    end
end

return uiText