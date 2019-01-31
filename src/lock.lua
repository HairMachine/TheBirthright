local Lock = {}

function Lock._damage(attack, target)
	local damage = math.random(attack.min, attack.max)
	target.hp = target.hp - damage
	love.gameEvent("damageDone", {damage = damage})
end

function Lock.doAttack(attack)
	-- player can avoid by passing a challenge
	if (attack.challenge) then
		if (gamestate.challenge(attack.challenge.difficulty, attack.challenge.core, attack.challenge.skills)) then
			return
		end
	end
	local player = gamestate.getPlayer()
	Lock["_"..attack.type](attack, player)
end

function Lock.chooseAttack(obj)
	if (not obj.lock.attacks) then
		return
	end
	local maxchance = 0
	local tchance = {}
	for k, attack in ipairs(obj.lock.attacks) do
		tchance[k] = {
			attack = attack,
			minChance = maxchance
		}
		maxchance = maxchance + attack.chance
		tchance[k].maxChance = maxchance
	end
	local roll = math.random(1, maxchance)
	for k, chance in ipairs(tchance) do
		if (k >= chance.minChance and k < chance.maxChance) then
			return Lock.doAttack(chance.attack)
		end
	end
end

function Lock.behaviourHunter(obj)

end

function Lock.behaviourShambler(obj)
	if (math.random(1, 6) >= 5) then
		local canMove = {}
		local exits = gamestate.getRoom(obj.mapPosX, obj.mapPosY, obj.mapPosZ).exits
		for k, v in pairs(exits) do
			if (v ~= 0) then table.insert(canMove, k) end
		end	
		local move = canMove[math.random(1, #canMove)]
		if (move == "n") then
			obj.mapPosY = obj.mapPosY - 1
		elseif (move == "e") then
			obj.mapPosX = obj.mapPosX + 1
		elseif (move == "s") then
			obj.mapPosY = obj.mapPosY + 1
		elseif (move == "w") then
			obj.mapPosX = obj.mapPosX - 1
		end
		love.gameEvent("roomChange", {})
	end
end

function Lock.behaviourCheck(obj)
	local player = gamestate.getPlayer()
	if (player.mapPosX == obj.mapPosX and player.mapPosY == obj.mapPosY) then
		Lock.chooseAttack(obj)
		return
	end
	if (obj.lock.type == "hunter") then
		Lock.behaviourHunter(obj)
	elseif (obj.lock.type == "shambler") then
		Lock.behaviourShambler(obj)
	end
end

return Lock