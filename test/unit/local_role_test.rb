# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

require_dependency 'role'
class LocalRoleTest < ActiveSupport::TestCase
  fixtures :projects, :roles

  should_belong_to :parent_project
  should_validate_presence_of :parent_project
  should_have_readonly_attributes :parent_project

  # Tests the removal of Role's default_scope
  should "include local roles in LocalRole object" do
    local_role = LocalRole.generate_for_project!(Project.find(1))
    assert_include(LocalRole.find(:all), local_role)
  end

end
