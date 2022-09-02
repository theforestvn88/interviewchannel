class CodeRunJob < ApplicationJob
  queue_as :default

  def perform(interview_id, user_id, file_path, code)
    CodeRunner.run_with_tempfile(interview_id, user_id, file_path, code)
  end
end
