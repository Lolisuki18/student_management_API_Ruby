class StudyClass < ApplicationRecord
  # Set table name to match migration
  self.table_name = 'classes'
  
  # Associations
  belongs_to :major
  belongs_to :homeroom_teacher, class_name: 'Teacher', optional: true
  has_many :students, foreign_key: 'class_id', dependent: :destroy
  
  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :academic_year, presence: true
  validates :semester, presence: true, numericality: { in: 1..2 }
  validates :max_students, presence: true, numericality: { greater_than: 0 }
  validates :current_students, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_academic_year, ->(year) { where(academic_year: year) }
  scope :by_semester, ->(semester) { where(semester: semester) }
  scope :by_major, ->(major_id) { where(major_id: major_id) }
  
  # Callbacks
  before_save :update_current_students_count
  
  def available_slots
    max_students - current_students
  end
  
  def full?
    current_students >= max_students
  end
  
  def can_add_student?
    !full? && status?
  end
  
  def enrollment_rate
    return 0 if max_students.zero?
    (current_students.to_f / max_students * 100).round(1)
  end
  
  def class_info
    "#{name} (#{code}) - #{major.name} - #{academic_year} HK#{semester}"
  end
  
  private
  
  def update_current_students_count
    self.current_students = students.where(status: true).count
  end
end
