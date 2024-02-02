# Cookbook Name:: starburst-cookbook
# Recipe:: restart-service

# Including the stop service recipe
include_recipe 'starburst-cookbook::stop'

# Including the start service recipe
include_recipe 'starburst-cookbook::start'