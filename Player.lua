Player = Class{}

local MOVE_SPEED = 80

function Player:init(map)
    self.width = 16
    self.height = 20

    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, self.width, self.height)
end

function Player:update(dt)
    
    if love.keyboard.isDown('a') then
        --Left movement
        self.x = self.x - MOVE_SPEED * dt
    elseif love.keyboard.isDown('d') then
        --Right movement
        self.x = self.x + MOVE_SPEED * dt
    end
end

function Player:render()
    love.graphics.draw(self.texture, self.frames[1], self.x, self.y)
end
