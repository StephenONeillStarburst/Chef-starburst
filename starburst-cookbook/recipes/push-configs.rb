# Cookbook Name:: starburst-cookbook
# Recipe:: push-configs

hostname = node['hostname']

Chef::Log.info("The hostname of the node is: #{hostname}")

# Determine the node type based on the hostname
if hostname.include?('worker')
  node_type = 'worker'
elsif hostname.include?('coordinator')
  node_type = 'coordinator'
else
  raise "Node with hostname #{node['hostname']}) needs contain either 'worker' or 'coordinator'. Without this, configs can not be sent correctly." unless ::Dir.exist?(etc_directory)
end

# Accessing variables from attributes/default.rb
etc_directory = node['starburst-cookbook']['etc_directory']
installation_root = node['starburst-cookbook']['installation_root']
software_name = node['starburst-cookbook']['software_name']

# Include set-java-home recipe
include_recipe 'starburst-cookbook::set-java-home'

# Check and fail if etc directory does not exist
raise "#{etc_directory} must exist to copy configs. Have you run the install playbook??" unless ::Dir.exist?(etc_directory)

# Generate a unique node ID
node_id = SecureRandom.uuid

config_files = ['config.properties', 'env.sh', 'jvm.config', 'node.properties', 'log.properties']
config_files.each do |file|
  template "#{etc_directory}/#{file}" do
    source "#{node_type}/#{file}.erb"
    owner ::File.stat(etc_directory).uid
    group ::File.stat(etc_directory).gid
    mode file == 'env.sh' ? '0700' : '0400'
    # Pass necessary variables as needed, e.g., for config.properties
    if file == 'config.properties'
      variables({
        coordinator_port: node['starburst-cookbook']['coordinator_port'],
        log_directory: node['starburst-cookbook']['log_directory'],
        coordinator_hostname: node['starburst-cookbook']['coordinator_hostname']
      })
    elsif file == 'node.properties'
      variables({
        node_environment: node['starburst-cookbook']['node_environment'],
        node_id: node_id, # Ensure node_id is defined somewhere in your recipe
        data_directory: node['starburst-cookbook']['data_directory'],
        etc_directory: node['starburst-cookbook']['etc_directory'],
        log_directory: node['starburst-cookbook']['log_directory']
      })
    end
  end
end


# Create a unique node ID for node.properties
node_id = SecureRandom.uuid

# Import memory auto-config task
include_recipe 'starburst-cookbook::mem-auto-config'

# Copy catalog files
remote_directory "#{etc_directory}/catalog" do
  source "catalog"
  files_owner ::File.stat(etc_directory).uid
  files_group ::File.stat(etc_directory).gid
  recursive true
  purge true
  action :create
end

# Copy extra etc configurations
remote_directory etc_directory do
  source "extra/etc"
  files_owner ::File.stat(etc_directory).uid
  files_group ::File.stat(etc_directory).gid
  action :create
end

# Copy extra libs
remote_directory "#{installation_root}/#{software_name}/lib" do
  source "extra/lib"
  files_owner ::File.stat(etc_directory).uid
  files_group ::File.stat(etc_directory).gid
  recursive true
  action :create
end

# Copy extra plugins
remote_directory "#{installation_root}/#{software_name}/plugin" do
  source "extra/plugin"
  files_owner ::File.stat(etc_directory).uid
  files_group ::File.stat(etc_directory).gid
  recursive true
  action :create
end


# Ensure permissions for etc, lib, and plugin directories
['etc', 'lib', 'plugin'].each do |subdir|
  directory "#{installation_root}/#{software_name}/#{subdir}" do
    owner ::File.stat(etc_directory).uid
    group ::File.stat(etc_directory).gid
    mode subdir == 'etc' ? '0700' : '0755'
    recursive true
    action :create
  end
end
