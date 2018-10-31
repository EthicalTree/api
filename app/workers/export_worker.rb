class ExportWorker < JobWorker

  def perform_job(job, format, fields, type)
    exporter = Export::Listing.new({
      format: format,
      fields: fields,
      type: type,
      update_progress: lambda {|count, total| job.update_progress(count, total)}
    })

    file_prefix = "#{type}"
    key ="admin/exports/#{type}/#{file_prefix}_#{Time.now.to_s}.#{format}"

    Tempfile.open(file_prefix, Rails.root.join('tmp')) do |fd|
      exporter.generate(fd)
      fd.rewind

      $fog_ethicaltree.files.create({
        key: key,
        body: fd.read,
        public: false
      })
    end

    job.payload = { s3_key: key }.to_json
  end
end

