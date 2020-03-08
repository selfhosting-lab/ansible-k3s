# Task file for tests
ref_file = 'tasks/firewalld.yml'

control 'firewalld-01' do
  title 'Ensure service definition exists'
  impact 'medium'
  ref ref_file
  describe file('/etc/firewalld/services/kube-api.xml') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
    its('selinux_label') { should eq 'system_u:object_r:firewalld_etc_rw_t:s0' }
  end
end

control 'firewalld-02' do
  title 'firewalld : Ensure Kube-API is in the firewalld service list'
  impact 'medium'
  ref ref_file
  describe command('firewall-cmd --info-service=kube-api') do
    its('exit_status') { should eq 0 }
  end
end

control 'firewalld-03' do
  title ' Ensure Kube-API is available in the internal zone'
  impact 'medium'
  ref ref_file
  describe firewalld do
    it { should have_service_enabled_in_zone('kube-api', 'internal') }
  end
end
