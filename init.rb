require 'rit_client'
 
ActionController::Base.send :include, Rit::ControllerMethods
ApplicationHelper.send :include, Rit::ControllerMethods