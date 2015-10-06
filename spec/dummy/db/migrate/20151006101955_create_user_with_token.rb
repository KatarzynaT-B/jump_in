class CreateUserWithToken < ActiveRecord::Migration
  def change
    create_table :user_with_tokens do |t|
      t.string :jumpin_token
    end
  end
end
