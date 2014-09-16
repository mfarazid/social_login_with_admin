class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def toast(type, text)   
    flash[:toastr] = { type => text }
  end

  private 
  
    def is_admin?
      if current_user.email != ENV['ADMIN_EMAIL']
        toast('error',"You're not authorized to access administration!")
        redirect_to root_path and return
      end
    end 
    
  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << [:email, :name]
    end
end
