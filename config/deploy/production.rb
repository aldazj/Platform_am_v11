#####################################
# Aldaz Jayro               HEPIA
#
#####################################
#Configuration pour le deploiement

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role

=begin
role :app, '54.187.247.213'
role :web, '54.187.247.213'
role :db,  '54.187.247.213'
=end

=begin
role :app, '54.75.232.77'
role :web, '54.75.232.77'
role :db,  '54.75.232.77'
=end

role :app, '54.76.150.237'
role :web, '54.76.150.237'
role :db,  '54.76.150.237'

set :stage, :production

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
#server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value

#INDE
#server '14.139.34.31', user: 'ubuntu-vm-one', roles: %w{web app db}, my_property: :my_value
#server '54.75.232.77', user: 'ubuntu', roles: %w{web app db}, my_property: :my_value

#Server RTS TAMEDIA
server '54.76.150.237', user: 'ubuntu', roles: %w{web app db}, my_property: :my_value

set :ssh_options, {
  #keys: %w(/home/aldazj/Bureau/aldazj_key.pem),
  #keys: %w(/home/aldazj/Bureau/hepia-project.pem),
  keys: %w(/home/aldazj/4AM/Projects/Tamedia/yma-eu.pem),
  forward_agent: false,
  #password:'**********'
}

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options
