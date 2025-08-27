class Room < ApplicationRecord
  # Associations
  has_many :class_subjects, dependent: :destroy
  has_many :schedules, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validates :room_type, inclusion: { in: %w[classroom laboratory conference computer_lab] }
  validates :status, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_building, ->(building) { where(building: building) }
  scope :by_type, ->(type) { where(room_type: type) }
  
  def full_name
    "#{building}-#{floor}-#{name}"
  end
  
  def available?
    status?
  end
end
