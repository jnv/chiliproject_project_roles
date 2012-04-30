# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module WorkflowsControllerPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        alias_method_chain :find_roles, :project_roles
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # XXX breaks chain (you really should just scope it)
      def find_roles_with_project_roles
        #find_roles_without_project_roles
        @roles = Role.global_only.find(:all, :order => 'builtin, position')
      end


    end

  end
end
