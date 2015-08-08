# client.rb
require "rubygems"
require "bundler/setup"
require "sinatra"
require "tempfile"
require "json"
require "./lib/knob"

get "/upload" do
  haml :upload
end

post "/upload" do
  tries = 0
  begin
    tries += 1
    path  = Pathname.new(params['myfile'][:tempfile])
    file  = File.open(path)
    unless file.none?
      k   = Knob.new("#{path.dirname}/#{path.basename}")
      msg = k.scan
    end
  rescue Exception => e
    puts e
    retry while tries < 5
  ensure
    k = nil
  end
  JSON.pretty_generate(JSON.parse(msg)) unless msg.nil?
end

get "/hi" do
  "Hello world!"
end