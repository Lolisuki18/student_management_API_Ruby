class Department < ApplicationRecord
  # Associations
  has_many :majors, dependent: :destroy
  has_many :teachers, dependent: :destroy
  belongs_to :head_teacher, class_name: 'Teacher', optional: true
  
  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  
  def total_teachers
    teachers.active.count
  end
  
  def total_majors
    majors.active.count
  end
end
