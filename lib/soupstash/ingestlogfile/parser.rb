module SoupStash
  class IngestLogfile
    class Parser
      def initialize
        @parsed_count = 0

        perl_in, @log_out  = IO.pipe
        @json_in, perl_out = IO.pipe

        @pid = fork {
          parser_path = Dir.getwd + '/script/logfile-parser.pl'

          Dir::chdir './vendor/dcss_henzell'

          $stdin.reopen  perl_in
          $stdout.reopen perl_out 

          @json_in.close
          @log_out.close

          # Use whatever perl happens to be in the path rather than hard coding in she-bang.
          # TODO Pass in $server and any other relevant log fields data.
          exec 'perl', parser_path
        }

        perl_in.close
        perl_out.close
      end

      def import_from(logfile)
        $stdout.sync = true
        logfile.each do |line|
          next if line =~ /\bv=0.(?:[2-9]|10)/ # XXX Temp hack to skip older games.

          @log_out.puts line

          json = @json_in.gets
          game = JSON.parse(json) rescue nil

          # logfile-parser.pl failed and has complained on stderr
          if game.nil?
            $stdout.print "#{$0}: Failed to parse: #{line}\n"
            next
          end

          yield game

          # Useful when importing afresh.
          $stdout.print "At line #{@parsed_count}\r"
          @parsed_count += 1
        end
        $stdout.print "\n"
      end

      def finish_parsing
        begin
          @log_out.puts '__EXIT__'
        rescue Errno::EPIPE
        end

        Process.waitpid(@pid)

        puts "Imported #{@parsed_count} games!"
      end
    end
  end
end
