module Mezu
  class ApplicationController < ActionController::Base

    before_filter do
      unless instance_eval(&Config.authenticate)
        render :text => t("rosetta.access_denied"), :status => 401
        false
      end
    end

    before_filter :change_locale

    protect_from_forgery

    private
    def change_locale
      return true unless params[:l]
      I18n.locale = params[:l] if I18n.available_locales.include?(params[:l].to_sym)
    end
  end
end
