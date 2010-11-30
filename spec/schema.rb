ActiveRecord::Schema.define(:version => 0) do
  create_table :mezu_messages do |t|
    t.string        :title, :limit => 50
    t.string        :level, :limit => 10
    t.string        :body
    t.datetime      :expires_at
    t.datetime      :read_at
    t.references    :messageable, :polymorphic => true

    t.timestamps
  end

  add_index :mezu_messages, [:messageable_type, :messageable_id]

  create_table :users do |t|
    t.string :login
    t.string :password
  end

  create_table :posts do |t|
    t.string :title
  end
end
