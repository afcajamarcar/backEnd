module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    devise_token_auth_group :member, contains: [:retailer, :distributor]

    def create
      @resource = resource_class.new(sign_up_params)
      @resource.provider ="email"

      #validation
      if resource_class.case_insensitive_keys.include?(:email)
        @resource.email= sign_up_params[:email].try :downcase
      else
        @resource.email= sign_up_params[:email]
      end

      UserMailer.welcome_email(@resource).deliver_now

      # give redirect value from params priority
      @redirect_url= params[:confirm_success_url]

      #fall back to default value if provided

      @redirect_url ||= DeviseTokenAuth.default_confirm_success_url

      #success redirect url is required
      if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
        return  render_create_error_missing_confirm_success_url
      end

      # if whitelist is set, validate redirect_url against whitelist
      #What is whitelist? -> http://searchexchange.techtarget.com/definition/whitelist
      if DeviseTokenAuth.redirect_whitelist
        unless DeviseTokenAuth::Url.whitelisted(@redirect_url)
          return render_create_error_redirect_url_not_allowed
        end
      end

      begin
        #override email confirmation, must be sent from controller
        resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
        resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)

        if @resource.save
          yield @resource if block_given?
            unless @resource.confirmed?
                #user will require email authentication
                @resource.send_confirmation_instructions({
                  client_config: params[:config_name],
                  redirect_url: @redirect_url
                })
            else
              @client_id= SecureRandom.urlsafe_base64(nil, false)
              @token= SecureRandom.urlsafe_base64(nil, false)

              @resource.tokens[@client_id]={
                token: BCrypt::Password.create(@token),
                expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
              }

              @resource.valid?
              puts @resource.errors.full_messages
              update_auth_header
            end
            render_create_success

          else
            clean_up_passwords @resource
            render_create_error
          end

        rescue ActiveRecord::RecordNotUnique
          clean_up_passwords @resource
          render_create_error_email_already_exists
        end
      end

      def update 
       if @resource 
         @resource1 = @resource 
         if @resource1.send(resource_update_method, account_update_params) 
           yield @resource1 if block_given? 
           render_update_success 
         else 
           render_update_error 
         end 
       else 
         render_update_error_user_not_found 
       end 
     end 
      def destroy 
        if @resource 
          @resource.destroy 
          yield @resource if block_given? 
 
          render_destroy_success 
        else 
          render_destroy_error 
        end 
      end 
    end
end
