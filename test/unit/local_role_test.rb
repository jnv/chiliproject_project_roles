# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

require_dependency 'role'
class LocalRoleTest < ActiveSupport::TestCase
  fixtures :projects, :roles
  
  should_belong_to :parent_project
  should_validate_presence_of :parent_project
  should_have_readonly_attributes :parent_project

end
