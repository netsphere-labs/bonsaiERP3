
# Create sample data.

# Apartment の使い方は、ここが詳しい
#   https://qiita.com/kakipo/items/a584d24771dff019d3a9
#   Apartment でマルチテナントサービスを作成する

# `rails db:seed` で, 2回呼び出される.
# 1回目: `Organisation` の生成.
# `db:seed` の完了後:
#    1. 自動的にテナントの生成 = スキーマのコピー
#    2. `rails db:seed` の再呼び出し.
#       この挙動は `config.seed_after_create`

puts "Creating seed data for BonsaiERP..."


# Create organization with a unique tenant name
def make_org_and_admin_user()
  org_name = "Kintsugi"

  org = Organisation.new(
    name: org_name,
    inventory_active: true,
    country_code: 'JP',
    time_zone: TZInfo::Timezone.get('Asia/Tokyo').name,
    currency: 'JPY',
    email: 'info@kintsugi.design'
  )
if USE_SUBDOMAIN
  org.tenant = "kintsugi97890" # ホスト名のテストのため固定
else
  org.tenant = "public"
end

  # Save the organization
  org.save!
  puts "Organization '#{org.name}' has been created with tenant '#{org.tenant}'"
  
  # Create admin user
  user = User.new(
    email: 'admin@kintsugi.design',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Admin',
    last_name: 'User'
  )
  
  # Set confirmation token and confirm the user
  user.set_confirmation_token if user.respond_to?(:set_confirmation_token)
  user.confirmed_at = Time.now if user.respond_to?(:confirmed_at=)
  
  # Create link between user and organization
  link = user.active_links.build(
    organisation_id: org.id,
    #tenant: org.tenant,
    role: 'admin',
    master_account: true,
    active: true,
    api_token: SecureRandom.urlsafe_base64(32)
  )
  
  user.save!
  puts "User #{user.email} has been created with password: password123"
    
    # Note: We don't need to create OrgCountry records as the app uses the Country model
    # which is a Struct based on the COUNTRIES constant
    
    
  puts "\n==============================================="
  puts "Seed data created successfully!"
  puts "You can now login with:"
  puts "Email: admin@kintsugi.design"
  puts "Password: password123"
  puts "Tenant: #{org.tenant}"
  puts "==============================================="
end


if Organisation.count == 0
  make_org_and_admin_user()
else
  # ここで drop table する
  print "Apartment::Tenant.current = ", Apartment::Tenant.current, "\n"
  if Apartment::Tenant.current != "public"
    ActiveRecord::Base.connection.execute("DROP TABLE links")
    ActiveRecord::Base.connection.execute("DROP TABLE organisations")
    ActiveRecord::Base.connection.execute("DROP TABLE users")
  end
end

