class CodeRunJob < ApplicationJob
  queue_as :default

  def perform(interview_id, file_path, pos_start, pos_end)
    CodeRunner.run_with_tempfile(interview_id, file_path, pos_start, pos_end)
  end
end
