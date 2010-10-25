require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('leboncoin', '0.0.1') do |p|
  p.description    = "leboncoin toolkit."
  p.url            = "http://github.com/kdridi/leboncoin"
  p.author         = "Karim DRIDI"
  p.email          = "karim.dridi@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.runtime_dependencies     = ["htmlentities", "nokogiri"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

