# -*- encoding : utf-8 -*-
ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :local_roles, :except => [:index], :collection => {:report => [:get, :post]}
    project.role_shifts 'role_shifts', :controller => :role_shifts, :action => :update, :conditions => {:method => :post}
  end

end
