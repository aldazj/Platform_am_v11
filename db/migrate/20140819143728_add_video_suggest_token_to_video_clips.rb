class AddVideoSuggestTokenToVideoClips < ActiveRecord::Migration
  def change
    add_column :video_clips, :video_suggest_token, :string
  end
end
