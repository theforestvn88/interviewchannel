# frozen_string_literal: true

class Admin::AdminController < ApplicationController
    before_action :ensure_admin!

    private

        def is_admin?
            current_user&.admin?
        end

        def ensure_admin!
            redirect_to root_path unless is_admin?
        end
end
