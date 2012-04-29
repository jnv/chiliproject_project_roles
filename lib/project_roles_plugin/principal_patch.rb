# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module PrincipalPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :allowed_to?, :project_roles
        alias_method_chain :roles_for_project, :project_roles
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # Intercepts global authorization (options[:global])
      def allowed_to_with_project_roles?(action, context, options={})
        if options[:global]
          # Admin users are always authorized
          return true if admin?

          # authorize if user has at least one role that has this permission
          roles = memberships.collect { |m| m.roles }.flatten.uniq

          # global permissions won't ever apply to local roles
          roles.reject! { |r| r.is_a? LocalRole }

          return roles.detect { |r| r.allowed_to?(action) } || (self.logged? ? Role.non_member.allowed_to?(action) : Role.anonymous.allowed_to?(action))
        end

        allowed_to_without_project_roles?(action, context, options)
      end

      # Loads project-specific role shifts for anonymous and non-member users
      def roles_for_project_with_project_roles(project)
        if logged?
          @role_non_member = project.role_non_member || Role.non_member
        else
          @role_anonymous = project.role_anonymous || Role.anonymous
        end
        roles_for_project_without_project_roles(project)
      end

    end

  end
end