#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On crée un tableau de nos groups en format json
#Important pour l'autocompletion dans la page qui envoie les mails

json.array!(@groups) do |group|
  json.extract! group, :id, :name
  json.url group_url(group, format: :json)
end
