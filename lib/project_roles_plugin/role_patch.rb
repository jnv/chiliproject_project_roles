# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module RolePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        named_scope :global_only, :conditions => {:type => 'Role'}

        named_scope :available_for_project, lambda { |project|
          {
              :joins => "LEFT OUTER JOIN projects ON roles.local_role_project_id = projects.id",
              :conditions => ["roles.type = 'Role' OR (roles.type = 'LocalRole' AND projects.lft <= ? AND projects.rgt >= ?)", project.left, project.right]
          }
        }

        # Kudos to Lawrence McAlpin
        # http://www.lmcalpin.com/post/5219540409/overriding-rails-validations-metaprogramatically
        @validate_callbacks.reject! do |c|
          begin
            if Proc === c.method && eval("attrs", c.method.binding).first == :name && c.options.has_key?(:case_sensitive)
              true
            end
          rescue
            false
          end
        end
        validates_uniqueness_of :name, :case_sensitive => false, :scope => :local_role_project_id
      end
    end

    module ClassMethods
    end

    module InstanceMethods

    end
  end
end