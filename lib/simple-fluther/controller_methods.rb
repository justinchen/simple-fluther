require 'em-http-request'

module SimpleFluther
  module ControllerMethods
    def make_fluther_request
      setup_fluther_user
      return exec_request
    end
    
    def setup_fluther_user
      @fluther_user = {}
      if user = self.send(SimpleFluther::Config.method_to_get_current_user) rescue nil
        SimpleFluther::Config.user_fields.each { |dest, src|  @fluther_user[dest] = user.send(src).to_s }
      end  
    end
    
    def build_request
      fluther_params = request.params.dup.update(
        :fed_key => SimpleFluther::Config.app_key
      )
      fluther_params[:fed_sessionid] = request.cookies['fed_sessionid']  if request.cookies['fed_sessionid']
      if @fluther_user.present?
        fluther_params[:fed_uid] = @fluther_user[:id].to_s
        fluther_params[:fed_username] = @fluther_user[:name].to_s
        fluther_params[:fed_email] = @fluther_user[:email].to_s
      end

      options = {
        :redirects => 0,
        :timeout => 10,
        :head => {
          'User-Agent' => "Fluther Federated Client #{SimpleFluther::ClientVersion} (Ruby)",
          'X-Forwarded-For' => request.env['REMOTE_ADDR'],
          'X-Forwarded-Host' => request.env['HTTP_HOST'],
          'X-Forwarded-User-Agent' => request.user_agent
        }
      }
      options[:head]['X-Requested-With'] = request.env['HTTP_X_REQUESTED_WITH']  if request.env['HTTP_X_REQUESTED_WITH']
      options[request.post? ? :body : :query] = fluther_params

      path = request.path.sub( %r{^#{SimpleFluther::Config.prefix}}, '' )
      path = '/' + path  unless path.starts_with?('/')
      path = path + '/' unless path.ends_with?('/')
      url = "#{request.scheme}://#{SimpleFluther::Config.fluther_host}#{path}"

      Rails.logger.debug request.request_method
      Rails.logger.debug url
      Rails.logger.debug options

      EventMachine::HttpRequest.new( url ).send( request.request_method, options )
    end

    def exec_request
      result = nil
      em_running = EM.reactor_running?
      EM.run  do
        fluther = build_request
        fluther.callback do
          result = handle_response fluther
          EM.stop
        end
      end
      result
    end

    def handle_response( fluther )
      Rails.logger.debug "Fluther HTTP Response Code: #{fluther.response_header.status}" 
      Rails.logger.debug fluther.response_header
      type_header = fluther.response_header['CONTENT_TYPE']
      content_type = type_header.split(';')[0] || 'text/html'

      result = if [301, 302].include?( fluther.response_header.status )
        redirect_to fluther.response_header['LOCATION'], :status => fluther.response_header.status
        false
      elsif request.xhr? || (content_type != 'text/html')
        Rails.logger.debug "AJAX?"
        render :text => fluther.response, :layout => false
#        [ fluther.response_header.status, {'Content-Type' => type_header}, [fluther.response] ]
        true
      else
        fluther.response.html_safe  if fluther.response.respond_to?(:html_safe)
        request.env['fluther.response'] = fluther.response
        request.env['fluther.title']  = fluther.response_header['FLUTHER_TITLE']  if fluther.response_header['FLUTHER_TITLE']
        request.env['fluther.header'] = fluther.response_header['FLUTHER_HEADER']  if fluther.response_header['FLUTHER_HEADER']
#        @app.call request.env
        true
      end
      result
    end
  end
end