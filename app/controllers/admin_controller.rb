# frozen_string_literal: true

class AdminController < ApplicationController
    before_action :ensure_admin!
   
    private def is_admin?
        current_user.id == 1
    end

    private def ensure_admin!
        redirect_to root_path unless is_admin?
    end
end
