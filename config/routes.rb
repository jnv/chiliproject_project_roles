# -*- encoding : utf-8 -*-
ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :local_roles, :except => [:index] , :collection => { :report => [:get, :post]}
  end

end
