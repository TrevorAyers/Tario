WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require 'class'
push = require 'push'

require 'Util'
require 'Map'

function love.load()
    math.randomseed(os.time())
    map = Map()

    --Stops blurring of pixels when zoomed in in push
    love.graphics.setDefaultFilter('nearest','nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = true,
        vsync = true
    })

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    map:update(dt)

    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.draw()
    push:apply('start')

    love.graphics.translate(math.floor(- map.camX + 0.5), math.floor(- map.camY + 0.5))

    --Red was previously 108/255, 140/255, 255/255, 255/255
    love.graphics.clear(90 / 255, 140/ 255, 220 / 255, 255 / 255)
    map:render()
    
    if map.player.state == 'victory' then
        displayVictory()
    end


    push:apply('end')
end

function displayVictory()
    love.graphics.setFont = love.graphics.newFont('fonts/font.ttf', 24)
    love.graphics.printf("    Congratulations! You win!", map.camX, 20, map.mapWidthPixels / 2, 'center')
end