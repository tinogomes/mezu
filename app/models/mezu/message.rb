module Mezu
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

    # Return messages based on model name and ids.
    #
    #   Mezu::Message.list(:thing => 1)
    #
    scope :list, proc {|options|
      options = {options.class.name.underscore.to_sym => options.id} unless options.kind_of?(Hash)
      options.reverse_merge!(:global => true)

      query = select("DISTINCT(mezu_messages.id), mezu_messages.*").
              joins("LEFT JOIN mezu_readings ON mezu_readings.message_id = mezu_messages.id")

      conditions = [].tap do |c|
        # Retrive global messages
        c << %[(messageable_type IS NULL)] if options.delete(:global)

        # Retrieve message for provided AR classes
        options.each do |class_name, ids|
          ids = [ids].flatten.compact
          next if ids.empty?
          c << %[(messageable_type = "#{class_name.to_s.classify}" AND messageable_id IN(:#{class_name}))]
        end
      end

      # Only apply condition if conditions is set
      query = query.where(%[(#{conditions.join(" OR ")})], options) if conditions.any?
      query
    }

    scope :unread_by, proc {|reader|
      where(
        "mezu_messages.id NOT IN(
          SELECT mezu_readings.message_id
          FROM mezu_readings
          WHERE reader_type = :type AND reader_id = :id
        )",
        :type => reader.class.name, :id => reader.id
      )
    }

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

    # Mark message as read and associate it to the reader object.
    #
    #   @message = Mezu::Message.first
    #   @user = User.first
    #   @message.read_by!(@user)
    #
    def read_by!(reader)
      readings.create(:reader => reader) unless read_by?(reader)
    end

    # Check if a message has been read by the reader object.
    #
    #   @message = Mezu::Message.first
    #   @user = User.first
    #   @message.read_by?(@user)
    #
    def read_by?(reader)
      readings.from_reader(reader).first
    end

    private
    # This needs to be checked manually; otherwise,
    # validates_inclusion_of will cache the list.
    def check_locale # :nodoc:
      errors.add(:locale, :inclusion, :value => locale) unless Mezu::Config.available_locales.collect(&:to_s).include?(locale.to_s)
    end
  end
end
