# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class LocalRolesControllerTest < ActionController::TestCase

  fixtures :projects, :versions, :users, :roles, :members, :member_roles

  def setup
    @controller = LocalRolesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    Setting.default_language = 'en'

    Role.find(1).add_permission! :manage_project_roles
    #User.current = nil
    @request.session[:user_id] = 2 # manager, member of Project 1

    @project = Project.find(1)
    @subproject = Project.find(5) # subproject of Project 1, User 2 is manager
    @role = LocalRole.generate_for_project!(@project)
    @role.permissions = [:edit_project]
    @role.save!
  end

  context "GET show" do
    setup do
      get :show, :project_id => @project, :id => @role
    end

    should "include permission" do
      assert @role.has_permission?(:edit_project)
    end

    should_respond_with :success
    should_render_template :show
    should_assign_to(:local_role) { @role }
  end

  context "GET new" do
    setup do
      get :new, :project_id => @project
    end

    should_render_template :new
    should_assign_to :local_role, :class => LocalRole
  end

  context "GET edit" do
    setup do
      get :edit, :project_id => @project, :id => @role
    end

    should_render_template :edit
    should_assign_to(:local_role) { @role }
    should_assign_to :permissions
  end

  context "PUT update" do
    setup do
      put :update, :project_id => @project, :id => @role, :local_role => {:name => 'Local Manager',
                                                                          :permissions => ['edit_project', ''],
                                                                          :assignable => '0'}
    end

    should "update role's properties" do
      @role.reload
      assert_equal @role.name, 'Local Manager'
      assert_equal [:edit_project], @role.permissions
    end
  end

  context "POST create" do
    should "create new role without workflow copy" do
      assert_difference 'LocalRole.count', 1 do
        post :create, :project_id => @project, :local_role => {:name => 'LocalRoleWithoutWorkflowCopy',
                                                               :permissions => ['add_issues', 'edit_issues', 'log_time', ''],
                                                               :assignable => '0'}
      end
      #assert_redirected_to ''
      role = LocalRole.find_by_name('LocalRoleWithoutWorkflowCopy')
      assert_not_nil role
      assert_equal [:add_issues, :edit_issues, :log_time], role.permissions
      assert !role.assignable?
    end

    should_eventually "create new role with workflow copy" do
      assert_difference 'LocalRole.count', 1 do
        post :new, :role => {:name => 'LocalRoleWithWorkflowCopy',
                             :permissions => ['add_issues', 'edit_issues', 'log_time', ''],
                             :assignable => '0'},
             :copy_workflow_from => '1'
      end

      role = Role.find_by_name('LocalRoleWithWorkflowCopy')
      assert_not_nil role
      assert_equal Role.find(1).workflows.size, role.workflows.size
    end
  end

  context "DELETE destroy" do
    should "remove role" do
      assert_difference 'LocalRole.count', -1 do
        post :destroy, :project_id => @project, :id => @role
      end
    end

    should "not remove role in use" do
      MemberRole.generate!(:role => @role)
      assert_difference 'LocalRole.count', 0 do
        post :destroy, :project_id => @project, :id => @role
      end
      assert flash[:error] == 'This role is in use and cannot be deleted.'
    end
  end

  context "GET report" do
    setup do
      get :report, :project_id => @project
    end
    should_assign_to :permissions
    should_respond_with :success
    should_render_template :report
  end

  context "POST report" do
    setup do
      post :report, :project_id => @project, :permissions => {@role.id.to_s => ['add_issues', 'delete_issues']}
    end

    should "add permissions" do
      assert_equal [:add_issues, :delete_issues], @role.reload.permissions
    end
  end

  context "#authorize_manageable" do
    # Role should be manageable only in parent project

    {:edit => :get, :update => :put, :destroy => :delete}.each do |action, verb|
      context "#{verb.to_s.upcase} #{action}" do
        setup do
          self.send verb, action, :project_id => @subproject, :id => @role
        end
        should_respond_with 403 # access denied
      end
    end

    {:show => :get, :new => :get, :create => :post, :report => :get}.each do |action, verb|
      context "#{verb.to_s.upcase} #{action}" do
        setup do
          self.send verb, action, :project_id => @subproject, :id => @role
        end
        should "respond with #{:success}" do
          matcher = respond_with(:success)
          assert_accepts matcher, @controller
        end
      end
    end
  end

end
