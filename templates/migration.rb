class CreateMezuMessages < ActiveRecord::Migration
  def self.up
    create_table :mezu_messages do |t|
      t.string        :title, :null => false
      t.string        :level, :limit => 10, :null => false
      t.string        :body
      t.string        :locale, :null => false
      t.datetime      :expires_at
      t.datetime      :read_at
      t.references    :messageable, :polymorphic => true, :null => true

      t.timestamps
    end

    add_index :mezu_messages, [:messageable_type, :messageable_id]
  end

  def self.down
    drop_table :mezu_messages
  end
end
