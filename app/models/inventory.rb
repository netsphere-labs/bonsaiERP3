
# author: Boris Barroso
# email: boriscyber@gmail.com

# 入出庫伝票
class Inventory < BusinessRecord

  #include ::Models::Updater

  # exp_in  購買入庫
  # pur_tran  purchase-in-transit
  # pit_in  PIT -> IN
  # exp_out 仕入戻し
  # inc_out 販売出庫
  # inc_in  顧客返品
  # in      転送入庫
  # out     転送出庫
  # trans   1-step transfer
  OPERATIONS = %w(in out inc_in inc_out exp_in exp_out trans pur_tran pit_in).freeze

  STATES = %w(draft confirmed void).freeze
  enum :state, STATES.map{|x| [x,x]}.to_h
  
  # 親
  belongs_to :store

  # transfer-out の場合
  belongs_to :store_to, class_name: "Store", optional:true

  # 購買入庫、販売出庫の場合
  belongs_to :order, optional: true
  
  belongs_to :creator, class_name: "User"
  
  # scrap の場合 expense / PO partner
  belongs_to :account, optional:true
  
  belongs_to :project, optional: true
  #has_one    :transference, :class_name => 'InventoryOperation', :foreign_key => "transference_id"

  has_many :details, class_name: "InventoryDetail", dependent: :destroy
  #accepts_nested_attributes_for :inventory_details, allow_destroy: true,
  #                              reject_if: lambda {|attrs| attrs[:quantity].blank? || attrs[:quantity].to_d <= 0 }
  #alias :details :inventory_details

  # Validations
  validates_presence_of :date
  
  # 購買入庫, 販売出庫 with order の場合のみ
  #validates_presence_of :ref_number,
  #              if: -> x {%w(exp_in inc_out).include?(x.operation) }
  
  validates_inclusion_of :operation, in: OPERATIONS
  validates_lengths_from_database

  OPERATIONS.each do |_op|
    define_method :"is_#{_op}?" do
      _op === operation
    end
  end

  #with_options :if => :transout? do |inv|
    #inv.validates_presence_of :store_to
  #end

  def is_transference?
    %w(transin transout).include?(operation)
  end

  def to_s
    ref_number
  end

  # Returns an array with the details fo the transaction
  def get_transaction_items
    transaction.transaction_details
  end

=begin
  def is_income?
    is_inc_in? || is_inc_out?
  end

  def is_expense?
    is_exp_in? || is_exp_out?
  end
=end
  
  def set_ref_number
    io = Inventory.select("id, ref_number").order("id DESC").limit(1).first

    if io.present?
      self.ref_number = get_ref_io(io)
    else
      self.ref_number = "#{op_ref_type}-#{year}-0001"
    end
  end

  def movement
    case
    when(is_inc_in? || is_inc_out?)
      income
    when(is_exp_in? || is_exp_out?)
      expense
    end
  end

  def is_in?
    %w(in inc_in exp_in).include? operation
  end

  def is_out?
    %w(out inc_out exp_out).include? operation
  end


  # `save()` must be done by caller.
  def confirm! user
    raise TypeError if !user.is_a?(User)
    
    if draft?
      self.state = 'confirmed'
      # TODO: add fields.
      #self.approver_id = user.id
      #self.approver_datetime = Time.zone.now
    end
  end

  
  # journal entry
  # 債権債務が絡む取引は、都度つど仕訳を作る
  def gen_je_for_goods_received
    amt = {}
    @inv.details.each do |detail|
      # 三分法でやってみる
      amt[detail.item.accounting.purchase_ac_id] =
                        (amt[detail.item.accounting.purchase_ac_id] || 0) +
                        detail.price * detail.quantity  # ここは機能通貨
    end

    entry_no = rand(2_000_000_000)
    # Dr.
    sum_amt = 0
    amt.each do |pur_ac_id, a|
      # TODO: 金額は取引通貨でなければならない。が、機能通貨建てになっている
      #       受入れのときに取引通貨と両方保存が必要
          
      r = AccountLedger.new date: @inv.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: pur_ac_id,  # Dr.
                            amount: a,  
                            currency: @inv.order.currency,
                            description: "goods receipt po",
                            creator_id: current_user.id,
                            status: 'approved',
                            inventory_id: @inv.id
      r.save!
      sum_amt += a
    end

    # Cr.
    r = AccountLedger.new date: @inv.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: @inv.account_id,
                            amount: -sum_amt,  # 取引通貨, 貸方マイナス
                            currency: @inv.order.currency,
                            description: "goods receipt po",
                            creator_id: current_user.id,
                            status: 'approved',
                            inventory_id: @inv.id
    r.save!
  end

  
private

    def get_ref_io(io)
      _, y, _ = io.ref_number.split('-')
      if y === year
        "#{op_ref_type}-#{year}-#{"%04\d" % io.id.next}"
      else
        "#{op_ref_type}-#{year}-0001"
      end
    end

    def year
      @year ||= Time.zone.now.year.to_s[2..4]
    end

    def op_ref_type
      case
      when is_in?    then "I"
      when is_out?   then "E"
      when is_trans? then "T"
      end
    end
end
