# frozen_string_literal: true

module BookMark
    module_function

    Contact_Page_Size = 10

    def recently_contacts(user, offset = 0, limit = Contact_Page_Size)
        return [] if user.nil?

        _offset = offset.to_i
        _limit = limit.to_i
        recently_contacts = user.recently_contacts.offset(_offset).limit(_limit)
        next_offset = recently_contacts.size >= _limit ? _limit : nil
        return [recently_contacts, next_offset]
    end

    def search_contacts(user, search_key, limit = Contact_Page_Size)
        contacts = user.recently_contacts
        contacts = contacts.where("custom_name ILIKE ?", "%#{search_key}%") if search_key.present?
        contacts = contacts.offset(0).limit(limit)
    end
end
