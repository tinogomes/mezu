module Mezu
  class ApplicationController < ActionController::Base

    before_filter :authentication
    before_filter :change_locale
    before_filter :set_locale

    protect_from_forgery

    private
    def change_locale
      if params[:l] && Config.available_locales.include?(params[:l].to_sym)
        I18n.locale = params[:l]
        session[:_mezu_locale] = I18n.locale
      end
    end

    def set_locale
      I18n.locale = session[:_mezu_locale] || I18n.default_locale
    end

    def authentication
      unless instance_eval(&Config.authenticate)
        render :text => t("rosetta.access_denied"), :status => 401
        false
      end
    end
  end
end
