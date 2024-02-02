# Cookbook Name:: starburst-cookbook
# Recipe:: mem-auto-config

# Accessing memory auto-config settings from attributes/default.rb
use_auto_config = node['starburst-cookbook']['memory_auto_config']['use_auto_config']
etc_directory = node['starburst-cookbook']['etc_directory']
memory_config = node['starburst-cookbook']['memory_auto_config']
hostname = node['hostname']

# Define a helper method to fetch memory settings based on node type
def fetch_memory_settings(memory_config, node_type)
  case node_type
  when 'coordinator'
    memory_config['coordinator']
  when 'worker'
    memory_config['worker']
  else
    {} # Default or error case
  end
end

# Determine the node type based on the hostname
if hostname.include?('worker')
  node_type = 'worker'
elsif hostname.include?('coordinator')
  node_type = 'coordinator'
else
  raise "Node with hostname #{node['hostname']}) needs contain either 'worker' or 'coordinator'. Without this, configs can not be sent correctly." unless ::Dir.exist?(etc_directory)
end

# Apply memory settings if auto-config is enabled
if use_auto_config
  mem_settings = fetch_memory_settings(memory_config, node_type)

  # Apply JVM settings - example for jvm.config file modification
  jvm_config_path = "#{etc_directory}/jvm.config"
  if mem_settings.key?('heap_size_percentage') # Checking as an example
    ruby_block "update_jvm_config" do
      block do
        file = Chef::Util::FileEdit.new(jvm_config_path)
        file.search_file_replace_line(/^#?-Xmx/, "-Xmx#{mem_settings['heap_size_percentage']}")
        file.write_file
      end
      only_if { ::File.exist?(jvm_config_path) }
    end
  end

  # Apply Config settings - example for config.properties file modification
  config_properties_path = "#{etc_directory}/config.properties"
  if mem_settings.key?('total_memory') # Checking as an example
    ruby_block "update_config_properties" do
      block do
        file = Chef::Util::FileEdit.new(config_properties_path)
        file.search_file_replace_line(/^query.max-memory=/, "query.max-memory=#{mem_settings['total_memory']}")
        file.write_file
      end
      only_if { ::File.exist?(config_properties_path) }
    end
  end
end
