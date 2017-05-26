require 'aws-sdk'
require 'dotenv/load'
require 'tty'

require 'swa/globals'
require 'swa/cloud_client'
require 'swa/application'

module Swa
  class << self
    def run
      Swa::Application.init
    end

    def aws_wrapper(&block)
      begin
        block.call
      rescue StandardError => e
        puts "ERROR: #{e.message}"
      end
    end
  end
end
