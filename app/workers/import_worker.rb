class ImportWorker < JobWorker

  def perform_job(job, csv_content, fields)
    importer = Import::SeoPath.new({
      csv: csv_content,
      fields: fields,
      update_progress: lambda {|count, total| job.update_progress(count, total)}
    })

    importer.import()
  end
end

