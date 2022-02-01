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
    "julia"
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
        tag.h1(interviews.first.note).concat tag.label("Lang: ").concat select_tag('lang', options_for_select(SUPPORT_LANGS, "ruby")).concat(
          tag.label("   Style: ").concat select_tag('style', options_for_select(SUPPORT_STYLES, "default")).concat(
            tag.div(class: "code-editor") { |tag|
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
          )
        )
      }
      .concat(tag.div(class: "w-full flex justify-end sticky bottom-0 right-10") { |tag|
        tag.div { |tag|
          tag.div(id: "remote-video-container")
            .concat(tag.video(id: "local-video", class: "p2p-video", autoplay: true))
        }
      })
    end
  end
end
