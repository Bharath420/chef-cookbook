# install all the toolchains
include_recipe 'mc_jenkins_agent'

package 'tree'

if node['mc_hosting']['environment'] == 'devcloud'
  include_recipe 'mc_jenkins_agent_images::_devcloud_yum'
end

package 'ansible' do
  action  :install
  version node['mc_jenkins_agent_images']['ansible']['version']
  not_if { node['mc_jenkins_agent_images']['ansible']['skip'] }
end

# Remove this package in case it's installed because it conflicts with mc-cf-cli-autoscaler
package 'cf-cli' do
  action :remove
end

package 'mc-cf-cli-autoscaler' do
  options '--nogpg'
  action :upgrade
  not_if { node['mc_jenkins_agent_images']['cf_cli_autoscaler']['skip'] }
end

package 'cloudera-director-client' do
  options '--nogpg'
  action :install
  not_if { node['mc_jenkins_agent_images']['cloudera']['skip'] }
end

unless node['mc_jenkins_agent_images']['cobol']['skip']
  include_recipe 'mc_cobol::pre_install'
  include_recipe 'mc_cobol::topaz_cli'
end

unless node['mc_jenkins_agent_images']['java']['skip']
  include_recipe 'mc_jenkins_agent_java'
  include_recipe 'mc_jenkins_agent_images::_java_links'
end

unless node['mc_jenkins_agent_images']['sonar_scanner']['skip']
  include_recipe 'mc_sonar_scanner'

  link "#{node['mc_jenkins_agent']['home_dir']}/bin/sonar-scanner" do
    to    lazy { mc_sonar_scanner.get_path(node['mc_sonar_scanner']['base_dir']) }
    owner node['mc_jenkins_agent']['owner']
    group node['mc_jenkins_agent']['group']
    mode  '0550'
  end

  link "#{node['mc_jenkins_agent']['home_dir']}/bin/build-wrapper-linux-x86-64" do
    to    lazy { mc_sonar_scanner.get_buildWrapper_path64(node['mc_sonar_scanner']['base_dir']) }
    owner node['mc_jenkins_agent']['owner']
    group node['mc_jenkins_agent']['group']
    mode  '0550'
  end

  link "#{node['mc_jenkins_agent']['home_dir']}/bin/build-wrapper-linux-x86-32" do
    to    lazy { mc_sonar_scanner.get_buildWrapper_path32(node['mc_sonar_scanner']['base_dir']) }
    owner node['mc_jenkins_agent']['owner']
    group node['mc_jenkins_agent']['group']
    mode  '0550'
  end
end

# Other toolchains with their own cookbooks
include_recipe 'mc_android_sdk' unless node['mc_jenkins_agent_images']['android']['skip']
include_recipe 'mc_config_mgmt_pipeline_agent::integration_test_stage' unless node['mc_jenkins_agent_images']['config_mgmt']['it_stage']['skip']
include_recipe 'mc_config_mgmt_pipeline_agent::main_stages' unless node['mc_jenkins_agent_images']['config_mgmt']['main_stages']['skip']
include_recipe 'mc_cpp' unless node['mc_jenkins_agent_images']['cpp']['skip']
include_recipe 'mc_db2::full_client' unless node['mc_jenkins_agent_images']['db2']['skip']
include_recipe 'mc_jenkins_agent_javascript' unless node['mc_jenkins_agent_images']['javascript']['skip']
include_recipe 'mc_mq::client' unless node['mc_jenkins_agent_images']['mq']['skip']
include_recipe 'mc_oracle_client::client' unless node['mc_jenkins_agent_images']['oracle_client']['skip']
include_recipe 'mc_packer' unless node['mc_jenkins_agent_images']['packer']['skip']
include_recipe 'mc_python' unless node['mc_jenkins_agent_images']['python']['skip']
include_recipe 'mc_tuxedo' unless node['mc_jenkins_agent_images']['tuxedo']['skip']
include_recipe 'mc_vmware_ovftool' unless node['mc_jenkins_agent_images']['vmware_ovftool']['skip']
include_recipe 'mc_vra_cli' unless node['mc_jenkins_agent_images']['vra_cli']['skip']
include_recipe 'mc_web_browser' unless node['mc_jenkins_agent_images']['web_browser']['skip']
