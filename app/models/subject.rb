class Subject < ApplicationRecord
  # Associations
  belongs_to :major
  has_many :class_subjects, dependent: :destroy
  has_many :teachers, through: :class_subjects
  has_many :students, through: :class_subjects
  
  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :credits, presence: true, numericality: { greater_than: 0 }
  validates :theory_hours, numericality: { greater_than_or_equal_to: 0 }
  validates :practice_hours, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :required, -> { where(is_required: true) }
  scope :elective, -> { where(is_required: false) }
  scope :by_semester, ->(semester) { where(semester_number: semester) }
  
  def total_hours
    theory_hours + practice_hours
  end
  
  def total_class_subjects
    class_subjects.active.count
  end
  
  def required?
    is_required
  end
end
