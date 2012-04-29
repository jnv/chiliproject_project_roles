# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module ProjectPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        has_many :child_roles, :foreign_key => 'local_role_project_id', :class_name => 'LocalRole', :dependent => :destroy

        has_many :role_shifts, :dependent => :destroy
        #has_one :role_non_member, :through => :role_shifts, :conditions => ['role_shifts.builtin = ?', Role::BUILTIN_NON_MEMBER], :source => :role
        #has_one :role_anonymous, :through => :role_shifts, :conditions => ['role_shifts.builtin = ?', Role::BUILTIN_ANONYMOUS], :source => :role
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def local_roles
        self_and_ancestors.map(&:child_roles).flatten.uniq #FIXME this should be refactored to something effective
      end

      def role_anonymous
        role_shifts.find_by_builtin(Role::BUILTIN_ANONYMOUS).try(:to_role)
      end

      def role_non_member
        role_shifts.find_by_builtin(Role::BUILTIN_NON_MEMBER).try(:to_role)
      end

    end

  end
end
