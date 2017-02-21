require 'fetch_build'

set :application, "govuk_crawler_worker"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "mirrorer"

# Use the build number from the release tag if given
# Otherwise, this will fall back to using the lastSuccessfulBuild below.
if ENV["TAG"] =~ /\Arelease_(\d+)\z/
  set :artefact_number, $1
end

load 'defaults'

namespace :deploy do
  # This overrides the default update_code task
  desc "Copies the CI build artefact to the remote servers."
  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    run "mkdir -p #{release_path}"

    branch = ENV["TAG"] || "master"
    branch = "master" if branch == "release"

    ci_base_url = "https://ci_alphagov:#{ENV['CI_DEPLOY_JENKINS_API_KEY']}@ci.integration.publishing.service.gov.uk/job/#{application}/job/#{branch}"

    artefact_to_deploy = fetch(:artefact_number, fetch_last_build_number(ci_base_url))
    put "#{artefact_to_deploy}\n", "#{release_path}/build_number"

    artefact_url = "#{ci_base_url}/#{artefact_to_deploy}/artifact/#{application}"
    logger.info "Fetching #{artefact_url} from CI server"
    file = fetch_to_tempfile(artefact_url)
    top.upload file, "#{release_path}/#{application}", :mode => "0755"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    # The deploy user always has permission to run initctl commands.
    run "sudo initctl start #{application} 2>/dev/null || sudo initctl reload #{application}"
  end
end
