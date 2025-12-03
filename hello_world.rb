# hello_world.rb

require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby hello_world.rb [options]"

  opts.on("-n", "--name NAME", "Name to greet") do |name|
    options[:name] = name
  end
end.parse!

puts "Hello, #{options[:name]}!"
