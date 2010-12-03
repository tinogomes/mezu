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

    # active - A Scope to filter messages are not expired
    #
    scope :active, proc {
      where("expires_at IS NULL or expires_at > '#{Time.now}'")
    }

    # by_newest - A Scope to sort newest messages
    #
    scope :by_newest, order("created_at DESC")

    # by_locale - A Scope to return messages from a specific locale
    #
    scope :by_locale, proc {|locale|
      where(:locale => locale.to_s)
    }

    # expired - A Scope to filter expired messages
    #
    scope :expired, proc {
      where("expires_at <= '#{Time.now}'")
    }

    # for_messageable(<tt>item</tt>) - A Scope to filter messages for some item messageable
    # <tt>item</tt> - It is some instance of your model
    #
    scope :for_messageable, proc {|item|
      if item
        where({:messageable_type => item.class.name, :messageable_id => item.id})
      else
        # Workaround to return an empty result
        where("1 > 2")
      end
    }

    # unread - A Scope to filter only unread messages
    #
    scope :unread, where(:read_at => nil)

    # global - A Scope to filter global messages
    #
    scope :global, where(:messageable_id => nil)

    # top(<tt>number</tt>) - A Scope to limit number of messages to see
    # <tt>number</tt> - number of messages you want to see.
    #
    scope :top, proc {|n|
      n = [n.to_i, 1].max
      limit(n)
    }

    default_scope active.by_newest

    # with_expired - A Scope to see all messages (private and global)
    #
    def self.with_expired
      unscoped.order("created_at DESC")
    end

    # for_page(<tt>page</tt>) - A Scope to filter messages for some page number (10 messages per page)
    # <tt>page</tt> - a number that represents page you want see messages
    #
    def self.for_page(page)
      page = [page.to_i, 1].max - 1
      offset(page * PER_PAGE).limit(PER_PAGE + 1)
    end

    # global? - Return true/false if message are global or not.
    #
    def global?
      messageable_id.nil?
    end

    # expired? - Returns true/false if message is expired
    #
    def expired?
      expires_at? && expires_at < Time.now
    end

    # read! - Marks the message as read. Only wokrs for private messages. For global messages will raise!
    #
    def read!
      raise YouCannotMarkGlobalMessagesAsReadError if global?
      update_attribute(:read_at, Time.now)
    end

    private
    # This needs to be checked manually; otherwise,
    # validates_inclusion_of will cache the list.
    def check_locale # :nodoc:
      errors.add(:locale, :inclusion, :value => locale) unless Mezu::Config.available_locales.collect(&:to_s).include?(locale.to_s)
    end
  end
end
