require "aws-sdk"
require "dotenv/load"
require "tty"

require "swa/globals"
require "swa/cloud_client"
require "swa/cloud_stats"
require "swa/application"

module Swa
  class << self
    def run
      Swa::Application.new.run
    end
  end
end
