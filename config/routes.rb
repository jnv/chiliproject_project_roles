# -*- encoding : utf-8 -*-
ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :local_roles, :except => [:index] #, :member => { :add_users => :post}
  end

end
