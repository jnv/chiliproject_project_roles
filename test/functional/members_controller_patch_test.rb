# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

# Reuse the default test
require File.expand_path('test/functional/members_controller_test', RAILS_ROOT)

class MembersControllerPatchTest < MembersControllerTest
  fixtures :projects, :members, :member_roles, :roles, :users


  context "ProjectRolesPlugin" do
    setup do
      #@request.session[:user_id] = 2 # manager
      @role = LocalRole.generate_for_project!(Project.find(1))
    end

    context "POST new" do
      should "add new member" do
        assert_difference 'Member.count' do
          post :new, :id => 1, :member => {:role_ids => [@role.id], :user_id => 7}
        end
        assert_redirected_to '/projects/ecookbook/settings/members'
        assert User.find(7).member_of?(Project.find(1))
      end

      should "not add member if role is not available in the project" do
        root_project = Project.find(2)
        assert !root_project.is_descendant_of?(Project.find(1))
        assert_not_include root_project.local_roles, @role
        assert_no_difference 'Member.count' do
          post :new, :id => root_project.id, :member => {:role_ids => [@role.id], :user_id => 7}
        end
      end

      should "respond successfuly to AJAX request" do
        assert_difference 'Member.count' do
          post :new, :format => 'js', :id => 1, :member => {:role_ids => [@role.id], :user_id => 7}
        end
        assert_response :success
        assert_match 'Effect.Highlight', @response.body
      end
    end


  end


end
