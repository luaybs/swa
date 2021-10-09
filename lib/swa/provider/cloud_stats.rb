module Swa
  module Provider
    class CloudStats
      attr_accessor :cloudwatch

      def initialize(params = {})
        self.cloudwatch ||= Aws::CloudWatch::Client.new(
          region: params[:region],
          credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY"],
                                            ENV["AWS_SECRET_KEY"])
        )
      end
    end
  end
end
