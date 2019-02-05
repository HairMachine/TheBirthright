local ui = require "uiText"
gamestate = require "stateContainer"

function love.load()
    math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)
    gamestate.essencesGen()
    gamestate.recipeGen()
    gamestate.mapGen()
    ui:init()
    love.gameEvent("roomChange", {})
end

function love.draw()
    ui:display()
end 

function love.mousepressed(x, y, button, istouch, presses)
    ui:leftClick(x, y)
end

function love.keypressed(key, scancode, isrepeat)
    ui:keypressed(key)
end

function love.gameEvent(event, result)
	print("Triggered "..event)
    ui:event(event, result)
    gamestate:event(event, result)
end