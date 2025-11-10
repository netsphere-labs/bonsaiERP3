
# Used to create sample data

def create_user_and_org
  user = User.new email: 'demo@example.com', password: 'demo12345'
  user.save!

  #user.confirm_token(user.confirmation_token)
  UserSession.user = user

=begin  
# Countries
YAML.load_file('db/defaults/countries.yml').each do |c|
  OrgCountry.create!(c){|co| co.id = c['id'] }
end
puts "Countries have been created."
# Currencies
YAML.load_file('db/defaults/currencies.yml').each do |c|
  Currency.create!(c) {|cu| cu.id = c['id'] }
end
puts "Currencies have been created."
=end
  
  org = Organisation.create!(name: 'Bonsailabs',
                           # :country_id => 1,
                           country_code: 'JP',
                           currency: 'JPY',
                           phone: '2745620', mobile: '70681101',
                           address: "Mallasa calle 4 Nº 71\n (La Paz - Bolivia)")
  puts "The organisation #{org.name} has been created"

  Link.create! organisation_id: org.id,
               user_id: user.id,
               active: true,
               role:'admin'
end


# main
ActiveRecord::Base.transaction do
  create_user_and_org()
end
