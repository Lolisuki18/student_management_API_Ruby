class RenameClassesToStudyClasses < ActiveRecord::Migration[8.0]
  def change
    rename_table :classes, :study_classes
  end
end
