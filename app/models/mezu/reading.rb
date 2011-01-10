module Mezu
  class Reading < ActiveRecord::Base
    set_table_name "mezu_readings"

    belongs_to :message, :class_name => "Mezu::Message"
    belongs_to :reader, :polymorphic => true

    validates_presence_of :message

    scope :from_reader, lambda {|reader|
      where(:reader_id => reader.id, :reader_type => reader.class.name)
    }
  end
end
