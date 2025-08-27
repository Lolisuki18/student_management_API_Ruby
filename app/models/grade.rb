class Grade < ApplicationRecord
  # Associations
  belongs_to :student_class_subject
  belongs_to :grade_type
  belongs_to :graded_by, class_name: 'Teacher'
  
  # Delegations
  delegate :student, to: :student_class_subject
  delegate :class_subject, to: :student_class_subject
  delegate :subject, to: :student_class_subject
  
  # Validations
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :student_class_subject_id, uniqueness: { scope: :grade_type_id, message: "đã có điểm cho loại điểm này" }
  validates :graded_at, presence: true
  
  # Scopes
  scope :by_grade_type, ->(type) { joins(:grade_type).where(grade_types: { code: type }) }
  scope :recent, -> { order(graded_at: :desc) }
  
  def passed?
    score >= 5.0
  end
  
  def grade_letter
    case score
    when 9.0..10.0
      'A+'
    when 8.5...9.0
      'A'
    when 8.0...8.5
      'B+'
    when 7.0...8.0
      'B'
    when 6.5...7.0
      'C+'
    when 5.5...6.5
      'C'
    when 5.0...5.5
      'D+'
    when 4.0...5.0
      'D'
    else
      'F'
    end
  end
end
