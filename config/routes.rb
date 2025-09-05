Rails.application.routes.draw do
  #Tất cả các router được định nghĩa trong block này

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  post 'auth/login', to: 'auth#login' # sẽ tự động map đến phương thức login trong AuthController
  post 'auth/register', to: 'auth#register'
  delete 'auth/logout', to: 'auth#logout'
  get 'auth/me', to: 'auth#me'


  # User Router
  resources :users, except: [:new, :edit]

  # ================== STUDENT ROUTES ==================
  
  # Custom routes (đặt TRƯỚC resources để có độ ưu tiên cao hơn)
  get 'student/dashboard/:id', to: 'student#student_dashboard', as: 'student_dashboard'
  get 'student/search', to: 'student#search'
  get 'student/statistics', to: 'student#statistics'
  
  # RESTful resources
  resources :student, except: [:new, :edit] do
    member do
      # Routes cần :id - /student/:id/action  
      patch :restore    # PATCH /student/:id/restore (khôi phục soft delete)
    end
  end

end

#Cách mà ruby tìm được controller tương ứng là 

# Rails sử dụng quy tắc đặt tên chuẩn để tự động ánh xạ từ route đến controller:
# Quá trình tìm controller:
# post 'auth/login', to: 'auth#login'
# Lấy phần trước dấu # → 'auth'
# Thêm _controller → 'auth_controller'
# Chuyển thành CamelCase → 'AuthController'
# Tìm file → app/controllers/auth_controller.rb
# Tìm class → AuthController
# Gọi method → login

# resources :users

# Quá trình tìm controller:

# Lấy tên resource → :users
# Chuyển thành string → 'users'
# Thêm _controller → 'users_controller'
# Chuyển thành CamelCase → 'UsersController'
# Tìm file → app/controllers/users_controller.rb
# Tìm class → UsersController

# # Ví dụ với route: post 'auth/login', to: 'auth#login'

# # Bước 1: Phân tích route
# controller_name = 'auth'     # Phần trước dấu #
# action_name = 'login'        # Phần sau dấu #

# # Bước 2: Tạo tên file
# file_name = "#{controller_name}_controller.rb"
# # => "auth_controller.rb"

# # Bước 3: Tạo tên class
# class_name = "#{controller_name.camelize}Controller"
# # => "AuthController"

# # Bước 4: Tìm file trong thư mục
# file_path = "app/controllers/#{file_name}"
# # => "app/controllers/auth_controller.rb"

# # Bước 5: Load class và gọi method
# controller_class = Object.const_get(class_name)
# # => AuthController

# # Bước 6: Gọi action
# controller_instance = controller_class.new
# controller_instance.send(action_name)
# # => Gọi method 'login'


# 4. Ví dụ cụ thể với project của bạn:
# Khi có request: POST /auth/login

# Rails tìm route khớp: post 'auth/login', to: 'auth#login'
# Phân tích: controller = 'auth', action = 'login'
# Tìm file: app/controllers/auth_controller.rb
# Tìm class: AuthController
# Gọi method: login
# Khi có request: GET /users

# Rails tìm route khớp: resources :users → GET /users
# Phân tích: controller = 'users', action = 'index'
# Tìm file: app/controllers/users_controller.rb
# Tìm class: UsersController
# Gọi method: index


# # Nếu không có file auth_controller.rb
# LoadError: Unable to autoload constant AuthController

# # Nếu không có class AuthController
# NameError: uninitialized constant AuthController

# # Nếu không có method login
# NoMethodError: undefined method `login' for AuthController