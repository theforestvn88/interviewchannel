module CodeHelper
    SUPPORT_LANGS = [
        "ruby",
        "python",
        "javascript", 
        "typescript",
        "go",
        "java",
        "kotlin",
        "dart",
        "swift",
        "objectivec",
        "c", 
        "cpp",
        "csharp",
        "rust",
        "php",
        "perl",
        "scala",
        "erlang",
        "elixir",
        "crystal",
        "clojure",
        "css",
        "scss",
        "shell",
        "bash",
        "dockerfile",
        "sql",
        "r",
        "julia",
        "other"
    ].freeze
    
    def interview_stream(*interviews, **attributes)
      curr_interview = interviews.first
      return if curr_interview.nil?

      attributes[:channel] = attributes[:channel]&.to_s || "InterviewStreamsChannel"
      attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(interviews)
      attributes[:"interview-id"] = curr_interview.id
      # attributes[:"token"] = SecureRandom.hex(6)
      attributes[:"theme"] = 'blues-rock'

      # styles
      editor_main_style = %W( w-full pt-0 #{attributes[:"theme"]}-main )
      editor_header_style = %W( flex justify-between sticky top-0 mt-2 p-1 #{attributes[:"theme"]}-header text-xs )
      editor_command_style = %W( w-full sticky bottom-0 #{attributes[:"theme"]}-command border-0 text-xs pl-2 invisible )
      editor_lock_style = %W( w-full sticky bottom-0 #{attributes[:"theme"]}-lock border-0 text-xs pl-2 invisible )
      interview_intro_style = %W( #{attributes[:"theme"]}-intro text-xs row-7 )
      result_view_style = %W( #{attributes[:"theme"]}-result sticky bottom-0 pb-20 pl-2 w-full text-xs text-white invisible )
      
      candidate = curr_interview.candidate
      interviewers = curr_interview.interviewers

      tag.interview_stream(**attributes, class: "w-full min-h-screen") do |tag|
          tag.div(class: editor_main_style) { |tag|
            link_to("</\ interview > Channel", root_path, class: "pl-2 text-white text-sm hover:underline")
            .concat(
              tag.textarea(
                "/*" +
                [
                  curr_interview.title,
                  "Round: #{curr_interview.round}",
                  "Candidate: #{candidate.name}<#{candidate.email}>",
                  "Interviewers: #{interviewers.map{|i| i.name + '<' + i.email + '>'}.join(',')}",
                  "Start Time: #{curr_interview.start_time.in_time_zone(candidate.curr_timezone).strftime('%F %R')} #{candidate.curr_timezone}",
                  "End Time: #{curr_interview.end_time.in_time_zone(candidate.curr_timezone).strftime('%F %R')} #{candidate.curr_timezone}",
                ].join("\n") +
                "*/",
                class: interview_intro_style
              )
              .concat(tag.div(id: "editor-header", class: editor_header_style) { |tag|
                  tag.label(">> interview >> ./we_code.rb", id: "code-filename")
                  .concat(tag.div(id: "editor-theme", class: "flex justify-end") { "@#{attributes[:"theme"]}" })
              })
              .concat(code_editor(attributes))
              .concat(tag.textarea(id: "editor-result", class: result_view_style, disabled: true))
              .concat(tag.p(":", id: "editor-command", class: editor_command_style))
              .concat(tag.p("", id: "editor-lock", class: editor_lock_style))
            )
          }
          .concat(p2p_videos(attributes))
      end
    end

    def dropdown(prefix, name, items)
      tag.div { |tag|
          tag.div(class: "dropdown relative inline-block") { |tag|
          tag.button(
              class: "text-white inline-flex items-center"
          ) { |tag|
              tag.span("#{prefix}#{name}", id: "selected-#{name}", class: "mr-1", prefix: prefix)
          }.concat(
              tag.ul(
              class: "dropdown-menu absolute hidden text-gray-700 pt-1"
              ) { |tag|
              options = tag.hr
              items.each do |item|
                  options = options.concat tag.li(item, id: "#{name}-#{item}", class: "bg-gray-100 hover:bg-gray-400 py-2 px-4 block whitespace-no-wrap #{name}-option")
              end
              options
              }
          )
          }
      }
    end

    def code_editor(attributes)
      tag.div(class: "code-editor w-full") { |tag|
          tag.pre(" ", class: "code-hl")
          .concat(tag.textarea(class: "code-input #{attributes[:"theme"]}-caret", rows: "100", spellcheck: "false"))
          .concat(tag.div(class: "w-full h-full code-editor-overlay") { |tag|
              lines = tag.div(class: "pt-4")
              (1..1000).each do |row_id|
              lines = lines.concat(
                  tag.div(id: "row-#{row_id}", class: "code-line #{attributes[:"theme"]}-numline") {
                  tag.button(id: "row-lineindex-#{row_id}", class: "w-6 flex justify-end hover:cursor-pointer") {
                      tag.label("#{row_id}", class: "text-xs").concat tag.label("|")
                  }
                  }
              )
              end
              lines
          })
      }
    end

    def p2p_videos(attributes)
      tag.div(class: "w-full flex justify-end sticky bottom-0 right-10") { |tag|
          tag.div { |tag|
            tag.div(id: "remote-video-container", class: "relative w-36 h-32")
              .concat(tag.video(id: "local-video-#{attributes[:user_id]}", class: "p2p-video border border-green-600 absolute top-0 right-1", autoplay: true))
              .concat(tag.p(attributes[:user_name], id: "show-video-#{attributes[:user_id]}", class: "w-36 px-5 text-xs text-white bg-green-600 hover:cursor-pointer absolute bottom-0 right-1"))
              .concat(tag.button("-", id: "hide-video-#{attributes[:user_id]}", class: "text-xl text-red-600 bg-red-200 w-5 h-5 absolute top-0 right-1"))
          }
      }
    end
end