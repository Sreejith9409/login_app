class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token  
  skip_before_action :authorized
  before_action :verify_user_authentication, :only => [:update_details, :update_delete_flag]

  rescue_from Exception do |exception| 
    log_error_msg(exception)
    render json: generate_error_message(exception) 
  end

  def log_error_msg(e)
    logger.error "#{e} #{e.backtrace.join("\n")}" 
  end

  def generate_error_message(e)
    err_msg = "<b>REQUEST:</b><br/><br/>"
    err_msg += "* Rails Root : #{Rails.root}<br/>"
    err_msg += "<br/><b>ENVIRONMENT:</b><br/><br/>"
    err_msg += "<br/><b>BACKTRACE:</b><br/><br/>"
    err_msg += "#{e.to_s}<br/>"
    err_msg += "<br/><b>Extra Params</b>: #{Thread.current['errbit_extra_data']}"
    err_msg += e.backtrace.join("\n")
    err_msg
  end

  def verify_user_authentication
    auth_token = get_auth_token
    @user = User.where(id: params[:id]).last
    @is_authenticated = (@user.present? && auth_token == @user.get_encrypted_auth_token)
  end

  def sign_in
    success, status  = true, ErrorCodeConstants::SUCCESS_CODE
    auth_token = get_auth_token
    if auth_token.blank?
      success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
      details = {"message" => "AuthToken Cannot be Blank"}
    else
      user = nil
      if params["login"].present? || params["email"].present?
        condition = params["login"].present? ? "login = '#{params["login"]}'" : "email = '#{params["email"]}'"
        user = User.where(condition).last
      end
      if user.present?
        if auth_token == user.get_encrypted_auth_token
          details = {"message" => "Signed In Successfully!!"}
        else
          success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
          details = {"message" => "AuthToken Doesnt match with the given email/login"}
        end
      else
        success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
        details = {"message" => "Please pass valid email or login"}
      end
    end
    render_json_hash(get_result_hash(status, success, details))
  end

  def sign_up
    success, status  = true, ErrorCodeConstants::SUCCESS_CODE
    if request.raw_post.present?
      params_hash = JSON.parse(request.raw_post)
      user = User.new(user_params(params_hash))
      user.crypted_password = generate_random_password
      if user.save
        details = {"message" => "User Created Successfully with auth token #{user.get_encrypted_auth_token}"}
      else
        success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
        details = {"message" => get_formatted_devise_error_message(user.errors)}
      end
    else
      success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
      details = {"message" => "Body params cannot be blank"}
    end
    render_json_hash(get_result_hash(status, success, details))
  end

  def update_details
    if @is_authenticated
      success, status  = true, ErrorCodeConstants::SUCCESS_CODE
      if request.raw_post.present?
        params_hash = JSON.parse(request.raw_post)
        @user.assign_attributes(params_hash)
        if @user.save
          details = {"message" => "#{@user.name}'s  details updated Successfully "}
        else
          success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
          details = {"message" => get_formatted_devise_error_message(@user.errors)}
        end
      else
        success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
        details = {"message" => "Body params cannot be blank"}
      end
    else
      success, status = false, ErrorCodeConstants::UN_PROCESSABLE_ENTITY
      details = {"message" => "Authentication Failed"}
    end
    render_json_hash(get_result_hash(status, success, details))
  end

  def get_formatted_devise_error_message(error_messages)
    if error_messages.messages.keys.include?(:mobile_number)
      formatted_err_msg = " #{"Mobile Number " + error_messages.messages[:mobile_number].first.to_s}."
    else
      formatted_err_msg = (error_messages.first.first.to_s.gsub("_"," ").camelize + " #{error_messages.first.second.to_s}.")
    end
    error_messages.full_messages.first
  end

  def get_result_hash(code, status, message)
    er_hash = Hash.new
    er_hash["code"] = code 
    er_hash["success"] = status
    er_hash["body"] = message
    er_hash
  end

  def render_json_hash(resp_hash)
    render :json => hash_to_json(resp_hash), :content_type => Mime[:json], :status => 200
  end

  def hash_to_json(hash_obj)
    Oj.dump(hash_obj)
  end

  def json_to_hash(str)
    JSON.parse(str)
  end

  def get_auth_token
    request.headers["HTTP_AUTH_TOKEN"] || params[:auth_token]
  end

  def generate_random_password
    chars = ('0'..'9').to_a + ('A'..'Z').to_a +  ('a'..'z').to_a + ('!'..'?').to_a
    generated_password = chars.sort_by { rand }.join[0...10]
    generated_password += "@"
  end

  private
    def user_params(params_hash)
      {first_name: params_hash["first_name"], last_name: params_hash["last_name"], login: params_hash["login"], email: params_hash["email"], age: params_hash["age"], gender: params_hash["gender"], mobile_number: params_hash["mobile_number"], home_number: params_hash["home_number"], work_number: params_hash["work_number"], address: params_hash["address"], city: params_hash["city"], state: params_hash["state"], country: params_hash["country"], pin_code: params_hash["pin_code"], crypted_password: params_hash["crypted_password"]}
    end
end

module ErrorCodeConstants
  SUCCESS_CODE = 200
  NOT_A_VALID_REQUEST = 400
  INTERNAL_ERROR_CODE = 500
  UN_PROCESSABLE_ENTITY = 422
end