# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

# Reuse the default test
require File.expand_path('test/functional/roles_controller_test', RAILS_ROOT)

class RolesControllerPatchTest < RolesControllerTest

  fixtures :roles, :users, :members, :member_roles, :workflows, :trackers

  context "ProjectRolesPlugin" do
    setup do
      @project = Project.find(1)
      @global_role = Role.find(1)
      @local_role = LocalRole.generate_for_project! @project
    end

    context "GET index" do
      setup do
        get :index
      end

      should_respond_with :success

      should "not include local roles" do
        assert_include assigns(:roles), @global_role
        assert_not_include assigns(:roles), @local_role
      end
    end


  end


end
