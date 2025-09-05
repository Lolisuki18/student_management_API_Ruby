class User < ApplicationRecord
  has_secure_password
  
  # Associations
  has_one :student, dependent: :destroy
  has_one :teacher, dependent: :destroy
  
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin teacher student] }
  validates :status, inclusion: { in: [true, false] }
  
  # Add attribute casting
  attribute :status, :boolean
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_role, ->(role) { where(role: role) }
  
  # Methods
  def admin?
    role == 'admin'
  end
  
  def teacher?
    role == 'teacher'
  end
  
  def student?
    role == 'student'
  end
  
  def full_name
    if teacher?
      teacher&.full_name
    elsif student?
      student&.full_name
    else
      email.split('@').first
    end
  end

  # Class Method
  #Xoá mềm 1 tài khoản 
  def self.soft_delete(email)
   begin
    #Tìm user đó có tồn tại không ?
      user = find_by(email: email)
    #Nếu tồn tại thì cập nhập 
    if user
      user.update(status: false)
      return {success: true, message: "Xoá tài khoản thành công"}
    else
      return {success: false, message: "Không tìm thấy tài khoản với email #{email}"}
    end
    rescue => e
      return {success: false, message:"Lỗi xoá tài khoản - #{e.message}"}
   end
  end

  #Cập nhập tài khoản
  def self.update_account(user)
    begin 
      #Tìm xem user đó có tồn tại không ?
      existing_user = find_by(id: user.id)
      #Nếu có tồn tại thì cập nhập
      if existing_user
        #Cập nhập thông tin 
        existing_user.update(
          email: user.email,
          password: user.password,
          role: user.role,
          status: user.status
        )
        return {success: true, message: "Cập nhập tài khoản thành công",user: existing_user}
      else
        return {success: false, message: "Không tìm thấy tài khoản với id #{user.id}"}
      end
    rescue => e 
      return {success: false , message: "Lỗi cập nhập tài khoản - #{e.message}"}
    end
  end

  #Lấy toàn bộ tài khoản có trong hệ thống
  def self.get_all_accounts
    begin
      users = all
      return {success: true, message: "Lấy danh sách tài khoản thành công", users: users}
    rescue => e
      return {success: false, message: "Lỗi lấy danh sách tài khoản - #{e.message}"}
    end
  end
  
  #Tạo 1 tài khoản mới 
  def self.add_account(email,password,role)
    #Kiểm tra email đã tồn tại chưa ?
    return {
      success: false,
      message: "Email đã tồn tại"
    } if email_exists?(email)

    #Validate role 
    return{success: false, message: "Vai trò không hợp lệ"} unless %w[admin teacher student].include?(role)

    #Tạo user mới 
    begin
       # Tạo user mới (has_secure_password sẽ tự động hash password)
        user = create!(
        email: email, 
        password: password,
        role: role, 
        status: true)
      return {success: true, message: "Tạo tài khoản thành công", user: user}
    rescue ActiveRecord::RecordInvalid => e
      return {success: false, message:"Lỗi tạo tài khoản - #{e.message}"}
    end
  end

  #Class Method - Kiểm tra email đã tồn tại chưa ?
  def self.email_exists?(email)
    exists?(email: email)
  end
  #Xem thử có email này đã tồn tại chưa ?  không ?
  def self.find_by_email(email)
    find_by(email: email)
  end
  #Check xem thử có đủ quyền hạn truy cập hay không ?
  def self.authenticate(email, password)
    user = find_by_email(email)
    return nil unless user&.status # ← Kiểm tra status trước
    
    user.authenticate(password) # ← Chỉ cần return kết quả authenticate
  end
end
