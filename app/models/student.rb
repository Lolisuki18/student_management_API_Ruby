class Student < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :major
  belongs_to :study_class, optional: true
  has_many :student_class_subjects, dependent: :destroy
  has_many :class_subjects, through: :student_class_subjects
  has_many :subjects, through: :class_subjects
  has_many :grades, through: :student_class_subjects
  
  # Validations
  validates :student_code, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :gender, inclusion: { in: %w[male female other] }
  validates :enrollment_year, presence: true, numericality: { greater_than: 1990 }
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_enrollment_year, ->(year) { where(enrollment_year: year) }
  scope :by_major, ->(major_id) { where(major_id: major_id) }
  scope :by_study_class, ->(class_id) { where(study_class_id: class_id) }
  
  def current_semester
    current_year = Date.current.year
    (current_year - enrollment_year) * 2 + (Date.current.month > 6 ? 2 : 1)
  end
  
  def total_subjects
    student_class_subjects.joins(:class_subject).count
  end
  
  def average_grade
    grades.average(:score)&.round(2)
  end
  
  def class_info
    study_class&.class_info || "Chưa xếp lớp"
  end
end
