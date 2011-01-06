module Mezu
  class YouCannotMarkGlobalMessagesAsReadError < RuntimeError
    def message
      "You cannot mark global messages as read"
    end
  end

  class Message < ActiveRecord::Base
    set_table_name "mezu_messages"

    LEVELS = %w(info warn error)
    PER_PAGE = 10

    validates_presence_of :title, :body
    validates_presence_of :expires_at, :if => lambda {|m| m.messageable_id.nil? }
    validates_inclusion_of :level, :in => LEVELS
    validate :check_locale

    belongs_to :messageable, :polymorphic => true
    has_many :readings, :class_name => "Mezu::Reading", :foreign_key => "message_id"

    # Return messages that haven't expired.
    #
    scope :active, proc {
      where("expires_at IS NULL or expires_at > '#{Time.now}'")
    }

    # Sort messages from newest to oldest.
    #
    scope :by_newest, order("created_at DESC")

    # Return messages from a given locale.
    #
    scope :by_locale, proc {|locale|
      where(:locale => locale.to_s)
    }

    # Return messages that expired.
    #
    scope :expired, proc {
      where("expires_at <= '#{Time.now}'")
    }

    # Return messages attached to a given object.
    #
    scope :for_messageable, proc {|item|
      if item
        where({:messageable_type => item.class.name, :messageable_id => item.id})
      else
        # Workaround to return an empty result
        where("1 > 2")
      end
    }

    # Return unread messages.
    #
    scope :unread_by, lambda {|related|
      select("mezu_messages.*").
      joins("
        LEFT JOIN mezu_readings ON
        mezu_readings.message_id = mezu_messages.id AND
        mezu_readings.related_type = '#{related.class.name}' AND
        mezu_readings.related_id = #{related.id.to_i}
      ").
      where("mezu_readings.message_id IS NULL")
    }

    # Return global messages.
    #
    scope :global, where(:messageable_id => nil)

    default_scope active.by_newest

    # Return all messages, including private and global messages.
    #
    def self.with_expired
      unscoped.order("created_at DESC")
    end

    # Return messages for a given page.
    #
    def self.for_page(page)
      page = [page.to_i, 1].max - 1
      offset(page * PER_PAGE).limit(PER_PAGE + 1)
    end

    # Return true if is a global message.
    #
    def global?
      messageable_id.nil?
    end

    # Return true if message is expired
    #
    def expired?
      expires_at? && expires_at < Time.now
    end

    # Mark message as read and associate it to the related object.
    #
    #   @message = Mezu::Message.first
    #   @user = User.first
    #   @message.read_by!(@user)
    #
    def read_by!(related)
      readings.create(:related => related) unless read_by?(related)
    end

    # Check if a message has been read by the related object.
    #
    #   @message = Mezu::Message.first
    #   @user = User.first
    #   @message.read_by?(@user)
    #
    def read_by?(related)
      readings.from_related(related).first
    end

    private
    # This needs to be checked manually; otherwise,
    # validates_inclusion_of will cache the list.
    def check_locale # :nodoc:
      errors.add(:locale, :inclusion, :value => locale) unless Mezu::Config.available_locales.collect(&:to_s).include?(locale.to_s)
    end
  end
end
