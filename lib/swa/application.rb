module Swa
  class Application
    def self.init
      loop do
        prompt = TTY::Prompt.new
        selected = prompt.select("What would you like to do?", COMMANDS.values)

        if selected == COMMANDS[:quit]
          puts "Bye!"
          break
        end

        selected_region = prompt.select("Which region are you working with?", REGIONS)
        opsworks = Swa::CloudClient.new({region: selected_region}).client

        puts "Grabbing stacks..."
        stacks = opsworks.describe_stacks.stacks
        stack_user = prompt.select("Which stack?", stacks.map(&:name))
        selected_stack = stacks.select{ |s| s.name == stack_user }.first

        Swa.aws_wrapper do
          case selected
          when COMMANDS[:deploy]
            puts "Grabbing apps..."
            apps = opsworks.describe_apps({stack_id: selected_stack.stack_id}).apps
            app_user = prompt.select("Which app?", apps.map(&:name))
            selected_app = apps.select{ |a| a.name == app_user }.first

            res = opsworks.create_deployment({
              stack_id: selected_stack.stack_id,
              app_id:   selected_app.app_id,
              command:  {
                          name: "deploy",
                          args: {
                            "migrate" => ["true"],
                          }
                        },
              comment:  "Deploying from swa CLI"
            })
            puts "Deployed #{selected_app.name}! ID: #{res.deployment_id}"
          when COMMANDS[:start]
            puts "Grabbing offline instances..."
            instances = opsworks.describe_instances({stack_id: selected_stack.stack_id}).instances.select{|i| i.status != "online"}
            instance_user = prompt.select("Which instance?", instances.map(&:hostname))
            selected_instance = instances.select{ |i| i.hostname == instance_user }.first

            res = opsworks.start_instance({instance_id: selected_instance.instance_id})
            puts "Done!"
          when COMMANDS[:stop]
            puts "Grabbing online instances..."
            instances = opsworks.describe_instances({stack_id: selected_stack.stack_id}).instances.select{|i| i.status == "online"}
            instance_user = prompt.select("Which instance?", instances.map(&:hostname))
            selected_instance = instances.select{ |i| i.hostname == instance_user }.first

            res = opsworks.stop_instance({instance_id: selected_instance.instance_id})
            puts "Done!"
          when COMMANDS[:ip]
            puts "Grabbing instances..."
            instances = opsworks.describe_instances({stack_id: selected_stack.stack_id}).instances
            instance_user = prompt.select("Which instance?", instances.reduce({}) {|m, i| m.merge!({"#{i.hostname} -- #{i.status}" => i.instance_id}); m })
            selected_instance = instances.select{ |i| i.instance_id == instance_user }.first

            pastel = Pastel.new
            puts "\n > The IP of #{selected_instance.hostname} is: " + pastel.on_bright_white.black("#{selected_instance.public_ip || selected_instance.elastic_ip || selected_instance.private_ip}")
            puts "\n"
          end
        end
      end
    end
  end
end