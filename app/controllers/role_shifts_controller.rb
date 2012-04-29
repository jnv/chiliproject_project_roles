class RoleShiftsController < ApplicationController
  unloadable
  model_object RoleShift
  before_filter :find_project_by_project_id
  before_filter :authorize
  #before_filter :find_model_object, :except => [:new, :create, :report]

  # POST project/:project_id/role_shifts
  def update
    if request.post? and params[:role_shifts]
      params[:role_shifts].each do |builtin, role_id|
        @role_shift = @project.role_shifts.find_or_initialize_by_builtin(builtin)
        if role_id.empty?
          @role_shift.destroy unless @role_shift.new_record?
          next
        end
        @role_shift.role = Role.find(role_id) #FIXME use @project.available_roles.find
        @role_shift.save
      end
    end
    redirect_to :back
  end
end
