class Major < ApplicationRecord
  # Associations
  belongs_to :department
  has_many :students, dependent: :destroy
  has_many :subjects, dependent: :destroy
  has_many :classes, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :duration_years, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  
  def total_students
    students.active.count
  end
  
  def total_subjects
    subjects.active.count
  end
  
  def total_classes
    classes.active.count
  end
end
