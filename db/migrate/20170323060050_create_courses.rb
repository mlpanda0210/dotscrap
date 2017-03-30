class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.string :topic
      t.string :url
      t.string :date
      t.string :address
      t.string :place

      t.timestamps
    end
  end
end
