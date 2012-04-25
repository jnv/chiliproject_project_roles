# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

# Reuse the default test
require File.expand_path('test/functional/projects_controller_test', RAILS_ROOT)

class ProjectsControllerTest < ActionController::TestCase

  fixtures :all

  #subject { ProjectsController }

  context "ProjectRolesPlugin" do
    setup do
      @project = Project.find(1)
      @request.session[:user_id] = 2 # manager
    end

    context "GET settings" do
      setup do
        LocalRole.generate_for_project! @project
        get :settings, :id => @project
      end

      should_respond_with :success
      should_render_template :settings
      should_assign_to :local_roles
    end


  end


end
