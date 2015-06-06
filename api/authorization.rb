require 'sinatra'
require 'rack'

module Sinatra
  module Authorization

    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def unauthorized!(realm="Logrado")
      #headers 'WWW-Authenticate' => %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end

    def authorized?
      puts session.inspect
      user = User.get(session[:user_id])
      if not user.nil?
        session[:program_id] = user.program.id
        return true
      end
      return false
    end

    def authorize(email, password)
      user = User.authenticate(email, password)
      if user
        return true
      else
        return false
      end
    end

    def current_user
      User.first(:email => session[:user_email])
    end

    def require_authentication
      return if authorized?
      unauthorized! unless auth.provided?
      unauthorized! unless authorize(*auth.credentials)

      # session[:user_email] = auth.username
    end

    # def admin?
    #   authorized?
    # end
  end
end

