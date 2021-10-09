module Swa
  module Provider
    class CloudClient
      attr_accessor :opsworks

      def initialize(params = {})
        self.opsworks ||= Aws::OpsWorks::Client.new(
          region: params[:region],
          credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY"],
                                            ENV["AWS_SECRET_KEY"])
        )
      end
    end
  end
end
