class AddVideoSuggestTokenSentAtToVideoClips < ActiveRecord::Migration
  def change
    add_column :video_clips, :video_suggest_token_sent_at, :datetime
  end
end
