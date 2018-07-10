require 'sidekiq-scheduler'

class DbBackup
  include Sidekiq::Worker

  def perform(*args)
    app_root = File.join(File.dirname(__FILE__), "..", "..")
    settings = YAML.load(File.read(File.join(app_root, "config", "database.yml")))[Rails.env]

    backup_filename = "#{settings['database']}-#{Time.now.strftime('%Y%m%d')}.sql"
    output_file = File.join(app_root, "tmp", backup_filename)
    password_flag = settings['password'].present? ? "-p#{settings['password']}" : ""

    cmd = "/usr/bin/env mysqldump -h #{settings['host']} -u #{settings['username']} #{password_flag} #{settings['database']} > #{output_file}"

    $fog_db_backups.files.create({
      key: backup_filename,
      body: File.read(output_file),
      public: false
    })

    system(cmd)
  end
end
