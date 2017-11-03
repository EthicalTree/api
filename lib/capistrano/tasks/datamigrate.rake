namespace :datamigrate do
  desc 'Run data migration from v1'
  task :v1 do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, "datamigrate:v1", sql_file, domain, username, password
        end
      end
    end
  end
end
