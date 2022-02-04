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

    tag.interview_stream(**attributes, class: "mx-auto w-full") do |tag|
      tag.div { |tag|
        tag.h1(interviews.first.note)
          .concat(
            tag.div(class: "w-1/2 flex justify-end") {
              dropdown('#', 'lang', SUPPORT_LANGS).concat dropdown('@', 'style', SUPPORT_STYLES)
            }
          )
          .concat(code_editor)
      }
      .concat(p2p_videos)
    end
  end

  def dropdown(prefix, name, items)
    tag.div { |tag|
      tag.div(class: "dropdown relative inline-block") { |tag|
        tag.button(
          class: "bg-gray-100 text-gray-700 py-1 px-3 inline-flex items-center border border-gray-300"
        ) { |tag|
          tag.span("#{prefix}#{name}", id: "selected-#{name}", class: "mr-1", prefix: prefix)
        }.concat(
          tag.ul(
            class: "dropdown-menu absolute hidden text-gray-700 pt-1 border border-gray-300"
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
    tag.div(class: "code-editor w-1/2 mt-1") { |tag|
      tag.pre(" ", class: "code-hl")
        .concat(tag.textarea(class: "input-transparent", rows: "10", spellcheck: "false"))
        .concat(tag.div(class: "w-full h-full code-editor-overlay") { |tag|
          lines = tag.div(class: "pt-4")
          (1..10).each do |row_id|
            lines = lines.concat(
              tag.div(id: "row-#{row_id}", class: "code-line") {
                tag.button(id: "row-lineindex-#{row_id}", class: "w-6 flex justify-end hover:cursor-pointer hover:bg-red-100") {
                  tag.label("#{row_id}", class: "text-xs")
                    .concat tag.label("|")
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
