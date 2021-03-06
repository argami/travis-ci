class ApplicationController < ActionController::Base

  require 'http_accept_language'

  prepend_view_path 'app/views/v1/default'

  protect_from_forgery

  before_filter :set_gitsha_header
  before_filter :prepare_for_mobile
  before_filter :set_locale
  after_filter  :prepare_unobtrusive_flash



  protected

    def set_locale
      I18n.locale = if params[:hl] && I18n.available_locales.include?(params[:hl].to_sym)
                 params[:hl].to_sym
               else
                 request.preferred_language_from(I18n.available_locales) || :en
               end
    end

    def repositories
      @repositories ||= Repository.timeline
    end
    helper_method :repositories

    def set_gitsha_header
      headers['X-GIT_SHA'] = ENV['GIT_SHA'] if ENV['GIT_SHA']
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    def mobile_device?
      if session[:mobile_param]
        session[:mobile_param] == '1'
      else
        request.user_agent =~ /Mobile|webOS/
      end
    end
    helper_method :mobile_device?

    def prepare_for_mobile
      session[:mobile_param] = params[:mobile] if params[:mobile]
    end


end
