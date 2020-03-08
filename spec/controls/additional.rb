# Task file for tests
ref_file = 'roles/k3s/tasks/additional.yaml'

control 'additional-01' do
  title 'Symlink embedded utilities'
  impact 'low'
  ref ref_file
  utilities = %w[kubectl crictl ctr]
  utilities.each do |utility|
    describe file("/usr/local/bin/#{utility}") do
      it { should exist }
      its('link_path') { should eq '/usr/local/bin/k3s' }
    end
  end
end

control 'additional-02' do
  title 'Add utilities autocompletion'
  impact 'low'
  ref ref_file
  autocompletions = %w[kubectl crictl]
  autocompletions.each do |autocompletion|
    describe file("/etc/bash_completion.d/#{autocompletion}") do
      it { should exist }
    end
  end
end
