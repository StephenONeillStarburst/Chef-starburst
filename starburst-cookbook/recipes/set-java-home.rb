# Cookbook Name:: starburst-cookbook
# Recipe:: set-java-home 

# Accessing variables from attributes/default.rb
version = node['starburst-cookbook']['version']

# Get SEP major version number
major_ver = version.match(/^(\d+)/)[1]

# Get JDK version number
jdk_version = major_ver.to_i >= 390 ? 17 : 11

# # Discover JAVA_HOME
# java_home_script = "../files/find_java.sh"
# cookbook_file java_home_script do
#   source 'find_java.sh'
#   mode '0755'
# end

# java_home = `#{java_home_script} #{jdk_version}`.strip

# Specify the destination path for the script on the node
java_home_script_path = '/tmp/find_java.sh'

# Use the cookbook_file resource to place the script on the node
cookbook_file java_home_script_path do
  source 'find_java.sh'
  mode '0755'
end

# Use a ruby_block to execute the script, capture its output, and set JAVA_HOME
ruby_block "set_java_home" do
  block do
    # Ensure the script is executable
    File.chmod(0755, java_home_script_path)

    # Run the script and capture the output
    java_home_output = `#{java_home_script_path} #{jdk_version}`.strip

    # Use node.run_state as a temporary storage to share java_home across recipes
    node.run_state['java_home'] = java_home_output

    # Set JAVA_HOME as a node attribute
    node.override['java']['java_home'] = java_home_output

    # Set JAVA_HOME as an environment variable
    ENV['JAVA_HOME'] = java_home_output
  end
  action :run
end



# # Set JAVA_HOME
# node.override['java']['java_home'] = java_home

# # Use it in other recipes
# ENV['JAVA_HOME'] = java_home
