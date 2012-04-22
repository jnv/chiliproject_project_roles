# -*- encoding : utf-8 -*-
class LocalRole < Role
  unloadable

  belongs_to :parent_project, :foreign_key => 'local_role_project_id', :class_name => 'Project', :readonly => true
  attr_readonly :parent_project
  validates_presence_of :parent_project

end
