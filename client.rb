# client.rb
require "rubygems"
require "bundler/setup"
require "sinatra"

get "/upload" do
  haml :upload
end

post "/upload" do
  # ...
end

get "/hi" do
  "Hello world!"
end