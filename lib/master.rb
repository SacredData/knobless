# master.rb
require "pathname"
require "json"

class MasterKnob
    def initialize(audio,stats)
        @audio_file = File.open("#{audio}","r")
        @stats = JSON.parse(stats)
        @audio_path = Pathname.new(@audio_file.path)
        puts "Ready to master audio!"
    end
    def analyze
        @steps = {}
        if @stats["peak"] > -3.0
            if @stats["rms"] > -16.0
                @steps["gain"]  = -6
                @steps["limit"] = true
            else
                @steps["norm"]  = -5
                @steps["limit"] = false
            end
        else
            @steps["limit"] = true
            peak_delta = @stats["peak"].abs - 3
            @steps["gain"] = "#{peak_delta}".to_f
        end
        puts "SoX arguments: #{@steps}"
    end
    def construct1
        sinc1 = "sinc 50-14k" # high-pass at 50Hz, low-pass at 14kHz
        sox_cmd1 = "sox #{@audio_path.realpath} #{@audio_path.realpath}.lev.wav #{sinc1} "
        if @steps["gain"].nil? == false
            sox_cmd1 += "gain "
            sox_cmd1 += "-l "  if @steps["limit"] == true
            sox_cmd1 += "#{@steps["gain"]}"
        elsif @steps["norm"].nil? == false
            sox_cmd1 += "norm #{@steps["norm"]}"
        end
        puts sox_cmd1
        `#{sox_cmd1}`
        puts "SoX CMD 1 - Complete"
    end
    def construct2
        sox_cmd2 = "sox #{@audio_path.realpath}.lev.wav #{@audio_path.realpath}.fix.wav gain -h "
        drc = @stats["rms"] || "-20"
        sox_cmd2 += "compand 0.02,0.2 6:-40,-30,#{drc} -10 -6 0.2 norm 0"
        puts sox_cmd2
        `#{sox_cmd2}`
        puts "SoX CMD 2 - Complete"
        crest_check = `sox #{@audio_path.realpath}.fix.wav -n stats 2>&1`
        crest_now   = crest_check.split("\n")[-8].match(/\d+.\d+/)[0].to_f
        if crest_now > 7.5
            crest_fix = crest_now - 6.5
            puts "Crest is low, running a final gain boost."
            `sox #{@audio_path.realpath}.fix.wav #{@audio_path.realpath}.final.wav gain -l #{crest_fix}`
            puts "SoX CMD 3 - Complete"
        end
        return "#{@audio_path.realpath}.final.wav"
    end
end