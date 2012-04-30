# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

# Reuse the default test
require File.expand_path('test/functional/workflows_controller_test', RAILS_ROOT)

class WorkflowsControllerTest < ActionController::TestCase

  fixtures :roles, :trackers, :workflows, :users, :issue_statuses

  context "ProjectRolesPlugin" do
    setup do
      @local_role = LocalRole.generate_for_project!(Project.find(1))
    end

    context "#find_roles" do
      setup do
        get :edit
      end

      subject { assigns(:roles) }

      should_assign_to :roles

      should "not assign local role" do
        assert_not_include subject, @local_role
      end

    end


  end


end
