class Schedule < ApplicationRecord
  # Associations
  belongs_to :class_subject
  belongs_to :room
  
  # Delegations
  delegate :subject, to: :class_subject
  delegate :teacher, to: :class_subject
  
  # Validations
  validates :day_of_week, presence: true, numericality: { in: 1..7 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :week_type, inclusion: { in: %w[all odd even] }
  validates :status, inclusion: { in: [true, false] }
  
  # Custom validation
  validate :end_time_after_start_time
  validate :no_time_conflict
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_day, ->(day) { where(day_of_week: day) }
  scope :by_week_type, ->(type) { where(week_type: type) }
  
  def day_name
    %w[Chủ nhật Thứ 2 Thứ 3 Thứ 4 Thứ 5 Thứ 6 Thứ 7][day_of_week]
  end
  
  def time_range
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end
  
  def duration_in_hours
    ((end_time - start_time) / 1.hour).round(1)
  end
  
  private
  
  def end_time_after_start_time
    return unless start_time && end_time
    
    if end_time <= start_time
      errors.add(:end_time, 'phải sau thời gian bắt đầu')
    end
  end
  
  def no_time_conflict
    return unless room && day_of_week && start_time && end_time
    
    conflicting_schedules = Schedule.where(
      room: room,
      day_of_week: day_of_week,
      status: true
    ).where.not(id: id)
    
    conflicting_schedules.each do |schedule|
      if times_overlap?(schedule)
        errors.add(:base, "Xung đột thời gian với lịch khác trong phòng #{room.name}")
        break
      end
    end
  end
  
  def times_overlap?(other_schedule)
    start_time < other_schedule.end_time && end_time > other_schedule.start_time
  end
end
