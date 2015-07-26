# knob.rb
require "rubygems"
require "bundler/setup"
require "pathname"
require "json"

class Knob
	attr_accessor :flat, :crest, :peak, :rmsl, :rmsh
	def initialize(wavfile)
		@file       = File.open("#{wavfile}","r")
		@file_path  = Pathname.new(@file.path)
		@file_score = 0
		@levelvals  = {:flat => 1.0, :crest => 6.0, :peak => -3.0, :rmsl => -34.0, :rmsh => -20.0}
		@encodevals = {:sampleEnc => [16,24], :sampleDep => [16,24],
			:sampleRate => [44100,48000,96000], :channels => [2]}
	end
	attr_reader :file, :file_path, :file_score
	def scan
		@lossless    =   if    @file_path.extname    =~ /\.[mp3|ogg|opus|aac]+/
      		false        elsif @file_path.extname    =~ /\.[flac|aif|aiff|wav|raw]+/
      		true
    	end
	    encCmd       = `soxi "#{@file_path}"`
		@sampleEnc   = "#{encCmd.split("\n")[-1]}".match(/\d+/)     #sample encoding
		@sampleDep   = "#{encCmd.split("\n")[-5]}".match(/\d+/)     #sample bit depth
	    @sampleRate  = "#{encCmd.split("\n")[-6]}".match(/\d+/)     #sampling frequency
	    @channels    = "#{encCmd.split("\n")[-7]}".match(/\d+/)     #channel count
	    @len         = `soxi -D "#{@file_path}"`

	    statsCmd = `sox "#{@file_path}" -n stats 2>&1`
	    @flat    = "#{statsCmd.split("\n")[-7]}".match(/\d+.\d+/)   #number of samples that hit 0dBFS
	    @crest   = "#{statsCmd.split("\n")[-8]}".match(/\d+.\d+/)   #peak-to-RMS ratio
	    @peak    = "#{statsCmd.split("\n")[-12]}".match(/-\d+.\d+/) #loudest measured sample in the file
	    @seconds = "#{statsCmd.split("\n")[-3]}".match(/\d+.\d+/)   #length in seconds
	    @rms     = "#{statsCmd.split("\n")[-11]}".match(/-\d+.\d+/) #not gonna bother explaining this one
    end
    attr_reader :sampleEnc, :sampleDep, :sampleRate, :channels, :len, :lossless
    attr_reader :flat, :crest, :peak, :rms, :seconds
    def score #TODO: Add a check for top/tail padding; add 15 to score if both are adaquate. 5 if only one.
    	#Audio encoding compliance scoring
    	@file_score += 50 if 
	    	@encodevals[:sampleRate].any? {|rate| rate == "#{@sampleRate}".to_i} == true &&
	    	@encodevals[:sampleEnc].any? {|enc| enc == "#{@sampleEnc}".to_i} 	 == true &&
	    	@encodevals[:sampleDep].any? {|dep| dep == "#{@sampleDep}".to_i} 	 == true &&
	    	@encodevals[:channels].any? {|chan| chan == "#{@channels}".to_i} 	 == true
	    @file_score += 5 if @lossless == true
	    #Audio dynamics measurement scoring
	    @file_score += 10 if "#{@flat}".to_f < @levelvals[:flat]
	    @file_score += 10 if "#{@rms}".to_f  < @levelvals[:rmsh] && "#{@rms}".to_f > @levelvals[:rmsl]
	    @file_score += 10 if "#{@peak}".to_f < @levelvals[:peak]
	    return {:file => "#{@file_path}", :score => @file_score}.to_json
    end
end