# -*- encoding : utf-8 -*-
ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :local_roles, :except => [:index], :collection => {:report => [:get, :post]}
    project.role_shifts 'role_shifts', :controller => :role_shifts, :action => :update, :conditions => {:method => :post}

    project.resources :local_workflows, :only => :index, :collection => {:copy => [:get, :post]}
    project.connect 'local_workflows/edit', :controller => :local_workflows, :action => :edit, :conditions => {:method => [:get, :post]}
  end

end
