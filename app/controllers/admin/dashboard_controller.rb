class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!, :is_admin?

  def home
    toast('success',"Welcome #{current_user.name}!")   
  end

end
