namespace :images do

  desc "Force update S3 images"
  task :force_update_s3_images, [] => [:environment] do |task, args|
    puts 'Starting force update...'
    puts ''

    $fog_images.files.each do |f|
      print('.')
      f.save
    end
  end

end
