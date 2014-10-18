class AddPasswordResetToPeople < ActiveRecord::Migration
  def change
    add_column :people, :password_reset_token, :string
    add_column :people, :password_reset_sent_at, :datetime
  end
end
