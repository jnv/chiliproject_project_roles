# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

require_dependency 'role'
class RoleShiftTest < ActiveSupport::TestCase
  fixtures :projects, :roles

  should_belong_to :project
  should_belong_to :role
  should_validate_presence_of :project, :role
  should_have_readonly_attributes :project, :builtin

  should "create shift" do
    assert RoleShift.create!({:project => Project.find(1), :role => Role.find(1), :builtin => Role::BUILTIN_ANONYMOUS})
  end

  should "not create shift with invalid builtin" do
    shift = RoleShift.new({:project => Project.find(1), :role => Role.find(1), :builtin => 42})
    assert !shift.save
  end

end
