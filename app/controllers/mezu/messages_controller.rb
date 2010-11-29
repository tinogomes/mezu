module Mezu
  class MessagesController < ApplicationController
    respond_to :html

    before_filter :load_message, :except => [:index, :new, :create]
    before_filter :load_levels, :except => [:index]
    before_filter :normalize_params, :only => [:create, :update]

    rescue_from ActiveRecord::RecordNotFound, :with => :mezu_message_not_found

    helper_method :current_page, :previous_page?, :next_page?

    def index
      @messages = Mezu::Message.with_expired.for_page(current_page).includes(:messageable).all
    end

    def new
      @message = Mezu::Message.new(params[:message])
      @app_models = Mezu.models
    end

    def create
      @message = Mezu::Message.new(params[:message])
      flash[:notice] = t("mezu.flash.created_successful") if @message.save
      respond_with(@message, :location => mezu_messages_path)
    end

    def edit; end

    def update
      flash[:notice] = t("mezu.flash.updated_successful") if @message.update_attributes(params[:message])
      respond_with(@message, :location => mezu_messages_path)
    end

    def remove; end

    def destroy
      @message.destroy
      flash[:notice] = t("mezu.flash.deleted_successful")
      redirect_to mezu_messages_path
    end

    private
    def load_message
      @message = Mezu::Message.with_expired.find(params[:id])
    end

    def load_levels
      @levels = Mezu::Message::LEVELS.map {|i| [t("mezu.levels.#{i}"), i] }
    end

    def mezu_message_not_found
      flash[:error] = t("mezu.flash.record_not_found")
      redirect_to mezu_root_path
    end

    def normalize_params
      return true if (message = params[:message]).nil?
      message[:messageable_type] = nil if (blank_messageable = message[:messageable_id].blank? || message[:messageable_type].blank? )
      message[:messageable_id] = nil   if blank_messageable
      return true
    end

    def current_page
      @current_page ||= [params[:p].to_i, 1].max
    end

    def previous_page?
      @previous_page ||= current_page > 1
    end

    def next_page?
      @next_page ||= (@messages.size > Mezu::Message::PER_PAGE) ? !!(@messages.pop) : false
    end
  end
end
