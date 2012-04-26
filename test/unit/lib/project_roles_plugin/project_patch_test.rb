# -*- encoding : utf-8 -*-
require File.expand_path('../../../../test_helper', __FILE__)

require_dependency 'project'
class ProjectRolesPlugin::ProjectPatchTest < ActiveSupport::TestCase

  #fixtures :all

  context "Project" do
    subject { Project.new }

    should_have_many :child_roles, :dependent => :destroy
    #should_have_many :local_roles
  end

end
