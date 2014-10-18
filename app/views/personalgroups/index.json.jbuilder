#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On crée un tableau de nos groupes personnels en format json
json.array!(@personalgroups) do |personalgroup|
  json.extract! personalgroup, :id, :person_id
  json.url personalgroup_url(personalgroup, format: :json)
end
