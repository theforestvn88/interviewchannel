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

  SUPPORT_STYLES = [
    "default", 
    "github"
  ].freeze

  def interview_stream(*interviews, **attributes)
    attributes[:channel] = attributes[:channel]&.to_s || "InterviewStreamsChannel"
    attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(interviews)
    attributes[:"interview-id"] = interviews.first.id
    attributes[:"user"] = SecureRandom.hex(6) # TODO:   replace by User model

    tag.interview_stream(**attributes, class: "w-full min-h-screen") do |tag|
      tag.div(class: "w-full bg-sky-800 pt-5") { |tag|
        tag.textarea("/*\n #{interviews.first.note}\n reviewer: xyz@gmail.com\n candidate: abc@gmail.com\n*/", class: "interview-info text-xs text-white")
        .concat(tag.div(id: "editor-header", class: "flex justify-between sticky top-0 mt-2 bg-cyan-600 text-xs text-white") { |tag|
          tag.label(">> interview >> ./we_code.rb")
          .concat(tag.div(class: "flex justify-end") {
            dropdown('#', 'lang', SUPPORT_LANGS).concat dropdown('@', 'style', SUPPORT_STYLES)
          })
        })
        .concat(code_editor)
        .concat(tag.input(id: "editor-command", class: "w-full sticky bottom-0 bg-cyan-300 border-0 text-xs text-white pl-5"))
      }
      .concat(p2p_videos)
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

  def code_editor
    tag.div(class: "code-editor w-full") { |tag|
      tag.pre(" ", class: "code-hl")
        .concat(tag.textarea(class: "code-input", rows: "100", spellcheck: "false"))
        .concat(tag.div(class: "w-full h-full code-editor-overlay") { |tag|
          lines = tag.div(class: "pt-4")
          (1..100).each do |row_id|
            lines = lines.concat(
              tag.div(id: "row-#{row_id}", class: "code-line") {
                tag.button(id: "row-lineindex-#{row_id}", class: "w-6 flex justify-end hover:cursor-pointer hover:bg-red-100") {
                  tag.label("#{row_id}", class: "text-xs text-white")
                    .concat tag.label("|", class: "text-white")
                }
              }
            )
          end
          lines
        })
    }
  end

  def p2p_videos
    tag.div(class: "w-full flex justify-end sticky bottom-0 right-10") { |tag|
      tag.div { |tag|
        tag.div(id: "remote-video-container")
          .concat(tag.video(id: "local-video", class: "p2p-video", autoplay: true))
      }
    }
  end
end
