class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string  :name,        null: false
      t.string  :client,      null: false
      t.date    :start_date,  null: false
      t.date    :end_date,    null: false
      t.text    :cover_image
      t.boolean :is_favorite, null: false, default: false
      t.timestamps
    end
  end
end
