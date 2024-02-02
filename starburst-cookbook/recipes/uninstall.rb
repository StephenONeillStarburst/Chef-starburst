# Cookbook Name:: starburst-cookbook
# Recipe:: uninstall-starburst

# Accessing variables from attributes/default.rb
software_name = node['starburst-cookbook']['software_name']
installation_root = node['starburst-cookbook']['installation_root']
install_owner = node['starburst-cookbook']['installation_owner']
install_group = node['starburst-cookbook']['installation_group']
data_directory = node['starburst-cookbook']['data_directory']
etc_directory = node['starburst-cookbook']['etc_directory']
log_directory = node['starburst-cookbook']['log_directory']
sep_systemd_service_name = node['starburst-cookbook']['sep_systemd_service_name']

##################################################################
## Service was started by systemd
##################################################################

# Check if systemd service is active and fail if it is
execute 'check_systemd_service_active' do
  command "systemctl is-active #{sep_systemd_service_name}"
  returns [1, 3] # Active: 0, Inactive: 1, Failed: 3
  only_if { ::File.exist?("/etc/systemd/system/#{sep_systemd_service_name}.service") }
end

##################################################################
## Service was started by systemV
##################################################################

# Check if systemV service is active and fail if it is
execute 'check_systemv_service_active' do
  command "service #{software_name} status"
  returns [1, 3]
  not_if { ::File.exist?("/etc/systemd/system/#{sep_systemd_service_name}.service") }
end

##################################################################
## Service was started by launcher
##################################################################

# Check if running via launcher and fail if it is
execute 'check_launcher_service_active' do
  command "#{installation_root}/#{software_name}/bin/launcher status"
  user install_owner
  returns [1, 3]
  not_if { ::File.exist?("/etc/systemd/system/#{sep_systemd_service_name}.service") }
end

# Uninstall RPM if exists
execute 'uninstall_rpm' do
  command "rpm -q #{software_name} && rpm -e #{software_name}"
  returns [0, 1] # Success: 0, Not installed: 1
  action :run
end

# Remove installation symlink
link "#{installation_root}/#{software_name}" do
  action :delete
end

# Delete all directories
directories_to_remove = Dir.glob("#{installation_root}/{trino*,presto*,starburst-enterprise*}")
directories_to_remove << data_directory
directories_to_remove << etc_directory
directories_to_remove << log_directory

directories_to_remove.each do |dir|
  directory dir do
    recursive true
    action :delete
  end
end

# Delete user and group if root
if node['starburst-cookbook']['become_root']
  user install_owner do
    action :remove
    ignore_failure true
  end

  group install_group do
    action :remove
    ignore_failure true
  end
end