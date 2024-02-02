# Cookbook Name:: starburst-cookbook
# Recipe:: stop-services

# Accessing variables from attributes/default.rb
sep_systemd_service_name = node['starburst-cookbook']['sep_systemd_service_name']
software_name = node['starburst-cookbook']['software_name']
installation_root = node['starburst-cookbook']['installation_root']
install_owner = node['starburst-cookbook']['installation_owner']
become_root = node['starburst-cookbook']['become_root']
etc_directory = node['starburst-cookbook']['etc_directory']


##################################################################
## Service was started by systemd
##################################################################

# Determine if service is managed by systemd
is_systemd = ::File.exist?("/etc/systemd/system/#{sep_systemd_service_name}.service")

service sep_systemd_service_name do
  action :stop
  only_if { is_systemd && become_root }
end

# Log the systemd status
execute 'log_systemd_status' do
  command "systemctl status #{sep_systemd_service_name}"
  action :run
  only_if { is_systemd && become_root }
end

##################################################################
## Service was started by systemV
##################################################################

# Stopping service via systemV (init.d)
execute 'stop_systemv_service' do
  command "service #{software_name} stop"
  action :run
  only_if "service #{software_name} status"
  only_if { become_root }
end

# # Log the systemV status
execute 'log_systemv_status' do
  command "service #{software_name} status"
  action :run
  only_if "service #{software_name} status"
  only_if { become_root }
end

# Determine user
install_owner = install_owner.empty? ? node['current_user'] : install_owner

############################################################################
# Stop service started by launcher
############################################################################
execute 'stop_via_launcher' do
  command "#{installation_root}/#{software_name}/bin/launcher stop --etc-dir #{etc_directory}"
  user install_owner
  only_if { become_root }
  not_if "service #{software_name} status"
end
