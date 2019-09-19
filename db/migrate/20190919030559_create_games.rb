class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :players
      t.string :scores
      
      t.timestamps
    end
  end
end