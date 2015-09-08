class RenameUsersToUserWithSecurePasswords < ActiveRecord::Migration
  def change
    rename_table :users, :user_with_secure_passwords
  end
end
