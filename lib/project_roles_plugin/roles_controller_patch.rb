# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module RolesControllerPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        alias_method_chain :index, :project_roles
        alias_method_chain :report, :project_roles
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # XXX doesn't call original method
      def index_with_project_roles
        @role_pages, @roles = paginate :roles, :per_page => 25, :order => 'builtin, position', :conditions => {:type => 'Role'} # XXX duplicates global_only scope, will_paginate would work better
        render :action => "index", :layout => false if request.xhr?
      end

      # XXX doesn't call original method
      def report_with_project_roles
        @roles = Role.global_only.find(:all, :order => 'builtin, position')
        @permissions = Redmine::AccessControl.permissions.select { |p| !p.public? }
        if request.post?
          @roles.each do |role|
            role.permissions = params[:permissions][role.id.to_s]
            role.save
          end
          flash[:notice] = l(:notice_successful_update)
          redirect_to :action => 'index'
        end
      end

    end

  end
end
