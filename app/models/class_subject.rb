class ClassSubject < ApplicationRecord
  # Associations
  belongs_to :subject
  belongs_to :teacher
  belongs_to :room, optional: true
  has_many :student_class_subjects, dependent: :destroy
  has_many :students, through: :student_class_subjects
  has_many :schedules, dependent: :destroy
  has_many :grades, through: :student_class_subjects
  
  # Validations
  validates :class_code, presence: true, uniqueness: true
  validates :academic_year, presence: true
  validates :semester, presence: true, numericality: { in: 1..2 }
  validates :max_students, presence: true, numericality: { greater_than: 0 }
  validates :current_students, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_academic_year, ->(year) { where(academic_year: year) }
  scope :by_semester, ->(semester) { where(semester: semester) }
  
  # Callbacks
  before_save :update_current_students_count
  
  def available_slots
    max_students - current_students
  end
  
  def full?
    current_students >= max_students
  end
  
  def can_enroll?
    !full? && status?
  end
  
  private
  
  def update_current_students_count
    self.current_students = student_class_subjects.where(status: true).count
  end
end
