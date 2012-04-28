# -*- encoding : utf-8 -*-
module ProjectRolesPlugin

  module MembersControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        before_filter :check_local_roles, :only => [:new, :edit]
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # Prevents creating member with role out of
      # local_roles hierarchy
      def check_local_roles
        role_ids = params[:member][:role_ids]
        roles = LocalRole.find(:all, :conditions => {:id => role_ids})
        local_roles = @project.local_roles
        roles.each do |role|
          unless local_roles.include?(role)
            deny_access
            break
          end
        end
      end
    end

  end
end