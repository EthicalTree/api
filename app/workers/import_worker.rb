class ImportWorker < JobWorker
  def perform_job(job, update_progress, csv_content, fields, type)
    # Convert csv bytes into a string
    csv_content = csv_content.pack('c*')

    importer = Import::new_by_type(type, {
      csv: csv_content,
      fields: fields,
      update_progress: update_progress
    })

    importer.import()

    job.set_payload({ errors: importer.errors })
  end
end
