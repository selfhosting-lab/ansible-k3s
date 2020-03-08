# Task file for tests
ref_file = 'roles/k3s/tasks/install.yaml'

control 'install-01' do
  title 'Install Openshift Python module'
  impact 'low'
  ref ref_file
  describe command('pip3 show openshift') do
    its('stdout') { should match(/Name: openshift/) }
    its('exit_status') { should eq 0 }
  end
end

control 'install-02' do
  title 'Download K3s binary'
  impact 'high'
  ref ref_file
  describe file('/usr/local/bin/k3s') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0755' }
  end
  describe command('k3s') do
    it { should exist }
  end
end

control 'install-03' do
  title 'Manage service'
  impact 'high'
  ref ref_file
  describe file('/etc/systemd/system/k3s.service') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
    its('selinux_label') { should eq 'system_u:object_r:systemd_unit_file_t:s0' }
  end
end

control 'install-04' do
  title 'Manage sysconfig'
  impact 'high'
  ref ref_file
  describe file('/etc/sysconfig/k3s') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
    its('selinux_label') { should eq 'system_u:object_r:etc_t:s0' }
  end
end

control 'install-05' do
  title 'Ensure k3s is running'
  impact 'high'
  ref ref_file
  describe systemd_service('k3s') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe port(6443) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
    its('addresses') { should include '0.0.0.0' }
  end
end

control 'install-06' do
  title 'Wait for node token to be generated'
  impact 'medium'
  ref ref_file
  describe file('/var/lib/rancher/k3s/server/node-token') do
    it { should exist }
  end
end

control 'install-07' do
  title 'Store k3s certificates'
  impact 'medium'
  ref ref_file
  certificate = '/var/lib/rancher/k3s/server/tls/server-ca.crt'
  describe file(certificate) do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
  end
  describe x509_certificate(certificate) do
    its('extensions.keyUsage') { should include 'Digital Signature' }
    its('extensions.keyUsage') { should include 'Key Encipherment' }
    its('extensions.keyUsage') { should include 'Certificate Sign' }
  end
end

control 'install-08' do
  title 'K3s is able to communicate with client'
  impact 'high'
  ref ref_file
  # Test connection from CLI client
  describe command('/usr/local/bin/k3s kubectl version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match 'Server Version' }
  end
  # Load k3s authentication
  config = YAML.safe_load(file('/etc/rancher/k3s/k3s.yaml').content)
  credentials = config['users'][0]['user']
  describe http('https://localhost:6443/healthz',
    method:        'GET',
    open_timeout:  60,
    read_timeout:  60,
    ssl_verify:    true,
    max_redirects: 3,
    auth:          {
      user: credentials['username'],
      pass: credentials['password']
    }) do
    its('status') { should eq 200 }
    its('body') { should eq 'ok' }
  end
end
