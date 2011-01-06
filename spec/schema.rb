ActiveRecord::Schema.define(:version => 0) do
  create_table :mezu_messages do |t|
    t.string        :title, :null => false
    t.string        :level, :limit => 10, :null => false
    t.text          :body
    t.string        :locale, :null => false
    t.datetime      :expires_at
    t.references    :messageable, :polymorphic => true, :null => true

    t.timestamps
  end

  add_index :mezu_messages, [:messageable_type, :messageable_id]

  create_table :mezu_readings do |t|
    t.references :message, :null => false
    t.references :related, :polymorphic => true, :null => false
    t.timestamps
  end

  add_index :mezu_readings, :message_id

  create_table :users do |t|
    t.string :login
    t.string :password
  end

  create_table :posts do |t|
    t.string :title
  end
end
