class ApplicationController < ActionController::API
  before_action :authenticate_request

  private
  
  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def authorize_admin
    render json: { errors: 'Access denied' }, status: :forbidden unless current_user.admin?
  end

  def authorize_teacher_or_admin
    render json: {errors: 'Access denied'}, status: :forbidden unless current_user.admin? || current_user.teacher?
  end

  def render_success(data, message = 'Success')
    render json: { success: true, message: message, data: data }, status: :ok
  end

  def render_error(message , status = :bad_request)
    render json: { success: false, message: message }, status: status
  end
end
