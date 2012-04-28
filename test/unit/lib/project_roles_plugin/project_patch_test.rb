# -*- encoding : utf-8 -*-
require File.expand_path('../../../../test_helper', __FILE__)

require_dependency 'project'
class ProjectRolesPlugin::ProjectPatchTest < ActiveSupport::TestCase

  fixtures :all

  context "ProjectRolesPlugin" do
    subject { Project.new }

    should_have_many :child_roles, :dependent => :destroy
    #should_have_many :local_roles

    context "#local_roles" do

      # +-1
      #   `--3
      #    --4
      #    +-5
      #      `--6
      # --2
      setup do
        @root = Project.find 1
        @subproject = Project.find 6
        @root_role = LocalRole.generate_for_project!(@root)
      end

      should "include child roles" do
        assert_include(@root.local_roles, @root_role)
      end

      should "include ancestors' roles" do
        assert_include(@subproject.local_roles, @root_role)
      end

    end
  end

end
