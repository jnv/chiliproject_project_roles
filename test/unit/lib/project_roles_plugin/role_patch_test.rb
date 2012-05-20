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
      @project = Project.generate!
      @local_role = LocalRole.generate_for_project!(@project)
    end

    should "include all roles" do
      assert_include(Role.find(:all), @local_role)
    end

    context "#global_only" do
      should "include only global roles" do
        assert_include(Role.global_only.find(:all), @global_role)
      end

      should "not include local role in find :all" do
        assert_not_include(Role.global_only.find(:all), @local_role)
      end
    end

    context "name validations" do
      should_validate_presence_of :name
      should_validate_uniqueness_of :name, :scoped_to => "local_role_project_id", :case_sensitive => true

      should "disallow name longer than 30 chars" do
        role = Role.new({:name => "a"*40})
        assert !role.save
      end
    end

    context "validates_uniqueness_of name" do

      should "allow same name for Role and LocalRole" do
        local_role = LocalRole.generate_for_project!(Project.generate!, {:name => @global_role.name})
        assert local_role.save
      end

      should "allow same name for LocalRole from different projects" do
        local_role = LocalRole.generate_for_project!(Project.generate!, {:name => @local_role.name})
        assert local_role.save
      end

      should "disallow same name in the same project" do
        local_role = LocalRole.new({:parent_project => @project, :name => @local_role.name})
        assert !local_role.save
      end

      should "disallow same name for global roles" do
        role = Role.new({:name => @global_role.name})
        assert !role.save
      end

    end

  end

end
