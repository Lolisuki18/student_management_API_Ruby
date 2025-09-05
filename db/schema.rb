# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_27_125546) do
  create_table "academic_years", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.boolean "is_current", default: false
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_current"], name: "index_academic_years_on_is_current"
    t.index ["name"], name: "index_academic_years_on_name", unique: true
  end

  create_table "class_subjects", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "teacher_id", null: false
    t.string "class_code", null: false
    t.string "academic_year", null: false
    t.integer "semester", null: false
    t.integer "max_students", default: 40
    t.integer "current_students", default: 0
    t.bigint "room_id"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year", "semester"], name: "index_class_subjects_on_academic_year_and_semester"
    t.index ["class_code"], name: "index_class_subjects_on_class_code", unique: true
    t.index ["room_id"], name: "index_class_subjects_on_room_id"
    t.index ["subject_id", "teacher_id"], name: "index_class_subjects_on_subject_id_and_teacher_id"
    t.index ["subject_id"], name: "index_class_subjects_on_subject_id"
    t.index ["teacher_id"], name: "index_class_subjects_on_teacher_id"
  end

  create_table "classes", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.bigint "major_id", null: false
    t.string "academic_year", null: false
    t.integer "semester", null: false
    t.bigint "homeroom_teacher_id"
    t.integer "max_students", default: 40
    t.integer "current_students", default: 0
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year", "semester"], name: "index_classes_on_academic_year_and_semester"
    t.index ["code"], name: "index_classes_on_code", unique: true
    t.index ["homeroom_teacher_id"], name: "index_classes_on_homeroom_teacher_id"
    t.index ["major_id"], name: "index_classes_on_major_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.integer "head_teacher_id"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["head_teacher_id"], name: "index_departments_on_head_teacher_id"
  end

  create_table "grades", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "majors", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.integer "duration_years", default: 4
    t.bigint "department_id", null: false
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_majors_on_code", unique: true
    t.index ["department_id"], name: "index_majors_on_department_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "capacity", default: 40
    t.string "building"
    t.string "floor"
    t.text "equipment"
    t.string "room_type", default: "classroom"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building", "floor"], name: "index_rooms_on_building_and_floor"
    t.index ["code"], name: "index_rooms_on_code", unique: true
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_class_subjects", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "class_subject_id", null: false
    t.date "enrollment_date", default: -> { "getdate()" }
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_subject_id"], name: "index_student_class_subjects_on_class_subject_id"
    t.index ["student_id", "class_subject_id"], name: "idx_student_class_subject_unique", unique: true
    t.index ["student_id"], name: "index_student_class_subjects_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "student_code", null: false
    t.string "full_name", null: false
    t.date "date_of_birth"
    t.string "gender"
    t.string "phone"
    t.text "address"
    t.bigint "major_id", null: false
    t.integer "enrollment_year"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "study_class_id"
    t.index ["enrollment_year"], name: "index_students_on_enrollment_year"
    t.index ["major_id"], name: "index_students_on_major_id"
    t.index ["student_code"], name: "index_students_on_student_code", unique: true
    t.index ["study_class_id"], name: "index_students_on_study_class_id"
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "credits", null: false
    t.integer "theory_hours", default: 0
    t.integer "practice_hours", default: 0
    t.bigint "major_id", null: false
    t.integer "semester_number"
    t.boolean "is_required", default: true
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
    t.index ["major_id", "semester_number"], name: "index_subjects_on_major_id_and_semester_number"
    t.index ["major_id"], name: "index_subjects_on_major_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "teacher_code", null: false
    t.string "full_name", null: false
    t.string "phone"
    t.string "email"
    t.bigint "department_id", null: false
    t.string "position"
    t.date "hire_date"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_teachers_on_department_id"
    t.index ["email"], name: "index_teachers_on_email", unique: true
    t.index ["teacher_code"], name: "index_teachers_on_teacher_code", unique: true
    t.index ["user_id"], name: "index_teachers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "student", null: false
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "class_subjects", "rooms"
  add_foreign_key "class_subjects", "subjects"
  add_foreign_key "class_subjects", "teachers"
  add_foreign_key "classes", "majors"
  add_foreign_key "classes", "teachers", column: "homeroom_teacher_id"
  add_foreign_key "majors", "departments"
  add_foreign_key "student_class_subjects", "class_subjects"
  add_foreign_key "student_class_subjects", "students"
  add_foreign_key "students", "classes", column: "study_class_id"
  add_foreign_key "students", "majors"
  add_foreign_key "students", "users"
  add_foreign_key "subjects", "majors"
  add_foreign_key "teachers", "departments"
  add_foreign_key "teachers", "users"
end
