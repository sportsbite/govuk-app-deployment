set :application, "government-frontend"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "docker_frontend"

load 'docker'
