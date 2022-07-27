# frozen_string_literal: true

module OmniAuthParser
    extend ActiveSupport::Concern

    module ClassMethods
        def parse_user_uid(auth)
            "%s/%s" % [auth['provider'], auth['uid']]
        end

        def parse_github(auth)
            if github_provider?(auth)
                auth.info["urls"]['GitHub']
            else
                ''
            end
        end

        def parse_user_info(auth, *attrs)
            attrs.map { |attr| auth.dig(:info, attr) }
        end
        
        def parse_user_name(auth)
            name_attr = github_provider?(auth) ? 'nickname' : 'name'
            auth.dig(:info, name_attr)
        end

        def parse_user_image(auth)
            auth.dig(:info, :image)
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

        def parse_user_primary_email(auth)
            auth.dig(:info, :email)
        end

        private def github_provider?(auth)
            auth['provider'] == 'github'
        end
    end
end
