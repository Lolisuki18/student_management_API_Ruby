class StudentController < ApplicationController
  
  before_action :set_student, only: [:student_dashboard, :show, :update, :destroy, :restore]

  # GET /student/dashboard/:id
  # Body {}
  def student_dashboard
    begin
      if current_user.student? && @student.user_id == current_user.id || current_user.admin? 
        dashboard_data = Student.get_student_dashboard(@student.id)
        if dashboard_data[:success]
          render_success(dashboard_data[:dashboard])
        else
          render_error(dashboard_data[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi lấy thông tin dashboard - #{e.message}")
    end
  end

 # GET /student/profile/:id
def show
  begin
    # Cho phép admin/teacher xem bất kỳ student nào, student chỉ xem của mình
    if (current_user.admin? || current_user.teacher?) || 
       (current_user.student? && @student.user_id == current_user.id)
      profile_data = Student.get_student_info(@student.id)
      if profile_data[:success]
        render_success(profile_data[:student])
      else
        render_error(profile_data[:message])
      end
    else
      render_error('Access denied', :forbidden)
    end
  rescue => e
    render_error("Lỗi lấy thông tin student - #{e.message}")
  end
end

  # POST /student
  def create 
    begin
      if current_user.admin? || current_user.teacher?
        result = Student.add_student(student_params)
        if result[:success]
          render_success(result[:student], result[:message])
        else
          render_error(result[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi tạo student - #{e.message}")
    end    
  end

  # PUT /student/:id
  # Body {student}
  def update
    begin
      if current_user.admin? || current_user.teacher?
        result = Student.update_student(params[:id], student_params)
        if result[:success]
          render_success(result[:student], result[:message])
        else
          render_error(result[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi cập nhật student - #{e.message}")
    end
  end

  # GET /student
  # Body {}
  def index 
    begin
      if current_user.admin? || current_user.teacher?
        result = Student.get_all_students()
        if result[:success]
          render_success(result[:students], result[:total]) 
        else
          render_error(result[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi lấy danh sách student - #{e.message}")
    end
  end

  # DELETE /student/:id
  # Body {}
  def destroy
    begin
      if current_user.admin? || current_user.teacher?
        result = Student.soft_delete(@student.student_code)
        if result[:success]
          render_success(result[:student], result[:message])
        else
          render_error(result[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi xóa student - #{e.message}")
    end
  end

  # GET /student/search
  def search
    begin
      if current_user.admin? || current_user.teacher?
        search_params_hash = params.permit(:name, :student_code, :major_id, :study_class_id, :enrollment_year, :status)
        result = Student.search_students(search_params_hash)
        if result[:success]
          render_success(result[:students], "Tìm kiếm thành công. Tìm thấy #{result[:total_found]} sinh viên")
        else
          render_error(result[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi tìm kiếm student - #{e.message}")
    end
  end

  # GET /student/statistics
  def statistics
    begin
      if current_user.admin?
        stats = Student.get_system_statistics
        if stats[:success]
          render_success(stats[:statistics])
        else
          render_error(stats[:message])
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi lấy thống kê hệ thống - #{e.message}")
    end
  end

  # PATCH /student/:id/restore
  def restore
    begin
      if current_user.admin? || current_user.teacher?
        # Khôi phục sinh viên đã soft delete - sử dụng @student từ before_action
        if @student.update(status: true)
          render_success(@student, "Khôi phục sinh viên thành công")
        else
          render_error("Khôi phục sinh viên thất bại: #{@student.errors.full_messages.join(', ')}")
        end
      else
        render_error('Access denied', :forbidden)
      end
    rescue => e
      render_error("Lỗi khôi phục student - #{e.message}")
    end
  end


  private
  
 # Lấy Student theo ID
def set_student
  # Sử dụng current_user.id thay vì current_user.user_id
   @student = Student.find_by!(id: params[:id])
rescue ActiveRecord::RecordNotFound
  render_error('Không tìm thấy student', :not_found)
end
    # Strong Parameters - Bảo vệ khỏi Mass Assignment
  def student_params
    params.require(:student).permit(
      :student_code, :full_name, :date_of_birth, :gender, 
      :phone, :address, :major_id, :enrollment_year, 
      :status, :study_class_id
    )
  end
end