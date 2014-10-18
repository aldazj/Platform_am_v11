#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On crée un tableau de nos personnes en format json
#Important pour l'autocompletion dans la page qui envoie les mails
json.array!(@people) do |person|
  json.extract! person, :id, :lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :name
  json.url person_url(person, format: :json)
end
