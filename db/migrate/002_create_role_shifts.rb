class CreateRoleShifts < ActiveRecord::Migration
  def self.up
    create_table :role_shifts do |t|
      t.integer :project_id, :null => false
      t.integer :role_id, :null => false
      t.integer :builtin, :default => 0, :null => false
    end
    add_index :role_shifts, [:project_id, :builtin], :unique => true
  end

  def self.down
    drop_table :role_shifts
  end
end
