# -*- encoding : utf-8 -*-
class LocalRole < Role
  unloadable

  belongs_to :parent_project, :foreign_key => 'local_role_project_id', :class_name => 'Project', :readonly => true
  attr_readonly :parent_project
  validates_presence_of :parent_project

  named_scope :available_for_project, lambda { |project|
    {
        :include => :parent_project,
        :conditions => ["projects.lft <= ? AND projects.rgt >= ?", project.left, project.right]
    }
  }

  def child_role_of?(project)
    project_id = project.is_a?(Project) ? project.id : project.to_i
    project_id == parent_project.id
  end

end
