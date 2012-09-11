# -*- encoding : utf-8 -*-
require File.expand_path('../../../../test_helper', __FILE__)
class ProjectRolesPlugin::MembersViewHelperPatchTest < ActiveSupport::TestCase

  fixtures :users, :projects, :members, :roles, :member_roles

  include MembersViewHelper

  def setup
    @project = Project.find(1)
    @global_role = Role.find(1)
    @project_role = LocalRole.generate_for_project!(@project)
  end

  context "#load_roles" do

    subject { load_roles(@project) }

    should "include project and global roles" do
      assert_include subject, @project_role
      assert_include subject, @global_role
    end

  end


end
