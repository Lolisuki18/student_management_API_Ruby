# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Bắt đầu tạo dữ liệu mẫu..."

# 1. Tạo Academic Years
puts "📅 Tạo năm học..."
academic_year = AcademicYear.find_or_create_by!(name: "2024-2025") do |ay|
  ay.start_date = Date.new(2024, 9, 1)
  ay.end_date = Date.new(2025, 6, 30)
  ay.is_current = true
  ay.status = true
end



# 3. Tạo Departments
puts "🏢 Tạo khoa/bộ môn..."
departments_data = [
  { name: "Khoa Công nghệ Thông tin", code: "CNTT", description: "Đào tạo các ngành về công nghệ thông tin" },
  { name: "Khoa Kinh tế", code: "KT", description: "Đào tạo các ngành về kinh tế và quản trị" },
  { name: "Khoa Ngoại ngữ", code: "NN", description: "Đào tạo các ngành ngoại ngữ" },
  { name: "Khoa Kỹ thuật", code: "KTKT", description: "Đào tạo các ngành kỹ thuật" }
]

departments = {}
departments_data.each do |dept_attrs|
  dept = Department.find_or_create_by!(code: dept_attrs[:code]) do |d|
    d.name = dept_attrs[:name]
    d.description = dept_attrs[:description]
    d.status = true
  end
  departments[dept_attrs[:code]] = dept
end

# 4. Tạo Majors
puts "🎓 Tạo ngành học..."
majors_data = [
  { name: "Công nghệ Thông tin", code: "CNTT", duration_years: 4, department_code: "CNTT" },
  { name: "Khoa học Máy tính", code: "KHMT", duration_years: 4, department_code: "CNTT" },
  { name: "Quản trị Kinh doanh", code: "QTKD", duration_years: 4, department_code: "KT" },
  { name: "Kế toán", code: "KT", duration_years: 4, department_code: "KT" },
  { name: "Tiếng Anh", code: "TA", duration_years: 4, department_code: "NN" },
  { name: "Kỹ thuật Phần mềm", code: "KTPM", duration_years: 4, department_code: "CNTT" }
]

majors = {}
majors_data.each do |major_attrs|
  major = Major.find_or_create_by!(code: major_attrs[:code]) do |m|
    m.name = major_attrs[:name]
    m.duration_years = major_attrs[:duration_years]
    m.department = departments[major_attrs[:department_code]]
    m.status = true
  end
  majors[major_attrs[:code]] = major
end

# 5. Tạo Users và Teachers
puts "👨‍🏫 Tạo giáo viên..."
teachers_data = [
  { email: "admin@university.edu.vn", password: "123456", role: "admin", 
    teacher_code: "GV001", full_name: "Nguyễn Văn Admin", phone: "0901234567", 
    department_code: "CNTT", position: "Trưởng khoa" },
  { email: "teacher1@university.edu.vn", password: "123456", role: "teacher", 
    teacher_code: "GV002", full_name: "Trần Thị Hoa", phone: "0901234568", 
    department_code: "CNTT", position: "Giảng viên chính" },
  { email: "teacher2@university.edu.vn", password: "123456", role: "teacher", 
    teacher_code: "GV003", full_name: "Lê Văn Nam", phone: "0901234569", 
    department_code: "KT", position: "Giảng viên" },
  { email: "teacher3@university.edu.vn", password: "123456", role: "teacher", 
    teacher_code: "GV004", full_name: "Phạm Thị Lan", phone: "0901234570", 
    department_code: "NN", position: "Giảng viên chính" }
]

teachers = {}
teachers_data.each do |teacher_attrs|
  user = User.find_or_create_by!(email: teacher_attrs[:email]) do |u|
    u.password = teacher_attrs[:password]
    u.role = teacher_attrs[:role]
    u.status = true
  end
  
  teacher = Teacher.find_or_create_by!(teacher_code: teacher_attrs[:teacher_code]) do |t|
    t.user = user
    t.full_name = teacher_attrs[:full_name]
    t.phone = teacher_attrs[:phone]
    t.email = teacher_attrs[:email]
    t.department = departments[teacher_attrs[:department_code]]
    t.position = teacher_attrs[:position]
    t.hire_date = Date.current - rand(1..5).years
    t.status = true
  end
  teachers[teacher_attrs[:teacher_code]] = teacher
