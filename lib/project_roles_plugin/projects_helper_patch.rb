# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module ProjectsHelperPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :project_settings_tabs, :project_roles
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def project_settings_tabs_with_project_roles
        tabs = project_settings_tabs_without_project_roles
        if User.current.allowed_to?(:manage_project_roles, @project)
          tabs.push({:name => 'project_roles',
                     :action => :manage_project_roles,
                     :partial => 'projects/settings/project_roles',
                     :label => :label_role_plural})
        end
        tabs
      end
    end

  end
end
