# Task file for tests
ref_file = 'tasks/audit.yml'

control 'audit-01' do
  title 'Ensure audit configuration directory exists'
  impact 'low'
  ref ref_file
  describe file('/etc/kubernetes') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0755' }
    its('selinux_label') { should eq 'system_u:object_r:etc_t:s0' }
  end
end

control 'audit-02' do
  title 'Ensure Kube API audit configuration is installed'
  impact 'low'
  ref ref_file
  describe file('/etc/kubernetes/audit-policy.yaml') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
    its('selinux_label') { should eq 'system_u:object_r:etc_t:s0' }
  end
end

control 'audit-03' do
  title 'Ensure audit events are being logged'
  impact 'low'
  ref ref_file
  describe file('/var/log/kube-audit.log') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
    its('selinux_label') { should eq 'system_u:object_r:var_log_t:s0' }
  end
end
