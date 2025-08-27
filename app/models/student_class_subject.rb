class StudentClassSubject < ApplicationRecord
  # Associations
  belongs_to :student
  belongs_to :class_subject
  has_many :grades, dependent: :destroy
  
  # Validations
  validates :student_id, uniqueness: { scope: :class_subject_id, message: "đã đăng ký môn học này" }
  validates :enrollment_date, presence: true
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_academic_year, ->(year) { joins(:class_subject).where(class_subjects: { academic_year: year }) }
  scope :by_semester, ->(semester) { joins(:class_subject).where(class_subjects: { semester: semester }) }
  
  # Delegates
  delegate :subject, to: :class_subject
  delegate :teacher, to: :class_subject
  delegate :academic_year, to: :class_subject
  delegate :semester, to: :class_subject
  
  def final_grade
    return nil unless grades.any?
    
    total_weight = 0
    weighted_score = 0
    
    grades.joins(:grade_type).each do |grade|
      weight = grade.grade_type.weight
      total_weight += weight
      weighted_score += grade.score * weight / 100
    end
    
    total_weight > 0 ? (weighted_score / total_weight * 100).round(2) : nil
  end
  
  def passed?
    final_grade && final_grade >= 5.0
  end
end
