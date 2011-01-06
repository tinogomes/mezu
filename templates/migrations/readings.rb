class CreateMezuReadings < ActiveRecord::Migration
  def self.up
    create_table :mezu_readings do |t|
      t.references :message, :null => false
      t.references :related, :polymorphic => true, :null => false
      t.timestamps
    end

    add_index :mezu_readings, :message_id
  end

  def self.down
    drop_table :mezu_readings
  end
end
