class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :register]

  #POST  /auth/login
    #Body : {email, password}
  def login 
   begin
      user = User.authenticate(auth_params[:email], auth_params[:password])

    if user
      token = JsonWebToken.encode({user_id: user.id, role: user.role, email: user.email})
      time = Time.now + 24.hours.to_i

      render_success({
        token: token,
        exp: time.strftime("%m-%d-%Y %H:%M"),
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
        }
      })
    else
      render_error('Invalid email or password', :unauthorized)
    end
   rescue => e
    render_error("Lỗi đăng nhập - #{e.message}")
   end
  end #end login

  #POST /auth/register 
  #Body {email, password}
  def register
    # Mặc định role là "student" nếu không có role được truyền vào
  role = "student"
    result = User.add_account(auth_params[:email], auth_params[:password], role)

    if result[:success]
      render_success(
        result[:user],
        result[:message]
      )
    else
      render_error(result[:message])
    end
  end #end register

  #GET /auth/me
  #Body {}
  def me 
    begin
      if current_user
        render_success({
          id: current_user.id,
          email: current_user.email,
          role: current_user.role,
          status: current_user.status,
        })
      else
        render_error('User not found', :not_found)
      end
    rescue => e
      render_error("Lỗi lấy thông tin người dùng - #{e.message}")
    end
  end

    # DELETE /auth/logout
  # Header: Authorization: Bearer <token>
  def logout
    begin
      # Vì JWT là stateless, chúng ta chỉ cần trả về thông báo thành công
      # Trong thực tế, client sẽ xóa token khỏi local storage
      render_success(nil, "Đăng xuất thành công")
    rescue => e
      render_error("Lỗi đăng xuất - #{e.message}")
    end
  end #end logout
  def auth_params
    params.permit(:email, :password, :role)
  end
end