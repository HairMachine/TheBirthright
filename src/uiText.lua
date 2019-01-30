-- TODO: Split up the screens? Alternatively might actually rework it all to be in the same UI... need to decide

local uiText = {}

uiText.lineHeight = 16
uiText.charWidth = 10
uiText.currentVerb = "examine"
uiText.usingItem = nil

uiText.container = nil
uiText.lastMessage = ""

uiText.currentBook = nil
uiText.currentChapter = ""

uiText.buttons = {}

uiText.screen = "explore"

uiText.screens = {
	explore = {
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
		                gamestate.doVerb(self.currentVerb, gamestate.getPlayer(), self.usingItem)
		                self.usingItem = nil
		            end
		        end
		    })
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
		end,
		display = function(self)
			local player = gamestate.getPlayer()
		    local room = gamestate.getRoom(player.mapPosX, player.mapPosY, player.mapPosZ)
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
        fire = "Fire"
    }

    uiText.objectDescriptions = {
        player = {
            name = "you",
            trueName = "you",
            description = "It's you!"
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
        	name = "a phiial",
        	trueName = "a phial of "..gamestate.magicItemGetName(),
        	description = "A vial, filled with a mysterious glowing fluid.",
        	pickup = "You pick up the vial.",
        	dropped = "You drop the vial."
    	},
        item_wand = {
        	name = "a wand",
        	trueName = "a wand of "..gamestate.magicItemGetName(),
        	description = "A vial, filled with a mysterious glowing fluid.",
        	pickup = "You pick up the vial.",
        	dropped = "You drop the vial."
    	},
        item_rod = {
        	name = "a vial",
        	trueName = "a rod of "..gamestate.magicItemGetName(),
        	description = "A vial, filled with a mysterious glowing fluid.",
        	pickup = "You pick up the vial.",
        	dropped = "You drop the vial."
    	},
        item_staff = {
        	name = "a staff",
        	trueName = "a staff of "..gamestate.magicItemGetName(),
        	description = "A vial, filled with a mysterious glowing fluid.",
        	pickup = "You pick up the vial.",
        	dropped = "You drop the vial."
    	},
        item_ring = {
        	name = "a ring",
        	trueName = "a ring of "..gamestate.magicItemGetName(),
        	description = "A vial, filled with a mysterious glowing fluid.",
        	pickup = "You pick up the vial.",
        	dropped = "You drop the vial."
    	},
        item_amulet = {
        	name = "an amulet",
        	trueName = "an amulet of "..gamestate.magicItemGetName(),
        	description = "A vial, filled with a mysterious glowing fluid.",
        	pickup = "You pick up the vial.",
        	dropped = "You drop the vial."
    	},
    	item_shotgun = {
    		name = "a shotgun",
    		truName = "a shotgun",
    		description = "Sturdy, wooden-stocked, doubled barrelled.",
    		pickup = "You pick up the shotgun.",
    		dropped = "You drop the shotgun"
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
end

return uiText