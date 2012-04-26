module LocalRolesHelper

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

end
