class AcademicYear < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, inclusion: { in: [true, false] }
  
  # Custom validation
  validate :end_date_after_start_date
  validate :only_one_current_year
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :current, -> { where(is_current: true) }
  
  def self.current_year
    current.first
  end
  
  def duration_in_months
    ((end_date - start_date) / 1.month).round
  end
  
  private
  
  def end_date_after_start_date
    return unless start_date && end_date
    
    if end_date <= start_date
      errors.add(:end_date, 'phải sau ngày bắt đầu')
    end
  end
  
  def only_one_current_year
    return unless is_current?
    
    existing_current = AcademicYear.where(is_current: true).where.not(id: id)
    if existing_current.exists?
      errors.add(:is_current, 'chỉ được có một năm học hiện tại')
    end
  end
end
