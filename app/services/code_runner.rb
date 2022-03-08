# frozen_string_literal: true

class CodeRunner
    RUNNER = { # TODO: runner for c/c++/java/kotlin/python...
        "rb" => "ruby".freeze,
        "js" => "node".freeze
    }.freeze

    CATCHER = {
        "rb" => "begin\n%s\nrescue => e\nputs \"ERROR: \#{e}\"\nend\n",
        "js" => "try {\n%s\n} catch (error) {\nconsole.log(`ERROR: ${error.message}`);\n}\n"
    }.freeze

    def self.run_with_tempfile(interview_id, user_id, file_path, pos_start, pos_end)
        interview = Interview.new(id: interview_id)
        code = CodeRepo.get_code(interview_id, file_path)
        unless code
            response(interview, user_id, "Something go wrong")
            return
        end

        unless runner = RUNNER[ext = file_path.split(".").last]
            response(interview, user_id, "Could not run .#{ext} file")
            return
        end

        require "tempfile"
        tempfile = Tempfile.new("#{interview_id}_#{file_path}")
        code = code[pos_start..pos_end]
        tempfile << CATCHER[ext] % code # TODO: wrap into a timeout handler
        tempfile.close
        output = `#{runner} #{tempfile.path}`
        
        response(interview, user_id, output)
    end

    def self.response(interview, user_id, result)
        lock = InterviewRepo.get_broadcast_lock(interview.id)
        if lock == user_id
            InterviewStreamsChannel.broadcast_update_interview(interview, {
                component: "code",
                result: result
            })
        end
        # reset lock time
        InterviewRepo.delete_coderun_lock(interview.id)
        InterviewRepo.delete_broadcast_lock(interview.id)
    end
end