end

# 6. Tạo Rooms
puts "🏫 Tạo phòng học..."
rooms_data = [
  { name: "A101", code: "A101", capacity: 40, building: "A", floor: "1", room_type: "classroom" },
  { name: "A102", code: "A102", capacity: 35, building: "A", floor: "1", room_type: "classroom" },
  { name: "A201", code: "A201", capacity: 45, building: "A", floor: "2", room_type: "classroom" },
  { name: "B101", code: "B101", capacity: 30, building: "B", floor: "1", room_type: "computer_lab" },
  { name: "B102", code: "B102", capacity: 30, building: "B", floor: "1", room_type: "computer_lab" },
  { name: "C101", code: "C101", capacity: 50, building: "C", floor: "1", room_type: "conference" }
]

rooms = {}
rooms_data.each do |room_attrs|
  room = Room.find_or_create_by!(code: room_attrs[:code]) do |r|
    r.name = room_attrs[:name]
    r.capacity = room_attrs[:capacity]
    r.building = room_attrs[:building]
    r.floor = room_attrs[:floor]
    r.room_type = room_attrs[:room_type]
    r.equipment = "Máy chiếu, màn hình, bảng trắng"
    r.status = true
  end
  rooms[room_attrs[:code]] = room
end

# 7. Tạo Subjects
puts "📚 Tạo môn học..."
subjects_data = [
  { name: "Lập trình Web", code: "WEB101", credits: 3, theory_hours: 30, practice_hours: 30, 
    major_code: "CNTT", semester_number: 3, is_required: true },
  { name: "Cơ sở dữ liệu", code: "DB101", credits: 3, theory_hours: 30, practice_hours: 30, 
    major_code: "CNTT", semester_number: 3, is_required: true },
  { name: "Lập trình Java", code: "JAVA101", credits: 3, theory_hours: 30, practice_hours: 30, 
    major_code: "CNTT", semester_number: 4, is_required: true },
  { name: "Quản trị học", code: "MGT101", credits: 3, theory_hours: 45, practice_hours: 0, 
    major_code: "QTKD", semester_number: 1, is_required: true },
  { name: "Tiếng Anh chuyên ngành IT", code: "ENG101", credits: 2, theory_hours: 30, practice_hours: 0, 
    major_code: "CNTT", semester_number: 2, is_required: false }
]

subjects = {}
subjects_data.each do |subject_attrs|
  subject = Subject.find_or_create_by!(code: subject_attrs[:code]) do |s|
    s.name = subject_attrs[:name]
    s.credits = subject_attrs[:credits]
    s.theory_hours = subject_attrs[:theory_hours]
    s.practice_hours = subject_attrs[:practice_hours]
    s.major = majors[subject_attrs[:major_code]]
    s.semester_number = subject_attrs[:semester_number]
    s.is_required = subject_attrs[:is_required]
    s.status = true
  end
  subjects[subject_attrs[:code]] = subject
end

# 8. Tạo Study Classes (Lớp sinh hoạt)
puts "🏛️ Tạo lớp sinh hoạt..."
study_classes_data = [
  { name: "CNTT K20A", code: "CNTT20A", major_code: "CNTT", academic_year: "2024-2025", 
    semester: 1, max_students: 40, teacher_code: "GV002" },
  { name: "CNTT K20B", code: "CNTT20B", major_code: "CNTT", academic_year: "2024-2025", 
    semester: 1, max_students: 35, teacher_code: "GV002" },
  { name: "QTKD K20A", code: "QTKD20A", major_code: "QTKD", academic_year: "2024-2025", 
    semester: 1, max_students: 40, teacher_code: "GV003" },
  { name: "KTPM K20A", code: "KTPM20A", major_code: "KTPM", academic_year: "2024-2025", 
    semester: 1, max_students: 35, teacher_code: "GV002" }
]

