#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On recupère une personne en format json
#Cette partie json est utilisée par les mails
#Normalement la librarie JQuery tokeninput utilise la variable "name" pour l'autocompletion mais ici
#j'ai utilisé le paramètre "title" pour faire l'autocompletion.
#Donc dans la page views->sendvidéos->index on doit mettre:
#     propertyToSearch: 'title'
#Pour faire l'autocomplétion désirée

#Lire la documentation pour voir comment le tokeninput fonctionne:
#http://loopj.com/jquery-tokeninput/

json.extract! @video_clip, :id, :title, :description, :is_available, :date, :views, :created_at, :updated_at
