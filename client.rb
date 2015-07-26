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
  begin
    path = Pathname.new(params['myfile'][:tempfile])
    k    = Knob.new("#{path.dirname}/#{path.basename}")
    msg  = k.scan
  rescue Exception => e
    puts e
    retry while tries < 5
  ensure
    k = nil
  end
  msg
end

get "/hi" do
  "Hello world!"
end