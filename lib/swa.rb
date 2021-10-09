require "aws-sdk"
require "dotenv/load"
require "tty"

require "swa/globals"
require "swa/utils"
require "swa/provider/cloud_client"
require "swa/provider/cloud_stats"
require "swa/application"

module Swa
  class << self
    def run
      Swa::Application.new.run
    end
  end
end
