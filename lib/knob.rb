# knob.rb
require "pathname"
require "json"

class Knob
  def initialize(wavfile)
    @file       = File.open("#{wavfile}","r")
    @file_path  = Pathname.new(@file.path)
    @file_score = 0
    @levelvals  = {:flat => 1.0, :crest => 6.0, :peak => -3.0, :rmsl => -34.0, :rmsh => -20.0}
    @encodevals = {:sampleEnc => [16,24], :sampleDep => [16,24], :sampleRate => [44100,48000,96000], :channels => [2], :length => 7199}
    @issues     = []
  end
  attr_reader :file, :file_path, :file_score
  def scan
    # Audio encoding compliance scanning
    @lossless = if    @file_path.extname    =~ /\.[mp3|ogg|opus|aac]+/
        false   elsif @file_path.extname    =~ /\.[flac|aif|aiff|wav|raw]+/
        true
    end
    counter      = 1
    soxi_checks  = ["-t","-r","-c","-D","-b"]
    encCmd       = []
    soxi_checks.each do |cmd|
      encCmd[counter] = `soxi #{cmd} "#{@file_path}"`
      puts "#{counter}: #{encCmd[counter]}"
      counter += 1
    end
    @enc = {:sample_encoding => "#{encCmd[5]}".to_i, :sample_depth => "#{encCmd[5]}".to_i, 
     :sample_rate => "#{encCmd[2]}".to_i, :channels => "#{encCmd[3]}".to_i, :lossless => @lossless}
    # Audio dynamics measurement scanning
    statsCmd = `sox "#{@file_path}" -n stats 2>&1`
    @seconds = "#{statsCmd.split("\n")[-3]}".match(/\d+.\d+/)[0].to_f   # length in seconds
    @flat    = "#{statsCmd.split("\n")[-7]}".match(/\d+.\d+/)[0].to_f   # number of samples that hit 0dBFS
    @crest   = "#{statsCmd.split("\n")[-8]}".match(/\d+.\d+/)[0].to_f   # peak-to-RMS ratio
    @rms     = "#{statsCmd.split("\n")[-11]}".match(/-\d+.\d+/)[0].to_f # look it up on wikipedia
    @peak    = "#{statsCmd.split("\n")[-12]}".match(/-\d+.\d+/)[0].to_f # loudest measured sample in the file
    @stats = {:flat => @flat, :crest => @crest, :peak => @peak, :rms => @rms,
      :seconds => @seconds}
    # Warnings
    return "bad_length" if "#{@seconds}".to_f > @encodevals[:length]
    score
  end
  attr_reader :sampleEnc, :sampleDep, :sampleRate, :channels, :lossless
  attr_reader :flat, :crest, :peak, :rms, :seconds, :issues
  def score # TODO: Add a check for top/tail padding; add 15 to score if both are adaquate. 5 if only one.
    if @lossless == true # If the file isn't lossless, there's literally no reason to master it.
    # Audio encoding compliance scoring
      @file_score += 40 if 
        @encodevals[:sampleRate].any? {|rate| rate == "#{@sampleRate}".to_i} == true &&
        @encodevals[:sampleEnc].any?  {|enc| enc == "#{@sampleEnc}".to_i}    == true &&
        @encodevals[:sampleDep].any?  {|dep| dep == "#{@sampleDep}".to_i}    == true &&
       	@encodevals[:channels].any?   {|chan| chan == "#{@channels}".to_i}   == true
    # Audio dynamics measurement scoring
      @file_score   += 10 if "#{@flat}".to_f  < @levelvals[:flat]
      @file_score   += 10 if "#{@peak}".to_f  < @levelvals[:peak]
      @file_score   += 5  if "#{@crest}".to_f > @levelvals[:crest]
      if @rms.between?(@levelvals[:rmsl],@levelvals[:rmsh])
        @file_score += 15
      elsif @rms < @levelvals[:rmsh]
        @file_score += 10
      elsif @rms < @levelvals[:rmsl]
        @file_score += 5
      else
        @issues.push("rms")
      end
    else 
      @file_score = 0
    end
    return {:file => "#{@file_path}", :score => @file_score,
            :enc  => @enc, :stats => @stats}.to_json
  end
end