study_classes = {}
study_classes_data.each do |class_attrs|
  study_class = StudyClass.find_or_create_by!(code: class_attrs[:code]) do |sc|
    sc.name = class_attrs[:name]
    sc.major = majors[class_attrs[:major_code]]
    sc.academic_year = class_attrs[:academic_year]
    sc.semester = class_attrs[:semester]
    sc.max_students = class_attrs[:max_students]
    sc.homeroom_teacher = teachers[class_attrs[:teacher_code]]
    sc.current_students = 0
    sc.status = true
  end
  study_classes[class_attrs[:code]] = study_class
end

# 9. Tạo Students
puts "👨‍🎓 Tạo sinh viên..."
students_data = []
(1..20).each do |i|
  study_class_code = ["CNTT20A", "CNTT20B", "QTKD20A", "KTPM20A"].sample
  major_code = case study_class_code
  when "CNTT20A", "CNTT20B" then "CNTT"
  when "QTKD20A" then "QTKD"
  when "KTPM20A" then "KTPM"
  end
  
  students_data << {
    email: "student#{i}@student.university.edu.vn",
    password: "123456",
    student_code: "SV#{i.to_s.rjust(4, '0')}",
    full_name: "Sinh viên #{i}",
    date_of_birth: Date.new(2000 + rand(5), rand(1..12), rand(1..28)),
    gender: ["male", "female"].sample,
    phone: "090123#{i.to_s.rjust(4, '0')}",
    address: "Địa chỉ sinh viên #{i}",
    major_code: major_code,
    study_class_code: study_class_code,
    enrollment_year: [2022, 2023, 2024].sample
  }
end

students = {}
students_data.each do |student_attrs|
  user = User.find_or_create_by!(email: student_attrs[:email]) do |u|
    u.password = student_attrs[:password]
    u.role = "student"
    u.status = true
  end
  
  student = Student.find_or_create_by!(student_code: student_attrs[:student_code]) do |s|
    s.user = user
    s.full_name = student_attrs[:full_name]
    s.date_of_birth = student_attrs[:date_of_birth]
    s.gender = student_attrs[:gender]
    s.phone = student_attrs[:phone]
    s.address = student_attrs[:address]
    s.major = majors[student_attrs[:major_code]]
    s.study_class = study_classes[student_attrs[:study_class_code]]
    s.enrollment_year = student_attrs[:enrollment_year]
    s.status = true
  end
  students[student_attrs[:student_code]] = student
end

# 10. Tạo Class Subjects (Lớp học phần)
puts "📖 Tạo lớp học phần..."
class_subjects_data = [
  { subject_code: "WEB101", teacher_code: "GV002", class_code: "WEB101_01", 
    academic_year: "2024-2025", semester: 1, room_code: "B101", max_students: 30 },
  { subject_code: "DB101", teacher_code: "GV002", class_code: "DB101_01", 
    academic_year: "2024-2025", semester: 1, room_code: "B102", max_students: 30 },
  { subject_code: "JAVA101", teacher_code: "GV002", class_code: "JAVA101_01", 
    academic_year: "2024-2025", semester: 2, room_code: "B101", max_students: 25 },
  { subject_code: "MGT101", teacher_code: "GV003", class_code: "MGT101_01", 
    academic_year: "2024-2025", semester: 1, room_code: "A101", max_students: 40 }
]

class_subjects = {}
class_subjects_data.each do |cs_attrs|
  class_subject = ClassSubject.find_or_create_by!(class_code: cs_attrs[:class_code]) do |cs|
    cs.subject = subjects[cs_attrs[:subject_code]]
    cs.teacher = teachers[cs_attrs[:teacher_code]]
    cs.academic_year = cs_attrs[:academic_year]
    cs.semester = cs_attrs[:semester]
    cs.room = rooms[cs_attrs[:room_code]]
    cs.max_students = cs_attrs[:max_students]
    cs.current_students = 0
    cs.status = true
  end
  class_subjects[cs_attrs[:class_code]] = class_subject
end
# 2. Tạo Grade Types 
puts "📊 Tạo loại điểm..."
grade_types_data = [
  { name: "Chuyên cần", code: "CC", weight: 10.0, description: "Điểm chuyên cần, tham gia lớp học" },
  { name: "Bài tập", code: "BT", weight: 20.0, description: "Điểm bài tập về nhà và trên lớp" },
  { name: "Giữa kỳ", code: "GK", weight: 30.0, description: "Điểm kiểm tra giữa kỳ" },
  { name: "Cuối kỳ", code: "CK", weight: 40.0, description: "Điểm thi cuối kỳ" }
]

