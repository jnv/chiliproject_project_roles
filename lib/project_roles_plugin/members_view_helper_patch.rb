# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module MembersViewHelperPatch

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        #extend InstanceMethods
        alias_method_chain :load_roles, :project_roles
      end
    end

    module InstanceMethods

      def load_roles_with_project_roles(project)
        #XXX could be handled by Project#available_roles but that would break the chain
        roles = load_roles_without_project_roles(project)
        project.local_roles + roles
      end
    end

  end
end
