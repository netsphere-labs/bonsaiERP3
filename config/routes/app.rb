get '/download_pdf/:file/:name' => 'download#download_pdf', as: :download

#resources :movement_details_history, only: [:show]
get '/movement_details_history/:id' => 'movement_details_history#show', as: :movement_detail_history

# Batch payments
post 'batch_paymets/income' => 'batch_payments#income', as: :income_batch_payments

post 'batch_paymets/expense' => 'batch_payments#expense', as: :expense_batch_payments

resources :attachments, only: [:create, :update, :destroy]

resources :tags do
  patch :update_models, on: :collection
end

resources :tag_groups

resources :export_expenses, only: [:index, :create]

resources :export_incomes, only: [:index, :create]

resources :admin_users, except: [:index] do
  patch :active, on: :member
end

resources :configurations, only: [:index]


######################################################################
# Master Data

# 商品・アイテム
resources :items do
  get :search_income, on: :collection
  get :search_expense, on: :collection
  get :search_inventory, on: :member
end

# UoM
resources :units

# 取引先
resources :partners do
  resources :contact_accounts  # Account から派生
  
  get :incomes, on: :member
  get :expenses, on: :member
end


######################################################################
# Finance

# 自社の銀行口座・現金マスタ
resources :cashes do
  get :money, on: :collection
end

# ●●削除してよいか?
resources :staff_accounts

# G/L
resources :account_ledgers, only: [:index, :show, :update] do
  post :transference, on: :collection
  patch :conciliate, on: :member
  patch :null, on: :member
end

# 振替伝票, 会計仕訳
resources :transferences #, only: [:new, :create]

resources :item_accountings

resources :payments  do
  member do
    get :new_income
    post :income
    get :new_expense
    post :expense
  end
end

resources :taxes

# controller_name = `reports_controller`
# `#index` はリポートを一覧表示する
resources :reports do
  collection do
    get :schedule
  end
end


get 'inventory_report' => 'reports#inventory', as: :inventory_report

# Loans. 借入れごとに勘定科目を作る.
resources :loans, only: [:index, :show, :update] do
  collection do
    get :new_receive
    post :receive
    get :new_give
    post :give
  end

  resources :loan_payments, only: [] do
    member do
      # Receive
      get :new_pay
      post :pay
      get :new_pay_interest
      post :pay_interest
      # Give
      get :new_charge
      post :charge
      get :new_charge_interest
      post :charge_interest
    end
  end
end

# Loans ledger_in
get 'loan_ledger_ins/:id/new_give' => 'loan_ledger_ins#new_give', as: :new_give_loan_ledger_in
patch 'loan_ledger_ins/:id/give' => 'loan_ledger_ins#give', as: :give_loan_ledger_in
get 'loan_ledger_ins/:id/new_receive' => 'loan_ledger_ins#new_receive', as: :new_receive_loan_ledger_in
patch 'loan_ledger_ins/:id/receive' => 'loan_ledger_ins#receive', as: :receive_loan_ledger_in


######################################################################
# Sales 

resources :sales_orders do
  member do
    patch :confirm
    patch :void
    patch :inventory
  end
end

# 「devolution」のスペイン語訳は、文脈によって異なりますが、「返却・払い戻し」を意味するdevolución（発音は「デボルーショーン」）や、
resources :devolutions do
  member do
    get :new_income
    post :income
    get :new_expense
    post :expense
  end
end


######################################################################
# Purchasing

resources :purchase_orders do
  member do
    patch :confirm
    patch :void
    patch :inventory
  end
end

resources :goods_return_requests do
  member do
    patch :confirm
    patch :void
  end
end


######################################################################
# Inventory

resources :transfer_requests

# In-Store Operations
resources :stores do
  resources :goods_receipt_pos do
    member do
      post :confirm
    end
  end

  # return to supplier
  resources :goods_returns

  # 出荷/納入
  resources :deliveries do
    member do
      post :confirm
    end
  end

  resources :customer_returns

  # inventory transfer in two-steps
  resources :inventory_outs
  resources :inventory_ins

  # one-step transfer w/o order
  resources :inventory_transferences #, only: [:new, :create, :show]
end


# 在庫
resources :stocks

# 入出庫伝票
resources :inventories, only: [:index, :show] do
  get :show_movement, on: :member
  get :show_trans, on: :member
end


######################################################################
# Project

# Production Orders
resources :prod_orders


######################################################################

# Admin only: 組織
resources :organisations #, only: [:new, :update]

resources :organisation_updates, only: [:edit, :update]

resources :user_passwords, only: [:new, :create] do
  collection do
    get :new_default
    post :create_default
  end
end

# Admin only.
resources :users, only: [:show, :edit, :update]

get '/dashboard' => 'dashboard#show', as: :dashboard
get '/home' => 'dashboard#home', as: :home

# No auth
resources :registrations do
  # Checks the confirmation_token of users added by admin
  get :new_user, on: :member
end

get '/sign_up' => 'registrations#new'

# No auth
# Password
resources :reset_passwords, only: [:index, :new, :create, :edit, :update]
# No auth

# 単数形. コントローラ名は `user_sessions`.
resource :user_session, only: [:new, :create, :destroy]
#get '/sign_in'  => 'sessions#new', as: :login
#get '/sign_out' => 'sessions#destroy', as: :logout

# Tests
resources :tests
get '/kitchen' => 'tests#kitchen' # Tests

# 例外を捕捉すること
#get '/404', to: 'errors#page_not_found'
#get '/422', to: 'errors#unacceptable'
#get '/500', to: 'errors#internal_error'