grade_types = {}
grade_types_data.each do |gt_attrs|
  grade_type = GradeType.find_or_create_by!(code: gt_attrs[:code]) do |gt|
    gt.name = gt_attrs[:name]
    gt.weight = gt_attrs[:weight]
    gt.description = gt_attrs[:description]
    gt.status = true
  end
  grade_types[gt_attrs[:name]] = grade_type
end

# 11. Đăng ký sinh viên vào lớp học phần (Student Class Subjects)
puts "📝 Đăng ký sinh viên vào lớp học phần..."
student_class_subjects = []

# Đăng ký một số sinh viên vào các lớp học phần
students.values.first(10).each do |student|
  # Đăng ký vào lớp WEB101_01 (sinh viên CNTT)
  if student.major.code == "CNTT"
    scs1 = StudentClassSubject.find_or_create_by!(
      student: student,
      class_subject: class_subjects["WEB101_01"]
    ) do |scs|
      scs.enrollment_date = Date.current - rand(30..60).days
      scs.status = true
    end
    student_class_subjects << scs1

    # Đăng ký vào lớp DB101_01
    scs2 = StudentClassSubject.find_or_create_by!(
      student: student,
      class_subject: class_subjects["DB101_01"]
    ) do |scs|
      scs.enrollment_date = Date.current - rand(30..60).days
      scs.status = true
    end
    student_class_subjects << scs2
  end
  
  # Đăng ký sinh viên QTKD vào lớp MGT101_01
  if student.major.code == "QTKD"
    scs3 = StudentClassSubject.find_or_create_by!(
      student: student,
      class_subject: class_subjects["MGT101_01"]
    ) do |scs|
      scs.enrollment_date = Date.current - rand(30..60).days
      scs.status = true
    end
    student_class_subjects << scs3
  end
end

# 12. Tạo điểm cho sinh viên (Grades)
puts "📊 Tạo điểm cho sinh viên..."
grades_created = 0

student_class_subjects.each do |scs|
  # Tạo điểm cho từng loại điểm
  grade_types.values.each do |grade_type|
    score = case grade_type.code
    when "CC" # Chuyên cần
      rand(8.0..10.0).round(1)
    when "BT" # Bài tập  
      rand(6.0..9.5).round(1)
    when "GK" # Giữa kỳ
      rand(5.0..9.0).round(1)
    when "CK" # Cuối kỳ
      rand(4.0..9.5).round(1)
    else
      rand(5.0..9.0).round(1)
    end

    grade = Grade.find_or_create_by!(
      student_class_subject: scs,
      grade_type: grade_type
    ) do |g|
      g.score = score
      g.graded_by = scs.class_subject.teacher
      g.graded_at = Date.current - rand(1..30).days
      g.note = "Điểm #{grade_type.name.downcase}"
    end
    grades_created += 1 if grade.persisted?
  end
end

puts "✅ Hoàn thành tạo dữ liệu mẫu!"
puts "📊 Thống kê:"
puts "   - Năm học: #{AcademicYear.count}"
puts "   - Loại điểm: #{GradeType.count}"
puts "   - Khoa: #{Department.count}"
puts "   - Ngành: #{Major.count}"
puts "   - Giáo viên: #{Teacher.count}"
puts "   - Sinh viên: #{Student.count}"
puts "   - Lớp sinh hoạt: #{StudyClass.count}"
puts "   - Phòng học: #{Room.count}"
puts "   - Môn học: #{Subject.count}"
puts "   - Lớp học phần: #{ClassSubject.count}"
puts "   - Đăng ký lớp học phần: #{StudentClassSubject.count}"
puts "   - Điểm: #{Grade.count}"
puts ""
puts "🔑 Tài khoản mẫu:"
puts "   Admin: admin@university.edu.vn / 123456"
puts "   Giáo viên: teacher1@university.edu.vn / 123456"
puts "   Sinh viên: student1@student.university.edu.vn / 123456"
