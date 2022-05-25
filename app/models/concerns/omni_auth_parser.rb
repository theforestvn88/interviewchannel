# frozen_string_literal: true

module OmniAuthParser
    extend ActiveSupport::Concern

    module ClassMethods
        def parse_user_uid(auth)
            "%s/%s" % [auth['provider'], auth['uid']]
        end

        def parse_github(auth)
            if auth['provider'] == 'github'
                auth.info["urls"]['GitHub']
            else
                ''
            end
        end

        def parse_user_info(auth)
            name_attr = auth['provider'] == 'github' ? 'nickname' : 'name'
            [name_attr, 'email', 'image'].map { |attr| auth.info[attr] }
        end
    end
end
