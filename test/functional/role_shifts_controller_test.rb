# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class RoleShiftsControllerTest < ActionController::TestCase

  fixtures :all

  def setup
    @controller = RoleShiftsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.env["HTTP_REFERER"] = 'back'
    Setting.default_language = 'en'

    Role.find(1).add_permission! :manage_role_shifts
    #User.current = nil
    @request.session[:user_id] = 2 # manager, member of Project 1

    @project = Project.find(1)
    @subproject = Project.find(5) # subproject of Project 1, User 2 is manager
    @role = LocalRole.generate_for_project!(@project)
    @role.permissions = [:edit_project]
    @role.save!

    @role_shift = @project.role_shifts.create!(:role => @role, :builtin => 1)
  end

  context "POST update" do
    setup do
      @params = {:project_id => @project, :role_shifts => {2 => @role.id}} # builtin = 2
    end

    should "create new shift" do
      assert_difference 'RoleShift.count' do
        post :update, @params
      end
      assert_redirected_to 'back'
    end

    should "update shift" do
      assert_equal @role.id, @role_shift.role_id
      @params[:role_shifts] = {1 => 1}
      assert_no_difference 'RoleShift.count' do
        post :update, @params
      end
      assert_redirected_to 'back'
      assert_equal 1, @role_shift.reload.role_id
    end

    should "remove shift" do
      @params[:role_shifts] = {1 => '', 2 => ''}
      assert_difference 'RoleShift.count', -1 do
        post :update, @params
      end
      assert_redirected_to 'back'
      assert_empty @project.reload.role_shifts
    end

  end

end
