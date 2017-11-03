namespace :datamigrate do
  desc 'Run data migration from v1'
  task :v1, [:sql_file, :domain, :username, :password] do |task, args|
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, "datamigrate:v1", args[:sql_file], args[:domain], args[:username], args[:password]
        end
      end
    end
  end
end
