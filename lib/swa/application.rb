module Swa
  class Application
    attr_accessor :prompt, :opsworks, :pastel, :cloudwatch

    def initialize
      self.prompt = TTY::Prompt.new
      self.pastel = Pastel.new
    end

    def run
      loop do
        selected_command = self.prompt.select("What would you like to do?", COMMANDS.values)

        if quit?(selected_command)
          puts "Bye!"
          break
        end

        selected_region = self.prompt.select("Which region are you working with?", REGIONS)
        set_opsworks(selected_region)
        set_cloudwatch(selected_region)

        puts "Grabbing stacks..."
        stacks = self.opsworks.describe_stacks.stacks
        stack_user = self.prompt.select("Which stack?", stacks.map(&:name))
        stack_id = stacks.select{ |s| s.name == stack_user }.first.stack_id

        rescue_wrapper do
          case selected_command
          when COMMANDS[:deploy]
            puts "Grabbing apps..."
            apps = self.opsworks.describe_apps({stack_id: stack_id}).apps
            app_user = self.prompt.select("Which app?", apps.map(&:name))
            selected_app = apps.select{ |a| a.name == app_user }.first

            deploy_id = deploy_app(stack_id, selected_app.app_id)

            print_result("Deployed #{selected_app.name}! ID: " + self.pastel.on_bright_white.black("#{deploy_id.deployment_id}"))
          when COMMANDS[:start]
            puts "Grabbing offline instances..."
            selected_instance = grab_instance(stack_id, filter_status: "stopped")
            self.opsworks.start_instance({instance_id: selected_instance.instance_id})

            print_result("Started #{selected_instance.hostname}!")
          when COMMANDS[:stop]
            puts "Grabbing online instances..."
            selected_instance = grab_instance(stack_id, filter_status: "online")
            self.opsworks.stop_instance({instance_id: selected_instance.instance_id})

            print_result("Stopped #{selected_instance.hostname}!")
          when COMMANDS[:ip]
            puts "Grabbing instances..."
            selected_instance = grab_instance(stack_id)

            print_result("The IP of #{selected_instance.hostname} is: " + self.pastel.on_bright_white.black("#{selected_instance.public_ip || selected_instance.elastic_ip || selected_instance.private_ip}"))
          when COMMANDS[:stats]
            puts "Grabbing online instances..."
            selected_instance = grab_instance(stack_id, filter_status: "online")
            res = get_stats(selected_region, selected_instance.instance_id)
          end
        end
      end
    end

    private

    def quit?(chosen)
      chosen == COMMANDS[:quit]
    end

    def set_opsworks(region)
      self.opsworks = Swa::CloudClient.new({region: region}).opsworks
    end

    def set_cloudwatch(region)
      self.cloudwatch = Swa::CloudStats.new({region: region}).cloudwatch
    end

    def deploy_app(stack_id, app_id)
      self.opsworks.create_deployment({
        stack_id: stack_id,
        app_id:   app_id,
        command:  {
                    name: "deploy",
                    args: {
                      "migrate" => ["true"],
                    }
                  },
        comment:  "Deploying from swa CLI"
      })
    end

    def print_result(output)
      puts "\n > #{output} \n\n"
    end

    def instances_with_status(instances, filter_status)
      instances.select{ |i| i.status == filter_status }
    end

    def grab_instance(stack_id, filter_status: nil)
      instances = self.opsworks.describe_instances({stack_id: stack_id}).instances
      instances = instances_with_status(instances, filter_status) if filter_status
      selected_instance_id = self.prompt.select("Which instance?", instances.reduce({}) {|m, i| m.merge!({"#{i.hostname} -- #{i.status}" => i.instance_id}); m })

      instances.select{ |i| i.instance_id == selected_instance_id }.first
    end

    def get_stats(region, instance_id)
      period = (24 * 60)
      options = { namespace: "AWS/OpsWorks",
                  metric_name: "",
                  dimensions: [
                    {
                      name: "InstanceId",
                      value: instance_id,
                    },
                  ],
                  start_time: Time.now - period,
                  end_time: Time.now,
                  period: period,
                  statistics: ["Average"] }

      avg_free = self.cloudwatch.get_metric_statistics(options.merge({metric_name: "memory_free"})).datapoints.first.average
      avg_total = self.cloudwatch.get_metric_statistics(options.merge({metric_name: "memory_total"})).datapoints.first.average

      "#{(avg_free / 1024 /1024).round(2)} / #{(avg_total / 1024 / 1024).round(2)}"
    end

    def rescue_wrapper(&block)
      begin
        block.call
      rescue StandardError => e
        puts "ERROR: #{e.message}"
      end
    end
  end
end