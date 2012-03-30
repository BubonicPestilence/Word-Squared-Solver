# encoding: utf-8

class WordSquared
  include HTTParty
  
  headers(
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/535.15+ (KHTML, like Gecko) Version/5.1.2 Safari/534.52.7",
    "Referer" => "http://wordsquared.com/",
    "Origin" => "http://wordsquared.com",
    "X-Requested-With" => "XMLHttpRequest",
  )
  
  base_uri "http://wordsquared.com"
  default_timeout 30
  
  def method_missing(meth, *args, &block)
    begin
      self.class.send(meth, *args, &block)
    rescue Timeout::Error, EOFError
      retry
    end
  end
  
  def self.to_dom html
    Nokogiri::HTML(html)
  end
  
  def self.get_dom *args
    data = get(*args)
    to_dom(data)
  end
  
  attr_accessor :game_id, :letters
  
  def initialize(game_id = "undefined")
    super()
    
    @game_id = game_id
    @csrf_param = @csrf_token = @auth_token = @short_link = ""
  end
  
  def update_headers
    headers({ "X-CSRF-Token" => @csrf_token })
  end
  
  def update_cookies resp
    headers({ "Cookie" => resp.headers["Set-Cookie"] })
  end
  
  def auth(login, password)
    doc = get_dom("", :headers => {
      "X-Requested-With" => ""
    })
    
    @csrf_param = doc.at("meta[name='csrf-param']")["content"]
    @csrf_token = doc.at("meta[name='csrf-token']")["content"]
    
    update_headers
    
    params = {
      @csrf_param => @csrf_token,
      "utf8" => "✓",
      "user[username]" => login,
      "user[password]" => password,
      "user[remember_me]" => 1,
    }
    
    resp = post("/users/sign_in", :body => params)
    update_cookies resp
    raise "Can not authenticate #{resp["error"]}" if resp["error"]
    
    @game_id = resp["gameId"]
    @auth_token = resp["user"]["authtoken"]
    
    resp
  end
  
  def handle_data resp
    @letters = resp["assigned_letters"]
    @short_link = resp["shortlink"]
  end
  
  def load_game
    params = {
      game: game_id
    }
    
    resp = post("/v2/load_game", :body => params)
    
    handle_data(resp) if resp["result"] == "success"
    
    resp
  end
  
  def tiles(l, t, r, b)
    get("/v2/tiles_for?game=#{game_id}&left=#{l}&top=#{t}&right=#{r}&bottom=#{b}", :headers => {
      "X-Requested-With" => ""
    })["tiles"]
  end
  
  def drag(y, x)
    params = {
      shortlink: @short_link,
      "added[]" => "#{x},#{y}"
    }
    
    resp = post("/v2/drag", :body => params)
  end
  
  def play(tile, word, direction)
    params = {
      game: game_id
    }
    
    if_word_was_completed = []
    
    drags = word.size - 1
    1.upto(drags) do |inc|
      letter_id = inc - 1
      letter = word[inc]
      
      new_y, new_x = case direction
      when :top
        letter = word[word.size - inc - 1]
        [tile.y + inc, tile.x]
      when :left
        letter = word[word.size - inc - 1]
        [tile.y, tile.x - inc]
      when :right
        [tile.y, tile.x + inc]
      when :bottom
        [tile.y - inc, tile.x]
      end
      
      drag(new_y, new_x)
      
      params["tiles[#{letter_id}][letter]"] = letter
      params["tiles[#{letter_id}][wildcard]"] = false
      params["tiles[#{letter_id}][y]"] = new_y
      params["tiles[#{letter_id}][x]"] = new_x
      
      if_word_was_completed << {
        "x" => new_x,
        "y" => new_y,
        "letter" => letter
      }
    end
    
    resp = post("/v2/play", :body => params)
    
    if resp["result"] == "success"
      handle_data(resp)
      resp["if_word_was_completed"] = if_word_was_completed
      
      return resp
    end
    
    false
  end
  
  def swap_tiles
    params = {
      :query => { game: game_id },
      :body => ""
    }
    
    resp = post("/v2/swap_rack", params)
    
    if resp["result"] == "success"
      handle_data(resp)
    end
    
    resp
  end
end
