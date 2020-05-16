Map = Class{}

require 'Util'
require 'Player'
require 'Flag'

TILE_BRICK = 1
TILE_EMPTY = 4

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

FLAG_1 = 13
FLAG_2 = 14

POLE_TOP = 8
POLE_MIDDLE = 12
POLE_BASE = 16

local SCROLL_SPEED = 62

function Map:init()
    --Where is the spritesheet located?
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.music = love.audio.newSource('sounds/music.wav','static')

    --How large are the tiles (in pixels)?
    self.tileWidth = 16
    self.tileHeight = 16
    --What are the dimensions of our map (in tiles)?
    self.mapWidth = 50
    self.mapHeight = 28
    self.tiles = {}

    self.gravity = 15
    self.player = Player(self)
    self.flag = Flag(self)

    self.camX = 0
    self.camY = -3

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight


    --Fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local x = 1
    while x < self.mapWidth + 1 do
        
        --5% chance to make cloud
        --make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        if x < self.mapWidth - 18 then
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

                --chance to create a block for Mario to hit

                if math.random(15) == 1 then
                    self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
                end

                --next vertical scan line
                x = x + 1
            else
                x = x + 2
            end
        elseif x == self.mapWidth - 16 then
            self:makePyramid(x, 0, 8)
            x = x + 8
        elseif x == self.mapWidth - 4 then
            self:makeFlag(x)
            x = x + 2
        else
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1
        end
    end
    
    self.music:setLooping(true)
    self.music:setVolume(0.1)
    self.music:play()
end

function Map:makePyramid(x, iteration, height)
    --Base case
    if iteration == height then
        return
    end
    --Building the actual pyramid
    for y = self.mapHeight / 2 - iteration, self.mapHeight do
        self:setTile(x + iteration, y, TILE_BRICK)
        y = y + 1
    end
    --Recursion
    iteration = iteration + 1
    self:makePyramid(x, iteration, height)
end

function Map:makeFlag(x)
    self:setTile(x, self.mapHeight / 2 - 5, POLE_TOP)
    self:setTile(x, self.mapHeight / 2 - 4, POLE_MIDDLE)
    self:setTile(x, self.mapHeight / 2 - 3, POLE_MIDDLE)
    self:setTile(x, self.mapHeight / 2 - 2, POLE_MIDDLE)
    self:setTile(x, self.mapHeight / 2- 1, POLE_BASE)
    for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
        self:setTile(x + 1, y, TILE_BRICK)
        y = y + 1
    end
end
    
function Map:collides(tile)
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:update(dt)
    self.camX = math.max(0, 
        math.min(self.player.x - VIRTUAL_WIDTH / 2,
            math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
    self.player:update(dt)
    self.flag:update(dt)
end

function Map:tileAt(x, y)
    --1 is added to each of these because our tile array is 1 indexed, while our pixel array is 0 indexed
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

--Funky formula here is to read in 2D data from a 1D map array
--Parenthetical bit is simply used as a line counter
function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:render()
    --Need to review Render section
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.tileSprites[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    self.player:render()
    self.flag:render()
end
