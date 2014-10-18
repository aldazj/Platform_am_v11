class AddVideoSuggestTokenToPeople < ActiveRecord::Migration
  def change
    add_column :people, :video_suggest_token, :string
  end
end
