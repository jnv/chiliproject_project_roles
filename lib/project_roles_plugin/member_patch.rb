# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module MemberPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        validate :validate_local_roles
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # Prevents creating member with role out of
      # local_roles hierarchy
      def validate_local_roles
        #local_roles = roles
        local_roles = member_roles.collect do |mr|
          mr.role.id if mr.role.is_a? LocalRole
        end
        local_roles.compact!

        return true if local_roles.empty?

        project_roles = project.local_roles.collect(&:id)
        local_roles.each do |role|
          unless project_roles.include?(role)
            errors.add("roles", "contain role which is not available in this project")
            break
          end
        end
      end
    end

  end
end