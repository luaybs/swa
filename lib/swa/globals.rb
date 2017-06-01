module Swa
  COMMANDS = {deploy: "Deploy App",
              start:  "Start Instance",
              stop:   "Stop Instance",
              ip:     "Get IP of Instance",
              stats:  "Instance Stats",
              quit:   "Quit"}.freeze

  REGIONS = { "US East (Ohio)" => "us-east-2",
              "US East (N. Virginia)" => "us-east-1",
              "US West (N. California)" => "us-west-1",
              "US West (Oregon)" => "us-west-2",
              "Asia Pacific (Tokyo)" => "ap-northeast-1",
              "Asia Pacific (Seoul)" => "ap-northeast-2",
              "Asia Pacific (Mumbai)" => "ap-south-1",
              "Asia Pacific (Singapore)" => "ap-southeast-1",
              "Asia Pacific (Sydney)" => "ap-southeast-2",
              "EU (Frankfurt)" => "eu-central-1",
              "EU (Ireland)" => "eu-west-1",
              "EU (London)" => "eu-west-2",
              "South America (São Paulo)" => "sa-east-1" }.freeze
end