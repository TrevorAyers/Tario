Map = Class{}

require 'Util'

TILE_BRICK = 1
TILE_EMPTY = 4

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5


local SCROLL_SPEED = 62

function Map:init()
    --Where is the spritesheet located?
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
    --How large are the tiles (in pixels)?
    self.tileWidth = 16
    self.tileHeight = 16
    --What are the dimensions of our map (in tiles)?
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    self.camX = 0
    self.camY = 0


    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    --Fill map with empty tiles
    for y = 1, self.mapHeight / 2 do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local x = 1
    while x < self.mapWidth do

        --5% chance to make cloud
        --make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        if math.random(20) == 1 then
            --left side of pipe
            self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

            --creates a column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1

            --place bush component and then column of bricks
            self:setTile(x, bushLevel, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1
            
            self:setTile(x, bushLevel, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

        elseif math.random(10) ~= 1 then

            --creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            --chanse to create a block for Mario to hit

            if math.random(15) == 1 then
                self.setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end

            --next vertical scan line
            x = x + 1
        else
            x = x + 2
        end
    end

    --[[
    --Starts halfway down the map, populates with bricks
    for y = self.mapHeight / 2, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_BRICK)
        end
    end
    ]]
end

function Map:update(dt)
    if love.keyboard.isDown('w') then
        --Up movement
        self.camY = math.max(math.floor(self.camY + dt * -SCROLL_SPEED), 0)
    elseif love.keyboard.isDown('a') then
        --Left movement
        self.camX = math.max(math.floor(self.camX + dt * -SCROLL_SPEED), 0)
    elseif love.keyboard.isDown('s') then
        --Down movement
        self.camY = math.min(math.floor(self.camY + dt * SCROLL_SPEED), self.mapHeightPixels - VIRTUAL_HEIGHT)
    elseif love.keyboard.isDown('d') then
        --Right movement
        self.camX = math.min(math.floor(self.camX + dt * SCROLL_SPEED), self.mapWidthPixels - VIRTUAL_WIDTH)
    end
end


function Map:render()
    --Need to review Render section
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end
end

function Map:setTile(x, y, tile)
    --Funky formula here is to read in 2D data from a 1D map array
    --Parenthetical bit is simply used as a line counter
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end