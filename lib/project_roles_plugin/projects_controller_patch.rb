# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module ProjectsControllerPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        before_filter :load_local_roles, :only => :settings
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def load_local_roles
        @local_roles = @project.child_roles # FIXME
      end
    end

  end
end
