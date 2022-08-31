# frozen_string_literal: true

class Admin::AdminController < ApplicationController
    before_action :ensure_admin!, except: [:confirm_pass]

    def enter_pass
    end

    def confirm_pass
        if verify_admin_pass(params[:pass])
            set_ap_key
            redirect_to admin_path
        else
            reset_session
            redirect_to root_path
        end
    end

    private

        def is_admin?
            current_user&.admin?
        end

        def get_admin_pass
            if ap_key = session[:ap_key]
                Rails.cache.read(ap_key)
            end
        end

        def verify_admin_pass(pass)
            pass.to_s == Rails.application.credentials.admin[:pass].to_s
        end

        def set_ap_key
            session[:ap_key] = ap_key = SecureRandom.hex
            Rails.cache.write(ap_key, Rails.application.credentials.admin[:pass].to_s, expired_in: 5.minutes)
        end

        def ensure_admin!
            redirect_to(root_path) and return unless is_admin?
            render(template: "admin/enter_pass") and return unless verify_admin_pass(get_admin_pass)
        end
end
