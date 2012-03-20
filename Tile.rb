# encoding: utf-8

class Tile
  attr_accessor :map, :y, :x, :letter, :extendable, :color
  
  SCAN_RANGE = 10
  
  @@directions = {
    :top_left     => [+1, -1],
    :top          => [+1, +0],
    :top_right    => [+1, +1],
    :right        => [+0, +1],
    :bottom_right => [-1, +1],
    :bottom       => [-1, +0],
    :bottom_left  => [-1, -1],
    :left         => [+0, -1],
  }
  
  def initialize(map, y, x, letter, extendable = false)
    @map, @y, @x, @letter, @extendable = map, y, x, letter, extendable
    @color = @extendable ? :white : :red
  end
  
  def coords_by_dir(direction, times = 1)
    [@y + @@directions[direction][0] * times, @x + @@directions[direction][1] * times]
  end
  
  def dir(direction, times = 1)
    @map[*coords_by_dir(direction, times)]
  end
  
  def coords_by_path *dirs
    y, x = @y, @x
    
    dirs.each do |d|
      y += @@directions[d][0]
      x += @@directions[d][1]
    end
    
    [y, x]
  end
  
  def path *dirs
    @map[*coords_by_path(*dirs)]
  end
  
  def letter?
    ("A".."Z").include?(@letter)
  end
  
  def suitable?
    return false if !letter? || !@extendable
    
    ret = {}
    
    # direction: [opposite, side_1, side_2]
    # ignore if opposite used
    # ignore if any of sides used too
    
    {
      :bottom => [:top, :left, :right],
      :right => [:left, :top, :bottom],
      :top => [:bottom, :left, :right],
      :left => [:right, :top, :bottom]
    }.each do |d, o|
      ret[d] = 1
      
      next if dir(o[0])
      
      next_cell_coords = coords_by_path(d)
      
      while ret[d] <= SCAN_RANGE
        side_1 = ([d] * ret[d]) + [o[1]]
        side_2 = ([d] * ret[d]) + [o[2]]
        next_of_next = ([d] * (ret[d] + 1))
        
        break if @map[*next_cell_coords]
        break if @map[*coords_by_path(*side_1)]
        break if @map[*coords_by_path(*side_2)]
        break if @map[*coords_by_path(*next_of_next)]
        
        ret[d] += 1
        
        next_cell_coords = coords_by_path(*next_of_next)
      end
    end
    
    ret
  end
end