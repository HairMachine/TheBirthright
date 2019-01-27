local ui = require "uiText"
gamestate = require "stateContainer"

function love.load()
    math.randomseed(os.time())
    gamestate.mapGen()
    gamestate.recipeGen()
    love.gameEvent("roomChange", {})
end

function love.draw()
    ui:display()
end 

function love.mousepressed(x, y, button, istouch, presses)
    ui:leftClick(x, y)
end

function love.gameEvent(event, result)
	print("Triggered "..event)
    ui:event(event, result)
    gamestate:event(event, result)
end