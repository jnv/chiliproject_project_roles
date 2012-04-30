module ProjectRolesHelper
  # Generate link to a given project's settings
  # @param project [Project]
  # @param label [Symbol]
  # @param tab [String]
  def link_to_project_settings(project, label = :label_settings, tab = "project_roles")
    link_to l(:label_settings), project_settings_path(project)
  end

  def project_settings_path(project, tab='project_roles')
    url_for :controller => 'projects', :action => 'settings', :id => project, :tab => tab
  end

  def nested_settings_header(project, tab, segment, tail)
    str = link_to_project_settings(@project, :label_settings, tab) + " &#187; "
    str += l(segment) + " &#187; "
    if tail.is_a? Symbol
      str += l(tail)
    else
      str+= h(tail)
    end
    str
  end
end