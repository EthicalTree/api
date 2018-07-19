require 'sidekiq-scheduler'

class ETDbBackup
  include Sidekiq::Worker

  def perform(*args)
    if Rails.env != 'production'
      return
    end

    app_root = File.join(File.dirname(__FILE__), "..", "..")
    settings = Rails.configuration.database_configuration[Rails.env]
    database_name = settings['database']

    backup_filename = "#{settings['database']}-#{Time.now.strftime('%Y%m%d')}.sql"
    output_file = File.join(app_root, "tmp", backup_filename)
    password_flag = settings['password'].present? ? "-p'#{settings['password']}'" : ""

    cmd = "/usr/bin/env mysqldump -h #{settings['host']} -u #{settings['username']} #{password_flag} #{database_name} > #{output_file}"
    system(cmd)

    $fog_db_backups.files.create({
      key: "ethicaltree/#{backup_filename}",
      body: File.read(output_file),
      public: false
    })

    File.delete(output_file) if File.exist?(output_file)
  end
end

class BlogDbBackup
  include Sidekiq::Worker

  def perform(*args)
    if Rails.env != 'production'
      return
    end

    app_root = File.join(File.dirname(__FILE__), "..", "..")
    settings = Rails.configuration.database_configuration[Rails.env]
    database_name = 'ethicaltree_blog'

    backup_filename = "blog-#{Time.now.strftime('%Y%m%d')}.sql"
    output_file = File.join(app_root, "tmp", backup_filename)
    password_flag = settings['password'].present? ? "-p'#{settings['password']}'" : ""

    cmd = "/usr/bin/env mysqldump -h #{settings['host']} -u #{settings['username']} #{password_flag} #{database_name} > #{output_file}"
    system(cmd)

    $fog_db_backups.files.create({
      key: "blog/#{backup_filename}",
      body: File.read(output_file),
      public: false
    })

    File.delete(output_file) if File.exist?(output_file)
  end
end
