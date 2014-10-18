#####################################
# Aldaz Jayro               HEPIA
#
#####################################

module ApplicationHelper

  #Fonction utilisée pour trier la liste des utilisateurs
  #selon les différentes columnes (nom, prénom) dans l'ordre
  #alphabetique
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
  end

end
