# Cookbook Name:: starburst-cookbook
# Recipe:: install

# Including the Java setup recipe
include_recipe 'starburst-cookbook::set-java-home'

# Accessing variables from attributes/default.rb
version = node['starburst-cookbook']['version']
installer_file = node['starburst-cookbook']['installer_file']
installer_url = node['starburst-cookbook']['installer_url']
package_name = node['starburst-cookbook']['package_name']
software_name = node['starburst-cookbook']['software_name']
data_directory = node['starburst-cookbook']['data_directory']
etc_directory = node['starburst-cookbook']['etc_directory']
log_directory = node['starburst-cookbook']['log_directory']
install_owner = node['starburst-cookbook']['installation_owner']
install_group = node['starburst-cookbook']['installation_group']
ulimit_nofile_min = node['starburst-cookbook']['ulimit_nofile_min']
become_root = node['starburst-cookbook']['become_root']

# Validate installation method
raise "Cannot specify both installer_file and installer_url" if installer_file && installer_url

# Determine file type
is_rpm = installer_file.end_with?('.rpm') || installer_url.end_with?('.rpm')

# Fail if non-root and trying RPM install
raise "RPM install can only be run as root" if is_rpm && !become_root

# Check if RPM is already installed
rpm_installed = false
['starburst-enterprise', 'trino-server-rpm', 'presto-server-rpm'].each do |pkg|
  rpm_installed = true if system("rpm -q #{pkg}")
end

# Determine user and group
if become_root
  install_owner = install_owner.empty? ? node['current_user'] : install_owner
  install_group = install_group.empty? ? node['current_group'] : install_group
else
  install_owner = node['current_user']
  install_group = node['current_group']
end

# Debug message
Chef::Log.info("install_owner: #{install_owner}, install_group: #{install_group}")

# Install RPM if applicable and not already installed
if is_rpm && !rpm_installed
  # Create temporary directory
  tmp_dir = Dir.mktmpdir

  # Copy or Download RPM
  if installer_file
    cookbook_file "#{tmp_dir}/#{package_name}-#{version}.rpm" do
      source "#{package_name}-#{version}.rpm"
      mode '0400'
    end
  elsif installer_url
    remote_file "#{tmp_dir}/#{package_name}-#{version}.rpm" do
      source installer_url
      mode '0400'
    end
  end

  # Install RPM
  rpm_package package_name do
    source "#{tmp_dir}/#{package_name}-#{version}.rpm"
    action :install
    only_if { become_root }
  end
end

# Create required directories
[data_directory, etc_directory, log_directory].each do |dir|
  directory dir do
    owner install_owner
    group install_group
    mode '0755'
    action :create
  end
end

# Create etc symlink if not using RPM
unless is_rpm
  link "#{etc_directory}" do
    to "#{software_name}/etc"
    owner install_owner
    group install_group
  end
end


# If the value reported by the target is <= the specified minimum, ok=true.
# If the target's value is "unlimited", ok=true. Else, ok=false.
ruby_block 'check_ulimit' do
  block do
    ulimit_cmd_output = `ulimit -H -n`.strip
    ulimit_ok = if ulimit_cmd_output == 'unlimited'
                  true
                else
                  ulimit_cmd_output.to_i >= node['starburst-cookbook']['ulimit_nofile_min']
                end

    if !ulimit_ok
      Chef::Log.warn("The limit of open files (ulimit -H -n) is not adequate. Found: #{ulimit_cmd_output}, Required: #{node['starburst-cookbook']['ulimit_nofile_min']}")
    end
  end
  only_if { !node['starburst-cookbook']['become_root'] }
end
