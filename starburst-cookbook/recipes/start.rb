# Cookbook Name:: starburst-cookbook
# Recipe:: start-services

# Accessing variables from attributes/default.rb
sep_systemd_service_name = node['starburst-cookbook']['sep_systemd_service_name']
etc_directory = node['starburst-cookbook']['etc_directory']
installation_root = node['starburst-cookbook']['installation_root']
software_name = node['starburst-cookbook']['software_name']
log_directory = node['starburst-cookbook']['log_directory']
install_owner = node['starburst-cookbook']['installation_owner']
become_root = node['starburst-cookbook']['become_root']

# Ensure the etc directory exists
directory "#{installation_root}/#{software_name}/etc" do
  owner install_owner
  group 'root'
  mode '0755'
  action :create
  recursive true
end

# Start SEP systemd service if it exists
service sep_systemd_service_name do
  action :start
  only_if { ::File.exist?("/etc/systemd/system/#{sep_systemd_service_name}.service") }
  only_if { become_root }
end

# Determine user
install_owner = node['chef_user_id'] if !become_root || install_owner.nil? || install_owner.empty?

# Start via launcher if SEP systemd service does not exist
execute 'start_software' do
  command "source #{etc_directory}/env.sh && #{installation_root}/#{software_name}/bin/launcher start --etc-dir #{etc_directory} --launcher-log-file #{log_directory}/launcher.log --server-log-file #{log_directory}/server.log"
  user install_owner
  not_if { ::File.exist?("/etc/systemd/system/#{sep_systemd_service_name}.service") }
  only_if { become_root }
end
