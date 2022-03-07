module InterviewsHelper
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
    attributes[:channel] = attributes[:channel]&.to_s || "InterviewStreamsChannel"
    attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(interviews)
    attributes[:"interview-id"] = interviews.first.id # TODO: uuid -> short link
    attributes[:"user_id"] = SecureRandom.hex(6) # TODO:   replace by User model
    attributes[:"user_name"] = attributes[:"user_id"]
    attributes[:"theme"] = 'blues-rock'

    # styles
    editor_main_style = %W( w-full pt-0 #{attributes[:"theme"]}-main )
    editor_header_style = %W( flex justify-between sticky top-0 mt-2 p-1 #{attributes[:"theme"]}-header text-xs )
    editor_command_style = %W( w-full sticky bottom-0 #{attributes[:"theme"]}-command border-0 text-xs pl-2 invisible )
    editor_lock_style = %W( w-full sticky bottom-0 #{attributes[:"theme"]}-lock border-0 text-xs pl-2 invisible )
    interview_intro_style = %W( #{attributes[:"theme"]}-intro text-xs )
    result_view_style = %W( #{attributes[:"theme"]}-result sticky bottom-0 pb-20 pl-2 w-full text-xs text-white invisible )

    tag.interview_stream(**attributes, class: "w-full min-h-screen") do |tag|
      tag.div(class: editor_main_style) { |tag|
        tag.textarea("/*\n #{interviews.first.note}\n reviewer: xyz@gmail.com\n candidate: abc@gmail.com\n*/", class: interview_intro_style)
        .concat(tag.div(id: "editor-header", class: editor_header_style) { |tag|
          tag.label(">> interview >> ./we_code.rb", id: "code-filename")
          .concat(tag.div(id: "editor-theme", class: "flex justify-end") { "@#{attributes[:"theme"]}" })
        })
        .concat(code_editor(attributes))
        .concat(tag.textarea(id: "editor-result", class: result_view_style, disabled: true))
        .concat(tag.p(":", id: "editor-command", class: editor_command_style))
        .concat(tag.p("", id: "editor-lock", class: editor_lock_style))
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
          (1..100).each do |row_id|
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
        tag.div(id: "remote-video-container")
          .concat(tag.video(id: "local-video", class: "p2p-video", autoplay: true))
      }
    }
  end
end
