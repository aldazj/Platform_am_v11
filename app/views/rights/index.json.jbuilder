#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On crée un tableau de nos droits en format json
json.array!(@rights) do |right|
  json.extract! right, :id, :name, :is_available
  json.url right_url(right, format: :json)
end
