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
    attributes[:"user"] = SecureRandom.hex(6) # TODO: replace by User model

    tag.interview_stream(**attributes) do |tag|
      tag.label("Lang: ").concat select_tag('lang', options_for_select(SUPPORT_LANGS, "ruby")).concat(
        tag.label("   Style: ").concat select_tag('style', options_for_select(SUPPORT_STYLES, "default")).concat(
          tag.div(class: "code-editor") { |tag|
            tag.pre("# in code we trust !!!", class: "code-hl")
              .concat tag.textarea(class: "input-transparent", spellcheck: "false")
          }
        )
      )
    end
  end
end
