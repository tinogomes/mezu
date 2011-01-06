module Mezu
  class Reading < ActiveRecord::Base
    set_table_name "mezu_readings"

    belongs_to :message, :class_name => "Mezu::Message"
    belongs_to :related, :polymorphic => true

    validates_presence_of :message

    scope :from_related, lambda {|related|
      where(:related_id => related).where(:related_type => related.class.name)
    }
  end
end
