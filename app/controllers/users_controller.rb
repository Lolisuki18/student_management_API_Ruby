class UsersController < ApplicationController
  before_action :authorize_admin, except: [:show]
  before_action :set_user, only: [:show, :update, :destroy]  # ← Sửa: "befor_action" → "before_action"

  # GET /users
  def index
    begin
      result = User.get_all_accounts
      if result[:success]
        render_success(result[:users], result[:message])  # ← Sửa: bỏ dấu {} thừa
      else
        render_error(result[:message])
      end
    rescue => e
      render_error("Lỗi lấy danh sách tài khoản - #{e.message}")
    end
  end

  # GET /users/:id
  def show
    begin
      if current_user.admin? || @user.id == current_user.id
        render_success({
          id: @user.id,
          email: @user.email,
          role: @user.role,  # ← Sửa: thêm dấu phẩy
          status: @user.status
        })
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi lấy thông tin tài khoản - #{e.message}")
    end
  end

  # POST /users
  #Body {email, password, role}
  def create
    begin
      if current_user.admin?
        # ← Sử dụng user_params thay vì params trực tiếp
        result = User.add_account(user_params[:email], user_params[:password], user_params[:role])
        if result[:success]  # ← Sửa: "sucess" → "success"
          render_success(result[:user], result[:message])  # ← Sửa: bỏ dấu {} thừa
        else
          render_error(result[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi tạo tài khoản - #{e.message}")
    end
  end

  # PATCH /users/:id
  def update
    begin
      if @user.update(user_params)  # ← Sử dụng user_params
        render_success(@user, "Cập nhật tài khoản thành công")
      else
        render_error(@user.errors.full_messages.join(', '))
      end
    rescue => e
      render_error("Lỗi cập nhật tài khoản - #{e.message}")
    end
  end

  # DELETE /users/:id
  def destroy
    begin
      result = User.soft_delete(@user.email)
      if result[:success]
        render_success(nil, result[:message])  # ← Sửa: bỏ dấu {} thừa
      else
        render_error(result[:message])
      end
    rescue => e
      render_error("Lỗi xóa tài khoản - #{e.message}")
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('Không tìm thấy user', :not_found)
  end
  
  # Strong Parameters - Bảo vệ khỏi Mass Assignment
  def user_params
   params.permit(:email, :password, :role, :status)
  end
end