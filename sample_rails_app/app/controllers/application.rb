# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '4f709dba7dc7d86578de3d5761895bbe'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter :simulate_bad_network_connection
  
  def simulate_bad_network_connection
    if request.format.xml?
      sleep 2
      
      render :text => "Simulated Failure!", :status => 575 if rand(10000) < 1500
    end
  end
end
