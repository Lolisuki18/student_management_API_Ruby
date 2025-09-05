class Student < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :major
  belongs_to :study_class, optional: true
  has_many :student_class_subjects, dependent: :destroy
  has_many :class_subjects, through: :student_class_subjects
  has_many :subjects, through: :class_subjects
  # has_many :grades, through: :student_class_subjects  # Comment out problematic association
  attribute :status, :boolean
  # Validations
  validates :student_code, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :gender, inclusion: { in: %w[Nam Nữ Khác male female other] }
  validates :enrollment_year, numericality: { greater_than: 1990 }
  validates :status, inclusion: { in: [true, false] } 
  
  # Scopes
  scope :active, -> { where(status: true) }
  scope :by_enrollment_year, ->(year) { where(enrollment_year: year) }
  scope :by_major, ->(major_id) { where(major_id: major_id) }
  scope :by_study_class, ->(class_id) { where(study_class_id: class_id) }
  
  def current_semester
    current_year = Date.current.year
    (current_year - enrollment_year) * 2 + (Date.current.month > 6 ? 2 : 1)
  end
  
  def total_subjects
    student_class_subjects.joins(:class_subject).count
  end
  
  def grades
    Grade.joins(:student_class_subject).where(student_class_subjects: { student_id: id })
  end
  
  def average_grade
    grades.average(:score)&.round(2)
  end
  
  def class_info
    study_class&.class_info || "Chưa xếp lớp"
  end

  # Method lấy dashboard tổng quan của sinh viên
  # Bao gồm thông tin cơ bản + tiến độ học tập
  def self.get_student_dashboard(student_id)
    begin
      # Include các association cần thiết để tránh N+1 query
      student = includes(:major, :study_class, :subjects).find_by(id: student_id)
      
      if student
        return {
          success: true,
          dashboard: {
            # Thông tin cơ bản của sinh viên
            student_info: {
              id: student.id,
              name: student.full_name,
              code: student.student_code,
              class: student.class_info,
              major: student.major&.name || "Chưa có chuyên ngành"
            },
            # Tiến độ học tập
            academic_progress: {
              current_semester: student.current_semester,
              total_subjects: student.total_subjects,
              average_grade: student.average_grade || 0.0,
              enrollment_year: student.enrollment_year
            }
          }
        }
      else
        return {success: false, message: "Không tìm thấy sinh viên với id #{student_id}"}
      end
    rescue => e
      return {success: false, message: "Lỗi lấy dashboard sinh viên - #{e.message}"}
    end
  end

  # Method tìm kiếm sinh viên theo nhiều tiêu chí
  # Có thể tìm theo tên, mã số, chuyên ngành, lớp
  def self.search_students(search_params = {})
    begin
      # Bắt đầu với scope cơ bản
      students = includes(:major, :study_class)
      
      # Tìm theo tên (không phân biệt hoa thường) - sử dụng LIKE cho SQL Server
      if search_params[:name].present?
        students = students.where("LOWER(full_name) LIKE LOWER(?)", "%#{search_params[:name]}%")
      end
      
      # Tìm theo mã số sinh viên
      if search_params[:student_code].present?
        students = students.where("LOWER(student_code) LIKE LOWER(?)", "%#{search_params[:student_code]}%")
      end
      
      # Tìm theo chuyên ngành
      if search_params[:major_id].present?
        students = students.where(major_id: search_params[:major_id])
      end
      
      # Tìm theo lớp học
      if search_params[:study_class_id].present?
        students = students.where(study_class_id: search_params[:study_class_id])
      end
      
      # Tìm theo năm nhập học
      if search_params[:enrollment_year].present?
        students = students.where(enrollment_year: search_params[:enrollment_year])
      end
      
      # Tìm theo trạng thái (active/inactive)
      if search_params[:status].present?
        students = students.where(status: search_params[:status])
      end
      
      # Sắp xếp kết quả
      students = students.order(:full_name)
      
      return {success: false, message: "Không tìm thấy sinh viên nào phù hợp"} unless students.any?
      
      # Trả về kết quả với thông tin cơ bản
      search_results = students.map do |student|
        {
          id: student.id,
          student_code: student.student_code,
          full_name: student.full_name,
          major_name: student.major&.name || "Chưa có chuyên ngành",
          class_info: student.class_info,
          enrollment_year: student.enrollment_year,
          current_semester: student.current_semester,
          status: student.status ? "Đang học" : "Đã nghỉ"
        }
      end
      
      return {
        success: true, 
        students: search_results,
        total_found: search_results.count
      }
    rescue => e
      return {success: false, message: "Lỗi tìm kiếm sinh viên - #{e.message}"}
    end
  end

  # Method thống kê tổng quan hệ thống
  # Trả về các con số thống kê quan trọng
  def self.get_system_statistics
    begin
      total_students = count
      active_students = active.count
      inactive_students = total_students - active_students
      
      # Thống kê theo năm nhập học
      enrollment_stats = group(:enrollment_year).count
      
      # Thống kê theo chuyên ngành
      major_stats = joins(:major).group('majors.name').count
      
      # Thống kê điểm trung bình - sử dụng query trực tiếp thay vì association
      avg_system_grade = Grade.joins(:student_class_subject)
                              .joins("INNER JOIN students ON students.id = student_class_subjects.student_id")
                              .average(:score)&.round(2) || 0.0
      
      return {
        success: true,
        statistics: {
          # Thống kê sinh viên
          total_students: total_students,
          active_students: active_students,
          inactive_students: inactive_students,
          
          # Thống kê theo năm
          enrollment_by_year: enrollment_stats,
          
          # Thống kê theo chuyên ngành
          students_by_major: major_stats,
          
          # Thống kê điểm số
          system_average_grade: avg_system_grade,
          
          # Thống kê khác
          total_majors: major_stats.keys.count,
          current_year: Date.current.year
        }
      }
    rescue => e
      return {success: false, message: "Lỗi lấy thống kê hệ thống - #{e.message}"}
    end
  end

  # Lấy thông tin sinh viên theo ID hoặc student_code
  # Sử dụng includes để tránh N+1 query problem
  def self.get_student_info(identifier, by: :id)
    begin
      # Load sinh viên cùng với major và study_class để tránh N+1 query
      student = case by
                when :id
                  includes(:major, :study_class).find_by(id: identifier)
                when :student_code
                  includes(:major, :study_class).find_by(student_code: identifier)
                else
                  nil
                end
    
      if student
        # Trả về thông tin chi tiết sinh viên
        return {
          success: true, 
          student: {
            # Thông tin cơ bản
            id: student.id,
            student_code: student.student_code,
            full_name: student.full_name,
            gender: student.gender,
            date_of_birth: student.date_of_birth,
            phone: student.phone,
            address: student.address,
            enrollment_year: student.enrollment_year,
            status: student.status,
            
            # Thông tin liên quan (tạm thời hardcode để tránh lỗi)
            current_semester: student.current_semester,
            total_subjects: 0, # Tạm thời set = 0
            average_grade: 0.0, # Tạm thời set = 0.0
            class_info: student.class_info,
            major_name: student.major&.name || "Chưa có chuyên ngành"
          }
        }
      else
        search_type = by == :id ? "id" : "mã số"
        return {success: false, message: "Không tìm thấy sinh viên với #{search_type} #{identifier}"}
      end
    rescue => e
      return {success: false, message: "Lỗi lấy thông tin sinh viên - #{e.message}"}
    end
  end # end get_student_info

  # Cập nhật thông tin 1 sinh viên
  def self.update_student(id, student_params)
    begin
      student = find_by(id: id, status: true)
      return { success: false, message: "Không tìm thấy sinh viên" } unless student
      
      # Kiểm tra mã sinh viên trùng lặp nếu có cập nhật student_code
      if student_params[:student_code] && student_params[:student_code] != student.student_code
        existing_student = find_by(student_code: student_params[:student_code])
        return { success: false, message: "Mã số sinh viên #{student_params[:student_code]} đã tồn tại" } if existing_student
      end
      
      # Convert status to boolean if provided
      if student_params.key?(:status)
        student_params[:status] = !!student_params[:status]
      end
      
      student.update!(student_params)
      return { success: true, message: "Cập nhật thông tin sinh viên thành công", student: student }
    rescue => e
      return { success: false, message: "Lỗi khi cập nhật thông tin sinh viên - #{e.message}" }
    end
  end

  # Lấy danh sách tất cả sinh viên với tùy chọn bao gồm thống kê
  # Include association để tránh N+1 query khi truy cập major và study_class
  def self.get_all_students(include_stats: false)
    begin
      # Load tất cả sinh viên với association, sắp xếp theo tên
      associations = include_stats ? [:major, :study_class] : [:major, :study_class]
      students = includes(associations).order(:full_name)
      
      # Nếu có dữ liệu thì return về danh sách sinh viên với format chi tiết
      if students.any?
        students_list = students.map do |student|
          result = {
            id: student.id,
            student_code: student.student_code,
            full_name: student.full_name,
            gender: student.gender,
            enrollment_year: student.enrollment_year,
            class_info: student.class_info,
            major_name: student.major&.name || "Chưa có chuyên ngành",
            status: student.status ? "Đang học" : "Đã nghỉ"
          }
          
          # Chỉ thêm thống kê khi được yêu cầu
          if include_stats
            result.merge!({
              current_semester: student.current_semester,
              total_subjects: student.total_subjects,
              average_grade: student.average_grade || 0.0
            })
          end
          
          result
        end
        return {success: true, students: students_list, total: students_list.count}
      else
        # Nếu không có thì báo không có sinh viên nào
        return {success: false, message: "Không có sinh viên nào trong hệ thống"}
      end
    rescue => e
      return {success: false, message: "Lỗi lấy danh sách sinh viên - #{e.message}"}
    end
  end #end get_all_students

  # Xóa mềm sinh viên - chỉ thay đổi status thành false
  # Không xóa vĩnh viễn dữ liệu để có thể khôi phục sau này
  def self.soft_delete(student_code)
    begin
      # Tìm sinh viên theo mã số
      existing_student = find_by(student_code: student_code)
      
      if existing_student
        # Nếu có thì xóa mềm bằng cách set status = false
        result = existing_student.update(status: false)
        
        if result
          # Nếu xóa thành công 
          return {
            success: true, 
            message: "Xóa sinh viên thành công",
            student: {
              id: existing_student.id,
              student_code: existing_student.student_code,
              full_name: existing_student.full_name,
              status: "Đã nghỉ học"
            }
          }
        else
          # Nếu xóa thất bại (có validation errors)
          return {
            success: false, 
            message: "Xóa sinh viên thất bại: #{existing_student.errors.full_messages.join(', ')}"
          }
        end
      else
        # Nếu không tìm thấy sinh viên
        return {
          success: false, 
          message: "Không tìm thấy sinh viên với mã số #{student_code}"
        }
      end
    rescue => e
      return {success: false, message: "Lỗi khi xóa sinh viên - #{e.message}"}
    end 
  end #end soft_delete

  # Thêm 1 sinh viên mới 
  def self.add_student(student)
    begin
      Rails.logger.info "=== ADD STUDENT DEBUG ==="
      Rails.logger.info "Student params: #{student.inspect}"
      Rails.logger.info "Status value: #{student[:status].inspect}"
      Rails.logger.info "Status class: #{student[:status].class}"
      
      # Kiểm tra xem mã số sinh viên đã tồn tại chưa
      existing_student = find_by(student_code: student[:student_code])
      return { success: false, message: "Mã số sinh viên #{student[:student_code]} đã tồn tại" } if existing_student
      
      # Nếu chưa thì tạo account mới rồi tạo sinh viên sau
      email = "#{student[:student_code]}@university.edu.vn"
      password = "123456"  # Make sure password is a string
      
      # Tạo tài khoản user mới
      user_result = User.add_account(email, password, "student")
      if user_result[:success]
        # Convert status to boolean before creating
        status_value = case student[:status]
        when 1, "1", true, "true"
          true
        when 0, "0", false, "false"
          false
        else
          true # default value
        end
        
        Rails.logger.info "Converted status: #{status_value.inspect}"
        
        # Tạo sinh viên mới với status đã convert
        student_new = create(
          user_id: user_result[:user].id,
          student_code: student[:student_code],
          full_name: student[:full_name],
          date_of_birth: student[:date_of_birth],
          gender: student[:gender],
          phone: student[:phone],
          address: student[:address],
          major_id: student[:major_id],
          enrollment_year: student[:enrollment_year],
          status: status_value,
          study_class_id: student[:study_class_id] 
        )
        return {success: true, message: "Thêm mới sinh viên thành công", student: student_new}
      else
        return {success: false, message: "Lỗi tạo tài khoản user cho sinh viên - #{user_result[:message]}"}
      end
    rescue => e
      Rails.logger.error "ADD STUDENT ERROR: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return {success: false, message: "Lỗi khi thêm mới 1 sinh viên - #{e.message}"}
    end 
  end
end
