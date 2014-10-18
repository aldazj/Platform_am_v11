class CreateGroupsVideoClips < ActiveRecord::Migration
  def change
    create_table :groups_video_clips do |t|
      t.references :group, index: true
      t.references :video_clip, index: true
    end
  end
end
