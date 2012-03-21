#!/usr/local/rvm/ruby
# encoding: utf-8

require_relative "common"

ws = WordSquared.new
Solver = WordSolver

puts "Logging as #{$username}"
base = ws.auth($username, $password)
user = base["user"]

print "Loading game .. "
game = ws.load_game
puts game["user"]["registered"] ? "OK" : "FAIL"

map = Map.new(ws)

last_word = user["profile"]["recent_words"].first["coords"].first
y, x = last_word["y"], last_word["x"]
map.zone(y, x)

bounds_hash = Map.bounds_hash(y, x)
fails = 0

loop {
  played = false
  resp = false
  
  bounds_hash[:top].downto(bounds_hash[:bottom]).each do |y|
    bounds_hash[:left].upto(bounds_hash[:right]).each do |x|
      tile = map[y, x]
      next unless tile
      
      sizes = tile.suitable?
      
      if sizes && (best_size = sizes.values.max) > 1
        direction = sizes.key(best_size)
        
        pattern = case direction
        when :right, :bottom
          "$#{tile.letter}"
        when :top, :left
          "#{tile.letter}$"
        end
        
        solved = Solver.solve(ws.letters.join(""), pattern)
        
        if solved.size > 0
          solved.sort_by! { |e| e.size }
          solved.reverse!
          
          best_word = solved.find { |w| w.size <= best_size }
          next unless best_word
          
          puts "#{tile.x} #{tile.y} DIRECTION: #{direction.to_s} SIZE: #{best_size} WORD: #{best_word}"
          
          word = best_word
          resp = ws.play(tile, word, direction)
          
          if resp
            base = resp
            resp["if_word_was_completed"].each { |h| map[h["y"], h["x"]] = Tile.new(map, h["y"], h["x"], h["letter"], true) }
            played = played ? played + 1 : 1
          end
        end
      end
    end
  end
  
  if played
    puts "Words completed for this batch: #{played}"
  else
    puts "No completed words -.-"
    fails += 1
    
    if $fails_before_swap_tiles and fails >= $fails_before_swap_tiles
      print "Swapping tiles .. "
      ws.swap_tiles
      puts "OK"
      
      fails = 0
    end
    
    user = base["user"]
    last_word = user["profile"]["recent_words"].first["coords"].first
    y, x = last_word["y"], last_word["x"]
    
    map.zone(y, x)
    bounds_hash = Map.bounds_hash(y, x)
  end
}