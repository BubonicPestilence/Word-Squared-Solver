require_relative "Tile"

class Map
  attr_accessor :tiles
  
  WIDTH = 100
  HEIGHT = 100
  
  def self.bounds(y, x, buffer = 0)
    left = x - WIDTH / 2 - buffer
    top = y + HEIGHT / 2 + buffer
    right = x + WIDTH / 2 + buffer
    bottom = y - HEIGHT / 2 - buffer
    
    [left, top, right, bottom]
  end
  
  def self.bounds_hash(y, x, buffer = 0)
    bounds = bounds(y, x, buffer)
    
    {
      left: bounds[0],
      top: bounds[1],
      right: bounds[2],
      bottom: bounds[3],
    }
  end
  
  def initialize ws
    @tiles = dynamic_hash
    @ws = ws
  end
  
  def [](y, x)
    @tiles[y][x]
  end
  
  def []=(y, x, t)
    @tiles[y][x] = t
  end
  
  def zone(y, x)
    buffer = Tile::SCAN_RANGE
    bounds = self.class.bounds(y, x, buffer)
    bounds_hash = self.class.bounds_hash(y, x, buffer)
    
    tiles = @ws.tiles(*bounds)
    tiles.each do |t|
      ty, tx = t["y"], t["x"]
      @tiles[ty][tx] = Tile.new(self, ty, tx, t["letter"], t["extendable"])
    end
    
    tiles.size
  end
end