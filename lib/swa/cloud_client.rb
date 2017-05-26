module Swa
  class CloudClient
    def initialize(params = {})
      Aws.config.update({
        region: params[:region],
        credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'],
                                          ENV['AWS_SECRET_KEY'])
      })
    end

    def client
      @ops ||= Aws::OpsWorks::Client.new()
    end
  end
end