# -*- encoding : utf-8 -*-
require File.expand_path('../../../../test_helper', __FILE__)

require_dependency 'principal'
class ProjectRolesPlugin::PrincipalPatchTest < ActiveSupport::TestCase
  fixtures :users, :members, :projects, :roles, :member_roles, :auth_sources

  def setup
    @admin = Principal.find(1)
    @jsmith = Principal.find(2)
    @dlopper = Principal.find(3)
    @rhill = Principal.find(4)
  end

  # Taken from UserTest
  context "#allowed_to?" do
    context "with a unique project" do
      should "return false if project is archived" do
        project = Project.find(1)
        Project.any_instance.stubs(:status).returns(Project::STATUS_ARCHIVED)
        assert !@admin.allowed_to?(:view_issues, Project.find(1))
      end

      should "return false if related module is disabled" do
        project = Project.find(1)
        project.enabled_module_names = ["issue_tracking"]
        assert @admin.allowed_to?(:add_issues, project)
        assert !@admin.allowed_to?(:view_wiki_pages, project)
      end

      should "authorize nearly everything for admin users" do
        project = Project.find(1)
        assert !@admin.member_of?(project)
        %w(edit_issues delete_issues manage_news manage_documents manage_wiki).each do |p|
          assert @admin.allowed_to?(p.to_sym, project)
        end
      end

      should "authorize normal users depending on their roles" do
        project = Project.find(1)
        assert @jsmith.allowed_to?(:delete_messages, project) #Manager
        assert !@dlopper.allowed_to?(:delete_messages, project) #Developper
      end
    end

    context "with multiple projects" do
      should "return false if array is empty" do
        assert !@admin.allowed_to?(:view_project, [])
      end

      should "return true only if user has permission on all these projects" do
        assert @admin.allowed_to?(:view_project, Project.all)
        assert !@dlopper.allowed_to?(:view_project, Project.all) #cannot see Project(2)
        assert @jsmith.allowed_to?(:edit_issues, @jsmith.projects) #Manager or Developer everywhere
        assert !@jsmith.allowed_to?(:delete_issue_watchers, @jsmith.projects) #Dev cannot delete_issue_watchers
      end

      should "behave correctly with arrays of 1 project" do
        assert !User.anonymous.allowed_to?(:delete_issues, [Project.first])
      end
    end

    context "with options[:global]" do
      should "authorize if user has at least one role that has this permission" do
        @dlopper2 = User.find(5) #only Developper on a project, not Manager anywhere
        @anonymous = User.find(6)
        assert @jsmith.allowed_to?(:delete_issue_watchers, nil, :global => true)
        assert !@dlopper2.allowed_to?(:delete_issue_watchers, nil, :global => true)
        assert @dlopper2.allowed_to?(:add_issues, nil, :global => true)
        assert !@anonymous.allowed_to?(:add_issues, nil, :global => true)
        assert @anonymous.allowed_to?(:view_issues, nil, :global => true)
      end
    end
  end

  context "ProjectRolesPlugin" do
    subject { Principal }

    context "#allowed_to?" do

      setup do
        @global_role = Role.find(1)
        @project = Project.find(1)
        @local_role = LocalRole.generate_for_project!(@project)
        @local_role.permissions = [:add_project, :view_issues, :add_issues]
        @local_role.save!

        @project.members << Member.new(:role_ids => [@local_role.id], :user_id => @rhill.id) # rhill has no memberships anywhere

      end

      should "not authorize global context" do
        assert !@rhill.allowed_to?(:add_project, nil, :global => true)
      end

    end


  end

end
