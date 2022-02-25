# frozen_string_literal: true

class CodeRunner
    RUNNER = {
        "rb" => "ruby".freeze,
        "js" => "node".freeze
    }.freeze

    CATCHER = {
        "rb" => "begin\n%s\nrescue => e\nputs \"ERROR: \#{e}\"\nend\n",
        "js" => "try {\n%s\n} catch (error) {\nconsole.log(`ERROR: ${error.message}`);\n}\n"
    }.freeze

    def self.run_with_tempfile(interview_id, file_path, pos_start, pos_end)
        interview = Interview.new(id: interview_id)
        code = CodeRepo.get_code(interview_id, file_path)
        unless code
            InterviewStreamsChannel.broadcast_update_interview(interview, {
                component: "code",
                result: "Something go wrong"
            })
            return
        end

        unless runner = RUNNER[ext = file_path.split(".").last]
            InterviewStreamsChannel.broadcast_update_interview(interview, {
                component: "code",
                result: "Could not run .#{ext} file"
            })
            return
        end

        require "tempfile"
        tempfile = Tempfile.new("#{interview_id}_#{file_path}")
        code = code[pos_start..pos_end]
        tempfile << CATCHER[ext] % code
        tempfile.close
        output = `#{runner} #{tempfile.path}`

        InterviewStreamsChannel.broadcast_update_interview(interview, {
            component: "code",
            result: output
        })
    end
end
