# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module ProjectPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        has_many :child_roles, :foreign_key => 'local_role_project_id', :class_name => 'LocalRole', :dependent => :destroy
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def local_roles
        self_and_ancestors.map(&:child_roles).flatten.uniq #FIXME this should be refactored to something effective
      end
    end

  end
end
