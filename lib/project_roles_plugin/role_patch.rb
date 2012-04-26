# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module RolePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        # XXX ugly but effective
        # Kudos to Jeff Paquette http://stackoverflow.com/a/1861486/240963
        unless File.basename($0) == "rake" && ARGV.include?("db:migrate")
          default_scope :conditions => "type != 'LocalRole'"
        end
      end
    end

    module ClassMethods
    end

    module InstanceMethods

    end
  end
end