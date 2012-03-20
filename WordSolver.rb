# encoding: utf-8

class WordSolver
  include HTTParty
  
  headers(
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/535.15+ (KHTML, like Gecko) Version/5.1.2 Safari/534.52.7",
  )
  
  base_uri "http://wordsolver.net"
  default_timeout 15
  
  def method_missing meth, *args, &block
    self.class.send(meth, *args, &block)
  end
  
  def self.to_dom(html)
    Nokogiri::HTML(html)
  end
  
  def self.get_dom(*args)
    data = get(*args)
    to_dom(data)
  end
  
  def self.solve(chars, pattern = "")
    query = {
      "tpl" => "search",
      "anagram" => chars,
      "mode" => "anagram",
      "dictionary" => "twl",
      "patternmatching" => pattern,
      "maxresults" => "500",
      "minlength" => "2",
      "sorting" => "wordlength",
      "sw" => "1680",
      "sh" => "1050"
    }
    
    d = get_dom("/", :query => query)
    
    ret = []
    d.search("p.resultwords a").each do |a|
      ret << a["href"].scan(/([^=]+)$/).flatten.first
    end
    
    ret
  end
end