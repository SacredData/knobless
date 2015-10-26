# client.rb
require "rubygems"
require "bundler/setup"
require "sinatra"
require "tempfile"
require "json"
require "time"
require "./lib/knob"

set :bind, '0.0.0.0'

get "/upload" do
  haml :upload
end

post "/upload" do
  tries,counter = 0,0
  @tracks  = {}
  @list = []
  session_time = Time.now
  params[:myfiles].each { |file|
    counter += 1
    begin
      tries   += 1
      path     = Pathname.new(file[:tempfile])
      name     = file[:filename]
      upfile   = File.open(path)
      unless upfile.none?
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
      @issues      = jmsg["issues"]
      @issues_str  = ""
      issue_count = 0
      @issues.each do |issue|
        if issue =~ /length/
          issue_count += 1
          @issues_str += "#{issue_count}: This file's length is too short! "
        end
        if issue =~ /lossy/
          issue_count += 1
          @issues_str += "#{issue_count}: [LOSSY ERROR] This file is not lossless! Please upload a WAV, FLAC, or AIFF. "
        end
        if issue =~ /flat/
          issue_count += 1
          @issues_str += "#{issue_count}: [FLAT FACTOR ERROR] This file contains audible distortion! "
        end
        if issue =~ /crest/
          issue_count += 1
          @issues_str += "#{issue_count}: [CREST FACTOR ERROR] This file's crest is too high. Audio levels must be reduced to achieve greater dynamic range. "
        end
        if issue =~ /rms/
          issue_count += 1
          @issues_str += "#{issue_count}: [RMS ERROR] This file's RMS is too high. Please reduce levels to achieve an ideal dynamic range. "
        end
        if issue =~ /peaks/
          issue_count += 1
          @issues_str += "#{issue_count}: [PEAK ERROR] This file is peaking above -3.0 dBFS. "
          @issues_str += "(We will fix this for you. No action is required.) " if @issues.length < 2
        end
      end
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
      # @tracks.push([@gen, @enc, @stats, counter, @issues_str])
      @tracks["#{@source_name}"] = { :general => @gen, :encoding => @enc, :stats => @stats,
                                  :counter => counter, :issues   => @issues }
      @list.push({:file => "#{@source_name}", :passed => @pass})
    end
  }
  
  # @tracks.each do |track_info|
  #   puts track_info
  #   puts "..."
  # end

  # @validation_msg = {:session => session_time, :files => @tracks}.to_json
  @tracks_msg = @list.to_json
  puts JSON.pretty_generate(@list)
  # haml :results2
end

get "/hi" do
  "Hello world!"
end