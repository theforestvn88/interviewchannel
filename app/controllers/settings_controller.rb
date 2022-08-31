class SettingsController < Admin::AdminController
    before_action :ensure_admin!
    before_action :set_setting, only: %i[ show edit update ]

    def show
    end

    def edit
    end

    def update
        if @setting.update(setting_params)
            head :no_content
        else
        end
    end

    private
    
        def set_setting
            @setting = Setting.find(params[:id])
        end

        def setting_params
            params.require(:setting).permit(:key, :value).tap do |setting|
                setting[:value] = JSON.parse(setting[:value])
            end
        end
end
