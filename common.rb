# encoding: utf-8

$stdout.sync = true

require "pp"
require "net/http"
require "open-uri"
require "httparty"
require "nokogiri"
require "yaml"
require "singleton"
require "time"

require_relative "settings.rb"
require_relative "WordSquared"
require_relative "WordSolver"
require_relative "Map"

def dynamic_hash(default = nil)
  if default
    Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = default } }
  else
    Hash.new { |h, k| h[k] = Hash.new }
  end
end

trap("INT") { exit }