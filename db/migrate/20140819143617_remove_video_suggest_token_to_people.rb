class RemoveVideoSuggestTokenToPeople < ActiveRecord::Migration
  def change
    remove_column :people, :video_suggest_token, :string
  end
end
