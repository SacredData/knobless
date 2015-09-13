# client.rb
require "rubygems"
require "bundler/setup"
require "sinatra"
require "tempfile"
require "json"
require "./lib/knob"

set :bind, '0.0.0.0'

get "/upload" do
  haml :upload
end

post "/upload" do
  tries,counter = 0,0
  @tracks = []
  params[:myfiles].each { |file|
    counter += 1
    begin
      tries   += 1
      path  = Pathname.new(file[:tempfile])
      name  = file[:filename]
      file  = File.open(path)
      unless file.none?
        k   = Knob.new("#{path.dirname}/#{path.basename}",name)
        msg = k.scan
        puts "File #{counter}: #{path} ---- SCANNED"
      end
    rescue Exception => e
      puts e
      retry while tries < 5
    ensure
      k = nil
    end
    unless msg.nil?
      jmsg = JSON.parse(msg)
      # GENERAL FILE INFORMATION
      @source_name = jmsg["file"]
      @pass        = jmsg["pass"]
      @score       = jmsg["score"]
      @gen         = {:name => @source_name, :pass => @pass, :score => @score}
      # ENCODING INFORMATION
      @encdata     = jmsg["enc"]
      @depth       = @encdata["sample_depth"]
      @rate        = @encdata["sample_rate"]
      @channels    = @encdata["channels"]
      @lossless    = @encdata["lossless"]
      @enc         = {:depth => @depth, :rate => @rate, :channels => @channels,
                      :lossless => @lossless }
      # AUDIO MEASUREMENTS
      @statsdata   = jmsg["stats"]
      @flat        = @statsdata["flat"]
      @crest       = @statsdata["crest"]
      @peak        = @statsdata["peak"]
      @rms         = @statsdata["rms"]
      @stats       = {:peak => @peak, :rms => @rms, :flat => @flat, :crest => @crest}
      @tracks.push([@gen,@enc,@stats,counter])
    end
  }
  @tracks.each do |track_info|
    puts track_info
    puts "..."
  end
  haml :results
end

get "/hi" do
  "Hello world!"
end