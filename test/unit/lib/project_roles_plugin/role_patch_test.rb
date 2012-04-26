# -*- encoding : utf-8 -*-
require File.expand_path('../../../../test_helper', __FILE__)

require_dependency 'role'
class ProjectRolesPlugin::RolePatchTest < ActiveSupport::TestCase
  fixtures :roles, :workflows
  #fixtures :all

  context "Role" do
    subject { Role.new }

    setup do
      @global_role = Role.find(1)
      @local_role = LocalRole.generate_for_project!(Project.generate!)
    end

    should "not include local role in find :all" do
      assert_include(Role.find(:all), @global_role)
      assert_not_include(Role.find(:all), @local_role)
    end



  end

end
