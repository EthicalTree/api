class JobWorker
  include Sidekiq::Worker

  def perform(job_id, *args)
    job = Job.find(job_id)
    job.started_at = Time.now

    begin
      update_progress = lambda { |count, total| job.update_progress(count, total) }
      update_progress.call(0, 1)

      Job.transaction do
        self.perform_job(job, update_progress, *args)
        job.status = :complete
        job.finished_at = Time.now
      end
    rescue Exception => e
      job.error_msg = e.message
      job.error_stack_trace = e.backtrace.join('\r\n')
      job.status = :error
    end

    job.save!
  end
end
