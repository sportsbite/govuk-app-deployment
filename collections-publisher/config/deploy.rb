set :application, "collections-publisher"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

set :source_db_config_file, false

set :config_files_to_upload, {
  'secrets/to_upload/redis.yml' => 'config/redis.yml',
  'secrets/to_upload/secrets.yml' => 'config/secrets.yml',
}

set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
