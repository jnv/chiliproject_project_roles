# -*- encoding : utf-8 -*-
class RoleShift < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :role

  validates_presence_of :project, :role
  validates_inclusion_of :builtin, :in => [Role::BUILTIN_ANONYMOUS, Role::BUILTIN_NON_MEMBER]

end
