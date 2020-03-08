# Task file for tests
ref_file = 'roles/k3s/tasks/users.yaml'

control 'users-01' do
  title 'Ensure kubeconfig directory exists in root user directory'
  impact 'low'
  ref ref_file
  describe file('/root/.kube') do
    it { should exist }
    its('type') { should be :directory }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0750' }
  end
end

control 'users-02' do
  title 'Ensure kubeconfig exists in root user directory'
  impact 'low'
  ref ref_file
  describe file('/root/.kube/config') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0640' }
  end
end
