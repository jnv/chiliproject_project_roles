# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class LocalWorkflowsControllerTest < ActionController::TestCase
  fixtures :roles, :trackers, :workflows, :users, :issue_statuses

  def setup
    @controller = LocalWorkflowsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    User.current = nil
    Setting.default_language = 'en'
    Role.find(1).add_permission! :manage_local_workflows
    @request.session[:user_id] = 2 # manager

    @project = Project.find(1)
    @subproject = Project.find(5) # subproject of Project 1, User 2 is manager
    @role = LocalRole.generate_for_project!(@project)
    @tracker = Tracker.first
    @workflow = @role.workflows.create!(:tracker_id => @tracker.id, :old_status_id => 1, :new_status_id => 2)
  end

  context "GET index" do
    setup do
      get :index, :project_id => @project
    end

    should_respond_with :success
    should_render_template :index

    should "render link to edit" do
      count = Workflow.count(:all, :conditions => ['role_id = ? AND tracker_id = ?', @role.id, @tracker.id])
      assert_tag :tag => 'a', :content => count.to_s,
                 :attributes => {:href => /edit\?role_id=#{@role.id}&amp\;tracker_id=#{@tracker.id}/}
    end

  end

  context "GET edit" do
    context "whithout params" do
      setup do
        get :edit, :project_id => @project
      end
      should_respond_with :success
      should_render_template :edit
      should_assign_to(:roles){ [@role] }
      should_assign_to :trackers
    end
  end

  def test_get_edit_with_role_and_tracker
    Workflow.delete_all
    Workflow.create!(:role_id => 1, :tracker_id => 1, :old_status_id => 2, :new_status_id => 3)
    Workflow.create!(:role_id => 2, :tracker_id => 1, :old_status_id => 3, :new_status_id => 5)

    get :edit, :role_id => 2, :tracker_id => 1
    assert_response :success
    assert_template 'edit'

    # used status only
    assert_not_nil assigns(:statuses)
    assert_equal [2, 3, 5], assigns(:statuses).collect(&:id)

    # allowed transitions
    assert_tag :tag => 'input', :attributes => {:type => 'checkbox',
                                                :name => 'issue_status[3][5][]',
                                                :value => 'always',
                                                :checked => 'checked'}
    # not allowed
    assert_tag :tag => 'input', :attributes => {:type => 'checkbox',
                                                :name => 'issue_status[3][2][]',
                                                :value => 'always',
                                                :checked => nil}
    # unused
    assert_no_tag :tag => 'input', :attributes => {:type => 'checkbox',
                                                   :name => 'issue_status[1][1][]'}
  end

  def test_get_edit_with_role_and_tracker_and_all_statuses
    Workflow.delete_all

    get :edit, :role_id => 2, :tracker_id => 1, :used_statuses_only => '0'
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:statuses)
    assert_equal IssueStatus.count, assigns(:statuses).size

    assert_tag :tag => 'input', :attributes => {:type => 'checkbox',
                                                :name => 'issue_status[1][1][]',
                                                :value => 'always',
                                                :checked => nil}
  end

  def test_post_edit
    post :edit, :role_id => 2, :tracker_id => 1,
         :issue_status => {
             '4' => {'5' => ['always']},
             '3' => {'1' => ['always'], '2' => ['always']}
         }
    assert_redirected_to '/workflows/edit?role_id=2&tracker_id=1'

    assert_equal 3, Workflow.count(:conditions => {:tracker_id => 1, :role_id => 2})
    assert_not_nil Workflow.find(:first, :conditions => {:role_id => 2, :tracker_id => 1, :old_status_id => 3, :new_status_id => 2})
    assert_nil Workflow.find(:first, :conditions => {:role_id => 2, :tracker_id => 1, :old_status_id => 5, :new_status_id => 4})
  end

  def test_post_edit_with_additional_transitions
    post :edit, :role_id => 2, :tracker_id => 1,
         :issue_status => {
             '4' => {'5' => ['always']},
             '3' => {'1' => ['author'], '2' => ['assignee'], '4' => ['author', 'assignee']}
         }
    assert_redirected_to '/workflows/edit?role_id=2&tracker_id=1'

    assert_equal 4, Workflow.count(:conditions => {:tracker_id => 1, :role_id => 2})

    w = Workflow.find(:first, :conditions => {:role_id => 2, :tracker_id => 1, :old_status_id => 4, :new_status_id => 5})
    assert !w.author
    assert !w.assignee
    w = Workflow.find(:first, :conditions => {:role_id => 2, :tracker_id => 1, :old_status_id => 3, :new_status_id => 1})
    assert w.author
    assert !w.assignee
    w = Workflow.find(:first, :conditions => {:role_id => 2, :tracker_id => 1, :old_status_id => 3, :new_status_id => 2})
    assert !w.author
    assert w.assignee
    w = Workflow.find(:first, :conditions => {:role_id => 2, :tracker_id => 1, :old_status_id => 3, :new_status_id => 4})
    assert w.author
    assert w.assignee
  end

  def test_clear_workflow
    assert Workflow.count(:conditions => {:tracker_id => 1, :role_id => 2}) > 0

    post :edit, :role_id => 2, :tracker_id => 1
    assert_equal 0, Workflow.count(:conditions => {:tracker_id => 1, :role_id => 2})
  end

  def test_get_copy
    get :copy
    assert_response :success
    assert_template 'copy'
  end

  def test_post_copy_one_to_one
    source_transitions = status_transitions(:tracker_id => 1, :role_id => 2)

    post :copy, :source_tracker_id => '1', :source_role_id => '2',
         :target_tracker_ids => ['3'], :target_role_ids => ['1']
    assert_response 302
    assert_equal source_transitions, status_transitions(:tracker_id => 3, :role_id => 1)
  end

  def test_post_copy_one_to_many
    source_transitions = status_transitions(:tracker_id => 1, :role_id => 2)

    post :copy, :source_tracker_id => '1', :source_role_id => '2',
         :target_tracker_ids => ['2', '3'], :target_role_ids => ['1', '3']
    assert_response 302
    assert_equal source_transitions, status_transitions(:tracker_id => 2, :role_id => 1)
    assert_equal source_transitions, status_transitions(:tracker_id => 3, :role_id => 1)
    assert_equal source_transitions, status_transitions(:tracker_id => 2, :role_id => 3)
    assert_equal source_transitions, status_transitions(:tracker_id => 3, :role_id => 3)
  end

  def test_post_copy_many_to_many
    source_t2 = status_transitions(:tracker_id => 2, :role_id => 2)
    source_t3 = status_transitions(:tracker_id => 3, :role_id => 2)

    post :copy, :source_tracker_id => 'any', :source_role_id => '2',
         :target_tracker_ids => ['2', '3'], :target_role_ids => ['1', '3']
    assert_response 302
    assert_equal source_t2, status_transitions(:tracker_id => 2, :role_id => 1)
    assert_equal source_t3, status_transitions(:tracker_id => 3, :role_id => 1)
    assert_equal source_t2, status_transitions(:tracker_id => 2, :role_id => 3)
    assert_equal source_t3, status_transitions(:tracker_id => 3, :role_id => 3)
  end

  # Returns an array of status transitions that can be compared
  def status_transitions(conditions)
    Workflow.find(:all, :conditions => conditions,
                  :order => 'tracker_id, role_id, old_status_id, new_status_id').collect { |w| [w.old_status, w.new_status_id] }
  end
end
