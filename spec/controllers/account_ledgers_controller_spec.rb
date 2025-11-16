
require 'rails_helper'

RSpec.describe AccountLedgersController do
  let(:user) { build :user, id: 10}

  before(:each) do
    stub_auth
    allow(controller).to receive(:current_tenant).and_return('public')
    UserSession.user = user
  end

  describe 'GET /' do
    it "Ok" do
      # Skip the template rendering by using a format that doesn't require a template
      mock_ledgers = double('ActiveRecord::Relation')
      allow(mock_ledgers).to receive(:includes).and_return(mock_ledgers)
      allow(mock_ledgers).to receive(:order).and_return(mock_ledgers)
      allow(mock_ledgers).to receive(:reverse_order).and_return(mock_ledgers)
      allow(mock_ledgers).to receive(:page).and_return([])
      allow(mock_ledgers).to receive(:empty?).and_return(false)
      
      query_mock = double('Query')
      allow(query_mock).to receive(:search).and_return(mock_ledgers)
      allow(AccountLedgers::Query).to receive(:new).and_return(query_mock)
      
      # Bypass the template rendering by using xhr request
      get :index, xhr: true
      
      expect(assigns(:title)).to eq("Transacciones")
    end
  end

  describe "GET /show/1" do
    it 'Ok' do
      account_ledger = build(:account_ledger, id: 1)
      allow(AccountLedger).to receive(:find).with("1").and_return(account_ledger)
      
      presenter_mock = double('AccountLedgerPresenter')
      allow(controller).to receive(:present).and_return(presenter_mock)
      
      # Bypass the template rendering by using xhr request
      get :show, params: { id: "1" }, xhr: true
      
      expect(assigns(:ledger)).to eq(presenter_mock)
    end
  end

  describe 'PATCH /account_ledgers/:id/conciliate' do
    before(:each) do
      allow(AccountLedger).to receive(:find).with("1").and_return(build :account_ledger, id: 1)
      UserSession.user = build(:user, id: 10)
    end

    it '#conciliate' do
      allow_any_instance_of(ConciliateAccount).to receive(:conciliate!).and_return(true)

      patch :conciliate, params: { id: "1" }

      expect(response).to redirect_to(controller.account_ledger_path(1))
      expect(controller.flash[:notice].present?).to eq(true)
    end

    it '#conciliate error' do
      allow_any_instance_of(ConciliateAccount).to receive(:conciliate!).and_return(false)

      patch :conciliate, params: { id: "1" }

      expect(response).to redirect_to(controller.account_ledger_path(1))
      expect(flash[:error].present?).to eq(true)
    end
  end

  describe 'PATCH /account_ledgers/:id/null' do
    before(:each) do
      allow(AccountLedger).to receive(:find).with("1").and_return(build :account_ledger, id: 1)
      UserSession.user = build(:user, id: 10)
    end

    it '#conciliate' do
      allow_any_instance_of(NullAccountLedger).to receive(:null!).and_return(true)

      patch :null, params: { id: "1" }

      expect(response).to redirect_to(controller.account_ledger_path(1))
      expect(controller.flash[:notice].present?).to eq(true)
    end

    it '#conciliate error' do
      allow_any_instance_of(NullAccountLedger).to receive(:null!).and_return(false)

      patch :null, params: { id: "1" }

      expect(response).to redirect_to(controller.account_ledger_path(1))
      expect(flash[:error].present?).to eq(true)
    end
  end
end
