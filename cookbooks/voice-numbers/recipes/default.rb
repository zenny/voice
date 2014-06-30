git node[:voice_numbers][:basedir] do
  repository "git@#{node[:wim][:gitbase]}/voice-numbers.git"
  revision    node[:etc][:default_branch]
  action     :sync
  user        node[:wim][:user]
  group       node[:wim][:group]

  not_if "test -e #{node[:voice_numbers][:basedir]}/config"
end

file "#{node[:voice_numbers][:basedir]}/.ruby-version" do
  content "jruby-#{node[:jruby][:version]}"
  owner   node[:wim][:user]
  group   node[:wim][:group]
  mode    00755
end

template "#{node[:voice_numbers][:basedir]}/.bundle/config" do
  source   'bundle.config.erb'
  cookbook 'etc'
  owner     node[:wim][:user]
  group     node[:wim][:group]
end

template "#{node[:voice_numbers][:basedir]}/config/app.yml" do
  source 'app.yml.erb'
  owner   node[:wim][:user]
  group   node[:wim][:group]
end

template "#{node[:voice_numbers][:basedir]}/config/mongoid.yml" do
  source 'mongoid.yml.erb'
  owner   node[:wim][:user]
  group   node[:wim][:group]
end

directory node[:voice_numbers][:basedir] do
  mode 00755
end

bash 'install_voice_numbers' do
  user  node[:wim][:user]
  group node[:wim][:group]
  cwd   node[:voice_numbers][:basedir]

  code <<-EOH
    export HOME=#{node[:wim][:home]}
    export PATH=#{node[:jdk][:home]}/bin:$PATH

    source #{node[:rvm][:basedir]}/scripts/rvm
    rvm use jruby-#{node[:jruby][:version]}@global
    git reset --hard
    git checkout #{node[:etc][:default_branch]}
    bundle install --path=vendor/bundle
  EOH

  not_if "test -e #{node[:voice_numbers][:basedir]}/vendor/bundle/jruby/#{node[:jruby][:baseapi]}/gems"
end

directory node[:voice_numbers][:logdir] do
  mode 00755
end

directory '/etc/sv/voice-numbers' do
  mode 00755
end

template '/etc/sv/voice-numbers/run' do
  source 'srv_run.erb'
  mode 00755
end

directory '/etc/sv/voice-numbers/log' do
  mode 00755
end

template '/etc/sv/voice-numbers/log/run' do
  source 'log_run.erb'
  mode 00755
end

link '/etc/service/voice-numbers' do
  to '/etc/sv/voice-numbers'
end