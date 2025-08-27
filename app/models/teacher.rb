class Teacher < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :department
  has_many :class_subjects, dependent: :destroy
  has_many :subjects, through: :class_subjects
  has_many :classes, foreign_key: 'homeroom_teacher_id', dependent: :nullify
  has_one :head_department, class_name: 'Department', foreign_key: 'head_teacher_id', dependent: :nullify
  has_many :grades, foreign_key: 'graded_by_id', dependent: :destroy
  
  # Validations
  validates :teacher_code, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :email, uniqueness: true, allow_blank: true
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  
  def total_class_subjects
    class_subjects.active.count
  end
  
  def total_students
    class_subjects.joins(:student_class_subjects).distinct.count('student_class_subjects.student_id')
  end
end
