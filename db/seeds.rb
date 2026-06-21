
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
    currency: 'USD',
    stock_fixed_date: Date.today - 2,
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


def make_test_data user
  raise TypeError if !user.is_a?(User)
  
    # BP - contact account
    bp1 = Contact.create! matchcode: "tanaka", name:"田中商事", active:true,
                          client:true, country_code:"JP"
    #bp1_a = ContactAccount.create! contact: bp1 #,
                #account: Account.new(name: "口座JPY", currency:"JPY",
                #                     active:true, description:"",
                #                     subtype: "APAR",
                #                     creator: user)

    bp2 = Contact.create! matchcode: "sato", name:"佐藤商店", active:true,
                          supplier:true, country_code:"JP"
    bp2_a = ContactAccount.create! contact: bp2,
                #account: Account.new(name: "振込先JPY", currency:"JPY",
                #                     active:true, description:"",
                #                     subtype:"APAR",
                #                     creator:user),
                bank_name: "三菱銀行, ふが支店",
                account_no: "1234567",
                account_name: "サトウショウテン"

    uom = Unit.create! name: "Each", symbol:"EA"
    
    store1 = Store.create! name: "店その1", address:"千葉県のどこか", active: true, description: ""
    store2 = Store.create! name: "店その2", address:"福岡県のどこか", active: true, description: ""

    our_bank1 = Cash.create!(
                    account: Account.new(name:"自社口座1", currency:"JPY",
                                         active:true, description:"",
                                         subtype:"A:CASH",
                                         creator:user),
                    bank_name:"住友銀行, ほげ支店",
                    account_no:"456789",
                    account_name:"ジシャコウザ" )

    ac1 = Account.create! name: "棚卸資産:商品", description:"", subtype:"A:INV",
                          active:true,
                          creator:user
    ac2 = Account.create! name: "売上:商品売上", description:"", subtype:"REV",
                          active:true,
                          creator:user
    ac3 = Account.create! name: "変動費:商品仕入", description:"", subtype:"OP:VC",
                          active:true,
                          creator:user
    ac4 = Account.create! name: "変動費:期末商品棚卸高", description:"",
                          subtype:"OP:VC", active:true,
                          creator:user

    ia = ItemAccounting.create! name: "商品の会計",
                                item_type: "HAWA",
                                stock_ac: ac1,
                                revenue_ac: ac2,
                                purchase_ac: ac3,
                                ending_inv_ac: ac4

    item1 = Item.create! name:"商品その1",
                         code: "X1",
                         description:"",
                         unit:uom,
                         buy_price:"123.45",
                         price:"456.78",
                         for_sale:true,
                         accounting:ia,
                         active:true,
                         creator:user
    item2 = Item.create! name:"商品その2",
                         code: "Y2",
                         description:"",
                         unit:uom,
                         buy_price:"1234",
                         price:"3456",
                         for_sale:true,
                         accounting:ia,
                         active:true,
                         creator:user
end


if USE_SUBDOMAIN
  # 2回回ってくる
  if Organisation.count == 0
    make_org_and_admin_user()
  else
    print "Apartment::Tenant.current = ", Apartment::Tenant.current, "\n"
    raise "internal error" if Apartment::Tenant.current == "public"
    
    #org = Organisation.find_by_tenant(Apartment::Tenant.current)
    user = User.first
    make_test_data(user)

    # ここで drop table する
    ActiveRecord::Base.connection.execute("DROP TABLE links")
    ActiveRecord::Base.connection.execute("DROP TABLE organisations")
    ActiveRecord::Base.connection.execute("DROP TABLE users")
  end
else
  ActiveRecord::Base.transaction do
    make_org_and_admin_user()
    make_test_data(User.first)
  end
end # USE_SUBDOMAIN

