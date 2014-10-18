#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On crée un tableau de nos commentaire en format json
json.array!(@comments) do |comment|
  json.extract! comment, :id, :message, :is_available, :date, :url, :videoitem_id
  json.url comment_url(comment, format: :json)
end
