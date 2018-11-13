class JobWorker
  include Sidekiq::Worker

  def perform(job_id, *args)
    job = Job.find(job_id)
    job.started_at = Time.now

    begin
      Job.transaction do
        self.perform_job(job, *args)
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
