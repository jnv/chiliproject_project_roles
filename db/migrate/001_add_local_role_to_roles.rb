class AddLocalRoleToRoles < ActiveRecord::Migration
  def self.up
    change_table :roles do |t|
      t.string :type, :limit => 30, :default => "Role", :null => false
      t.integer :local_role_project_id
    end
    add_index :roles, [:id, :type]
    add_index :roles, :local_role_project_id

    #Role.update_all("type = 'Role'", "type = ''")
  end

  def self.down
    LocalRole.destroy_all
    change_table :roles do |t|
      t.remove_index :column => [:id, :type]
      t.remove_index :column => :local_role_project_id
      t.remove :local_role_project_id, :type # XXX Assumes there's no other plugin using STI
    end
  end
end
