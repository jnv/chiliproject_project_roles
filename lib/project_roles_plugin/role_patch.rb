# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module RolePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        default_scope :conditions => "type != 'LocalRole'"
      end
    end

    module ClassMethods
    end

    module InstanceMethods

    end
  end
end