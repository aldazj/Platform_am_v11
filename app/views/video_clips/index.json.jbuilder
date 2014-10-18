#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On crée un tableau de nos vidéos en format json
#Important pour l'autocompletion dans la page qui envoie les mails
json.array!(@video_clips) do |video_clip|
  json.extract! video_clip, :id, :title, :description, :is_available, :date, :views
  json.url video_clip_url(video_clip, format: :json)
end
