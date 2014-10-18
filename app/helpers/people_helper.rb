#####################################
# Aldaz Jayro               HEPIA
#
#####################################

module PeopleHelper

    #On vérifie si une personne possède le groupe passé en paramètre
    def group_present?(group)
        !(@person.groups.find_by_id(group).nil?)
    end

    #On vérifie si un personne possède le groupe passé en paramètre
    #dans son personal groupe
    def personal_right_present?(right)
        @personalGroup = Personalgroup.find_by_id(@person.personalgroup)
        !(@personalGroup.rights.find_by_id(right).nil?)
    end

end
