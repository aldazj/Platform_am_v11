#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class PersonMailer < ActionMailer::Base
  #default from: "platform4am@gmail.com" On peut définir une seule fois si on désire

  #En-tête pour le mail qui enregistre un nouveau utilisateur
  def registration_mail(person)
    @person = person
    mail(
      :to =>  person.email,
      :from    => "platform4am@gmail.com",
      :subject => "Registration Platform 4AM",
    )
  end

  #En-tête pour le mail qui permet de modifier un mot de passe
  def password_reset(person)
    @person = person
    mail(
      :to =>  person.email,
      :from    => "platform4am@gmail.com",
      :subject => "Password Reset"
    )
  end

  #En-tête pour le mail qui suggère des vidéos à des utilisateurs
  def send_video(subject, mail, videos, message)
    @person = Person.find_by_email(mail)
    @videos = videos
    @message = message
    mail(
        :to =>  mail,
        :from    => "platform4am@gmail.com",
        :subject => subject
    )
  end

end
