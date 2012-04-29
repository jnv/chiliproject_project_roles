class LocalRolesController < ApplicationController
  unloadable

  include LocalRolesHelper

  model_object LocalRole
  before_filter :find_project_by_project_id
  before_filter :authorize
  before_filter :find_model_object, :except => [:new, :create, :report]
  before_filter :authorize_manageable, :except => [:new, :create, :show, :report]

  before_filter :load_workflow_local_roles, :only => [:new]

  # GET projects/:project_id/local_roles/show
  def show

  end

  # GET projects/:project_id/local_roles/new
  def new
    # Prefills the form with 'Non member' role permissions
    @local_role = LocalRole.new({:parent_project => @project, :permissions => Role.non_member.permissions})
    @permissions = @local_role.setable_permissions
  end

  # POST projects/:project_id/local_roles
  def create
    @local_role = LocalRole.new(params[:local_role])
    @local_role.parent_project = @project
    if @local_role.save
      # workflow copy
      if !params[:copy_workflow_from].blank? && (copy_from = Role.find_by_id(params[:copy_workflow_from]))
        @local_role.workflows.copy(copy_from)
      end
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_settings_path(@project)
    else
      @permissions = @local_role.setable_permissions
      load_workflow_local_roles
      render :action => 'new'
    end
  end

  # GET projects/:project_id/local_roles/:id/edit
  def edit
    @permissions = @local_role.setable_permissions
  end

  # PUT projects/:project_id/local_roles/:id
  def update
    if @local_role.update_attributes(params[:local_role])
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_settings_path(@project)
    else
      @permissions = @local_role.setable_permissions
    end
  end

  # DELETE projects/:project_id/local_roles/:id
  def destroy
    @local_role.destroy
  rescue
    flash[:error] = l(:error_can_not_remove_role)
  ensure
    redirect_to project_settings_path(@project)
  end

  # GET projects/:project_id/local_roles/report
  # POST projects/:project_id/local_roles/report
  def report
    @local_roles = @project.child_roles
    @permissions = Redmine::AccessControl.permissions.select { |p| !p.public? }
    if request.post?
      @local_roles.each do |role|
        role.permissions = params[:permissions][role.id.to_s]
        role.save
      end
      flash[:notice] = l(:notice_successful_update)
      redirect_to report_project_local_roles_path(@project)
    end
  end

  private
  def authorize_manageable
    unless @local_role.child_role_of?(@project)
      deny_access
    end
    true
  end

  def load_workflow_local_roles
    @local_roles = Role.available_for_project(@project).find(:all, :order => 'builtin, position') # XXX includes builtin
  end
end
