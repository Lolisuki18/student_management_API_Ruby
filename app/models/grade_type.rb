class GradeType < ApplicationRecord
  # Associations
  has_many :grades, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :weight, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :ordered_by_weight, -> { order(:weight) }
  
  def self.total_weight
    active.sum(:weight)
  end
end
