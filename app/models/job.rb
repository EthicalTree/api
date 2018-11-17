class Job < ApplicationRecord
  enum status: [:starting, :in_progress, :complete, :error]

  validates :job_type, presence: true

  def self.start_job worker, *args
    job = Job.create({
                       job_type: worker.to_s,
                       status: :starting,
                       progress: 0,
                       payload: '',
                       error_msg: '',
                       error_stack_trace: '',
                     })

    worker.perform_async(job.id, *args)

    job
  end

  def set_payload contents
    self.payload = contents.to_json
  end

  def update_progress count, total
    self.progress = (count.to_f / total.to_f * 100.0).to_i
    Rails.cache.write("jobs_#{self.id}_progress", self.progress)
  end

  def realtime_progress
    Rails.cache.read("jobs_#{self.id}_progress")
  end

  def payload_object
    if payload.present?
      payload_data = JSON.parse(payload)

      case job_type
      when 'ExportWorker'
        key = payload_data['s3_key']
        payload_data['download_url'] = $fog_ethicaltree.files.head(key).url(Time.now.to_i + 1.hour)
      end

      payload_data
    else
      {}
    end
  end
end
