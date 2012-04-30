class LocalWorkflowsController < ApplicationController
  unloadable

  model_object Workflow
  before_filter :find_project_by_project_id
  before_filter :authorize
  before_filter :find_roles
  before_filter :find_trackers

  helper :project_roles

  def index
    @workflow_counts = Workflow.count_by_project_tracker_and_role(@project)
  end

  def edit
    @role = @project.child_roles.find_by_id(params[:role_id])
    @tracker = @project.trackers.find_by_id(params[:tracker_id])

    if request.post? && @role && @tracker
      Workflow.destroy_all(["role_id=? and tracker_id=?", @role.id, @tracker.id])
      #@role.workflows.find_by_tracker_id(@role.id).destroy_all
      (params[:issue_status] || []).each do |status_id, transitions|
        transitions.each do |new_status_id, options|
          author = options.is_a?(Array) && options.include?('author') && !options.include?('always')
          assignee = options.is_a?(Array) && options.include?('assignee') && !options.include?('always')
          @role.workflows.build(:tracker_id => @tracker.id, :old_status_id => status_id, :new_status_id => new_status_id, :author => author, :assignee => assignee)
        end
      end
      if @role.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'edit', :role_id => @role, :tracker_id => @tracker
        return
      end
    end

    @used_statuses_only = (params[:used_statuses_only] == '0' ? false : true)
    if @tracker && @used_statuses_only && @tracker.issue_statuses.any?
      @statuses = @tracker.issue_statuses
    end
    @statuses ||= IssueStatus.find(:all, :order => 'position')

    if @tracker && @role && @statuses.any?
      workflows = Workflow.all(:conditions => {:role_id => @role.id, :tracker_id => @tracker.id})
      @workflows = {}
      @workflows['always'] = workflows.select { |w| !w.author && !w.assignee }
      @workflows['author'] = workflows.select { |w| w.author }
      @workflows['assignee'] = workflows.select { |w| w.assignee }
    end
  end

  def copy

    begin
      if params[:source_tracker_id].blank? || params[:source_tracker_id] == 'any'
        @source_tracker = nil
      else
        @source_tracker = @project.trackers.find(params[:source_tracker_id])
      end

      if params[:source_role_id].blank? || params[:source_role_id] == 'any'
        @source_role = nil
      else
        @source_role = @project.child_roles.find(params[:source_role_id])
      end

      @target_trackers = nil
      @target_trackers = @project.trackers.find(params[:source_tracker_id]) unless params[:target_tracker_ids].blank?

      @target_roles = nil
      @target_roles = @project.child_roles.find_all_by_id(params[:target_role_ids]) unless params[:target_role_ids].blank?
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    if request.post?
      if params[:source_tracker_id].blank? || params[:source_role_id].blank? || (@source_tracker.nil? && @source_role.nil?)
        flash.now[:error] = l(:error_workflow_copy_source)
      elsif @target_trackers.nil? || @target_roles.nil?
        flash.now[:error] = l(:error_workflow_copy_target)
      else
        Workflow.copy(@source_tracker, @source_role, @target_trackers, @target_roles)
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'copy', :source_tracker_id => @source_tracker, :source_role_id => @source_role
      end
    end
  end

  private

  def find_roles
    @roles = @project.child_roles
  end

  def find_trackers
    @trackers = @project.trackers
  end
end
