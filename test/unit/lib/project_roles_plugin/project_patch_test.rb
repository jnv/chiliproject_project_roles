# -*- encoding : utf-8 -*-
require File.expand_path('../../../../test_helper', __FILE__)

require_dependency 'project'
class ProjectRolesPlugin::ProjectPatchTest < ActiveSupport::TestCase

  fixtures :all

  context "ProjectRolesPlugin" do
    subject { Project.new }

    should_have_many :child_roles, :dependent => :destroy
    #should_have_many :local_roles
    should_have_many :role_shifts, :dependent => :destroy
    #should_have_one :role_non_member
    #should_have_one :role_anonymous

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

      should "return same result as mapping to child_roles" do
        reference = @root.self_and_ancestors.map(&:child_roles).flatten.uniq
        assert_same_elements reference, @root.local_roles

        reference = @subproject.self_and_ancestors.map(&:child_roles).flatten.uniq
        assert_same_elements reference, @subproject.local_roles
      end
    end

    context "#avaliable_roles" do
      setup do
        @root = Project.find 1
        @subproject = Project.find 6
        @root_role = LocalRole.generate_for_project!(@root)
        @subproject_role = LocalRole.generate_for_project!(@subproject)
      end

      subject { @subproject.available_roles }

      should "include both global and inherited roles" do
        reference = (Role.givable.global_only | @subproject.local_roles).map(&:id)
        assert_equal reference.size, subject.size
        assert_same_elements reference, subject.map(&:id)
      end

      should "find inherited local roles" do
        assert_not_nil subject.find(@root_role.id)
      end

      should "find own local roles" do
        assert_not_nil subject.find(@subproject_role.id)
      end
    end

    context "role shifts" do
      setup do
        @project = Project.find(2)

        @public_perms = Redmine::AccessControl.public_permissions.map(&:name)
        @logged_perms = Redmine::AccessControl.loggedin_only_permissions.map(&:name)
        @member_perms = Redmine::AccessControl.members_only_permissions.map(&:name)

        @local_role = LocalRole.generate_for_project!(@project)
        @local_role.permissions = @public_perms | @logged_perms | @member_perms
        @local_role.save!
        @anon = @project.role_shifts.create!({:role => @local_role, :builtin => Role::BUILTIN_ANONYMOUS}).role
        @nonm = @project.role_shifts.create!({:role => @local_role, :builtin => Role::BUILTIN_NON_MEMBER}).role
      end

      should "provide shifted roles" do
        assert_equal @project.role_anonymous.id, @anon.id
        assert_equal @project.role_non_member.id, @nonm.id
      end

      context "#role_anonymous" do
        should "not have logged-in only permissions" do
          @logged_perms.each do |permission|
            assert_not_include @project.role_anonymous.permissions, permission
          end
        end
      end

      context "#role_non_member" do
        subject { @project.role_anonymous }

        should "have permissions" do
          assert_not_empty subject.permissions
        end

        should "not have logged-in only permissions" do
          @member_perms.each do |permission|
            assert_not_include subject.permissions, permission
          end
        end
      end


    end
  end

end
