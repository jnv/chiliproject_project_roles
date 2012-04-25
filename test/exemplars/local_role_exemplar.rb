#-- encoding: UTF-8
require_dependency 'local_role'
class LocalRole < Role
  generator_for :name, :start => 'LocalRole0'
end

def LocalRole.generate_for_project!(project, attributes={})
  LocalRole.generate! attributes.merge({:parent_project => project})
end