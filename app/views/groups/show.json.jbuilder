#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On recupère un groupe en format json
#Cette partie json est utilisée par les mails
#Il faut absolument avoir une variable name pour que l'autocompletion
#fonctionne.
#Lire la documentation pour voir comment le tokeninput fonctionne:
#http://loopj.com/jquery-tokeninput/
json.extract! @group, :id, :name, :created_at, :updated_at
