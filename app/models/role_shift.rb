# -*- encoding : utf-8 -*-
class RoleShift < ActiveRecord::Base
  unloadable

  belongs_to :project, :readonly => true
  belongs_to :role#, :readonly => true

  validates_presence_of :project, :role
  validates_inclusion_of :builtin, :in => [Role::BUILTIN_ANONYMOUS, Role::BUILTIN_NON_MEMBER]
  validates_uniqueness_of :builtin, :scope => :project_id

  attr_readonly :project, :builtin

  def to_role
    orig = role
    replacement = orig.clone
    replacement.id = orig.id

    if builtin == Role::BUILTIN_ANONYMOUS
      replacement.permissions = orig.permissions - Redmine::AccessControl.loggedin_only_permissions.map(&:name)
    elsif builtin == Role::BUILTIN_NON_MEMBER
      replacement.permissions = orig.permissions - Redmine::AccessControl.members_only_permissions.map(&:name)
    else
      replacement.permissions = []
    end
    replacement
  end

end
