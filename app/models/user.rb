class User < ApplicationRecord
  has_secure_password
  
  # Associations
  has_one :student, dependent: :destroy
  has_one :teacher, dependent: :destroy
  
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin teacher student] }
  validates :status, inclusion: { in: [true, false] }
  
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
end
