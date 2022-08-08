# frozen_string_literal: true

module OmniAuthParser
    extend ActiveSupport::Concern

    module ClassMethods
        def parse_uid(auth)
            auth['uid']
        end

        def parse_provider(auth)
            auth['provider']
        end

        def parse_user_uid(auth)
            "%s/%s" % [parse_provider(auth), parse_uid(auth)]
        end

        def parse_social_link(auth)
            social = github_provider?(auth) ? "GitHub" : parse_provider(auth).capitalize
            auth.info.dig("urls", social)
        end

        def parse_github(auth)
            if github_provider?(auth)
                parse_social_link(auth)
            else
                ''
            end
        end

        def parse_user_info(auth, *attrs)
            attrs.map { |attr| auth.dig(:info, attr) }
        end
        
        def parse_user_name(auth)
            name_attr = github_provider?(auth) ? 'nickname' : 'name'
            auth.dig(:info, name_attr) || "%s %s" % [auth.dig(:info, :first_name), auth.dig(:info, :last_name)]
        end

        def parse_user_image(auth)
            auth.dig(:info, :image) || auth.dig(:info, :picture_url)
        end

        def parse_user_primary_email(auth)
            auth.dig(:info, :email)
        end

        def parse_user_emails(auth)
            if github_provider?(auth)
                emails = auth.dig(:extra, :all_emails)
                if primary_email = emails.find { |email| email[:primary] }
                    emails.delete(primary_email)
                    emails.unshift(primary_email)
                end

                emails.map { |email| email[:email] }
            else
                [parse_user_primary_email(auth)]
            end
        end

        private def github_provider?(auth)
            auth['provider'] == 'github'
        end
    end
end
