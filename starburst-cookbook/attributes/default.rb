# Basic version and environment settings
default['starburst-cookbook']['version'] = '429-e.2'
default['starburst-cookbook']['node_environment'] = 'production'

# Determining package, tarball, and software names based on version
version = node['starburst-cookbook']['version']
version_number = version.match(/\d+/)[0].to_i
is_enterprise_version = version.include?('-e')

default['starburst-cookbook']['package_name'] = if is_enterprise_version || version_number >= 351
                                             'starburst-enterprise'
                                           else
                                             'trino-server-rpm'
                                           end

default['starburst-cookbook']['tarball_name'] = if is_enterprise_version || version_number >= 351
                                             'starburst-enterprise'
                                           else
                                             'presto-server'
                                           end

default['starburst-cookbook']['software_name'] = if is_enterprise_version || version_number >= 351
                                              'starburst'
                                            else
                                              'presto'
                                            end

# File paths and installation settings
default['starburst-cookbook']['local_files'] = '../files'
default['starburst-cookbook']['local_logs'] = 'logs'
default['starburst-cookbook']['sep_systemd_service_name'] = 'starburst.service'

# Use `installer_url` to avoid uploading the installer file to each host.
# You can only use one installation method. Comment out `installer_file` when enabling `installer_url`.
# default['starburst-cookbook']['installer_file'] = "https://s3.us-east-2.amazonaws.com/software.starburstdata.net/402e/429-e.2/starburst-enterprise-429-e.2.tar.gz"
# default['starburst-cookbook']['installer_file'] =  "https://s3.us-east-2.amazonaws.com/software.starburstdata.net/402e/429-e.2/starburst-enterprise-429-e.2.rpm"

# Alternatively you can install from local file
# If using a tarball instead of an rpm, comment the below line and uncomment the following
default['starburst-cookbook']['installer_file'] = "#{node['starburst-cookbook']['local_files']}/#{node['starburst-cookbook']['package_name']}-#{node['starburst-cookbook']['version']}.rpm"
# Uncomment the following line if using tarball installation
# default['starburst-cookbook']['installer_file'] = "#{node['starburst-cookbook']['local_files']}/#{node['starburst-cookbook']['tarball_name']}-#{node['starburst-cookbook']['version']}.tar.gz"

# Network settings
default['starburst-cookbook']['coordinator_port'] = 22
default['starburst-cookbook']['worker_port'] = 22

# User and directory settings
# These are the recommended file path settings when become_root is set to true.
default['starburst-cookbook']['become_root'] = true
default['starburst-cookbook']['data_directory'] = "/var/lib/#{node['starburst-cookbook']['software_name']}"
default['starburst-cookbook']['etc_directory'] = "/etc/#{node['starburst-cookbook']['software_name']}"
default['starburst-cookbook']['log_directory'] = "/var/log/#{node['starburst-cookbook']['software_name']}"
default['starburst-cookbook']['installation_root'] = '/usr/lib'

# Uncomment and adjust the following lines if become_root is set to false
# default['starburst-cookbook']['installation_root'] = '/opt/starburst'
# default['starburst-cookbook']['data_directory'] = "#{node['starburst-cookbook']['installation_root']}/data"
# default['starburst-cookbook']['etc_directory'] = "#{node['starburst-cookbook']['installation_root']}/etc"
# default['starburst-cookbook']['log_directory'] = "#{node['starburst-cookbook']['installation_root']}/log"

# File ownership settings
# The downloaded installation files will be set to have this owner and group.
# But, if become_root=no, these are ignored, and all files will become
# owned by the chef_user.
default['starburst-cookbook']['installation_owner'] = node['starburst-cookbook']['software_name']
default['starburst-cookbook']['installation_group'] = node['starburst-cookbook']['software_name']

# Restart settings
default['starburst-cookbook']['graceful_shutdown_user'] = 'chef' # Value of X-Presto-User or X-Trino-User header
default['starburst-cookbook']['graceful_shutdown_retries'] = 120 # Number of times to check status before failing
default['starburst-cookbook']['graceful_shutdown_delay'] = 5 # Number of seconds to sleep between checking status
default['starburst-cookbook']['rolling_restart_concurrency'] = 1 # Number of Workers to restart at a time

# System limits - Minimum number of open files (ulimit -H -n)
default['starburst-cookbook']['ulimit_nofile_min'] = 131072

# Memory auto configuration
default['starburst-cookbook']['memory_auto_config']['use_auto_config'] = false
default['starburst-cookbook']['memory_auto_config']['max_concurrent_queries'] = 3
# Coordinator Configuration
default['starburst-cookbook']['memory_auto_config']['coordinator']['total_memory'] = '60GB'
default['starburst-cookbook']['memory_auto_config']['coordinator']['node_memory_headroom'] = '2GB'
default['starburst-cookbook']['memory_auto_config']['coordinator']['heap_size_percentage'] = 90
default['starburst-cookbook']['memory_auto_config']['coordinator']['heap_headroom_percentage'] = 30
# Worker Configuration
default['starburst-cookbook']['memory_auto_config']['worker']['total_memory'] = '100GB'
default['starburst-cookbook']['memory_auto_config']['worker']['node_memory_headroom'] ='2GB'
default['starburst-cookbook']['memory_auto_config']['worker']['heap_size_percentage'] = 90
default['starburst-cookbook']['memory_auto_config']['worker']['heap_headroom_percentage'] = 30