# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module WorkflowPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

      end
    end

    module ClassMethods
      def count_by_project_tracker_and_role(project)
        counts = connection.select_all("SELECT role_id, tracker_id, count(id) AS c FROM #{Workflow.table_name} GROUP BY role_id, tracker_id")
        roles = project.child_roles
        trackers = project.trackers

        result = []
        trackers.each do |tracker|
          t = []
          roles.each do |role|
            row = counts.detect { |c| c['role_id'].to_s == role.id.to_s && c['tracker_id'].to_s == tracker.id.to_s }
            t << [role, (row.nil? ? 0 : row['c'].to_i)]
          end
          result << [tracker, t]
        end

        result
      end
    end

    module InstanceMethods

    end
  end
end