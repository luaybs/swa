module Swa
  module Utils
    class << self
      def print_result(output)
        puts "\n > #{output} \n\n"
      end

      def rescue_wrapper
        begin
          yield
        rescue StandardError => e
          puts "ERROR: #{e.message}"
        end
      end
    end
  end
end
