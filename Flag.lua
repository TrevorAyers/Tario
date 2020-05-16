Flag = Class{}

function Flag:init(map)
    self.map = map
    self.x = (map.mapWidth - 5) * map.tileWidth
    self.y = (map.mapHeight / 2 - 6) * map.tileHeight
    self.width = 16
    self.height = 16
    self.texture = love.graphics.newImage('graphics/spritesheet.png')
    self.state = 'waving'

    self.behaviors = {
        ['waving'] = function(dt)
            self.animation = self.animations['waving']
        end,
        ['lowering'] = function(dt)
            self.animation = self.animations['lowering']
        end
    }
    self.animations = {
        ['waving'] = Animation{
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 48, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(16, 48, self.width, self.height, self.texture:getDimensions())
            },
            interval = 0.3
        },
        ['lowering'] = Animation{
            texture = self.texture,
            frames = {
                love.graphics.newQuad(32, 48, self.width, self.height, self.texture:getDimensions())
            },
            interval = 1
        }   
    }
end

function Flag:update(dt)
    self:checkCollision()
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    if self.state == 'lowering'then
        if self.y < (self.map.mapHeight / 2 - 2.5) * self.map.tileHeight then
            self.y = self.y + 15 * dt
        end
    end
end


function Flag:render()
    --Mirroring offsets it relative to its origin (which in love is the top left)
    --Need to offset origin as a result

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
        math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),
        --scaling variables
        0, scaleX, 1,
        --offset origin
        -self.width / 4, 1)
end

function Flag:checkCollision()
    if (self.map.player.x + self.map.player.width) >= (self.map.mapWidth - 4) * self.map.tileWidth then
        self.state = 'lowering'
        self.map.player.state = 'victory'
    else
        self.state = 'waving'
    end
end