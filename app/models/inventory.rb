
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

  # transfer-out の場合   => Use `TransferRequest#trans_to`
  #belongs_to :store_to, class_name: "Store", optional:true
  #validates_presence_of :store_to_id, if: -> r {r.operation == 'out'}
    
  # 購買入庫、販売出庫の場合
  belongs_to :order, optional: true
  validates_presence_of :order_id,
        if: -> r {%w[exp_in pur_tran pit_in inc_out out in].include? r.operation}

  belongs_to :creator, class_name: "User"
  
  # scrap の場合 expense / PO partner
  belongs_to :account, optional:true
  
  belongs_to :project, optional: true

  has_many :details, class_name: "InventoryDetail", dependent: :destroy
  #accepts_nested_attributes_for :inventory_details, allow_destroy: true,
  #                              reject_if: lambda {|attrs| attrs[:quantity].blank? || attrs[:quantity].to_d <= 0 }

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


  def to_s
    ref_number
  end

  # Returns an array with the details fo the transaction
  def get_transaction_items
    transaction.transaction_details
  end

  
  def set_ref_number
    io = Inventory.select("id, ref_number").order("id DESC").limit(1).first

    if io.present?
      self.ref_number = get_ref_io(io)
    else
      self.ref_number = "#{op_ref_type}-#{year}-0001"
    end
  end

=begin
  def movement
    case
    when(is_inc_in? || is_inc_out?)
      income
    when(is_exp_in? || is_exp_out?)
      expense
    end
  end
=end

=begin   pur_tran は in なのか?  blocked にするのは outなのか? など、単純ではない
  def is_in?
    %w(in inc_in exp_in).include? operation
  end

  def is_out?
    %w(out inc_out exp_out).include? operation
  end
=end


  # The caller must initiate a transaction
  def confirm! user
    raise TypeError if !user.is_a?(User)
    #raise TypeError if !org.is_a?(Organisation)
    
    if draft?
      self.state = 'confirmed'
      # TODO: add fields.
      #self.approver_id = user.id
      #self.approver_datetime = Time.zone.now
      update_stock()   # このなかで save!() が走る.
      save!()         
    end
  end


  # journal entry
  # 債権債務が絡む取引は、都度つど仕訳を作る
  # The caller must initiate a transaction
  def gen_je_for_goods_received user
    amt = {}
    self.details.each do |detail|
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
      r = AccountLedger.new date: self.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: pur_ac_id,  # Dr.
                            amount: a,  
                            currency: self.order.currency,
                            description: "goods receipt po",
                            creator_id: user.id,
                            status: 'approved',
                            inventory_id: self.id
      r.save!
      sum_amt += a
    end

    # Cr.
    r = AccountLedger.new date: self.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: self.account_id,
                            amount: -sum_amt,  # 取引通貨, 貸方マイナス
                            currency: self.order.currency,
                            description: "goods receipt po",
                            creator_id: user.id,
                            status: 'approved',
                            inventory_id: self.id
    r.save!
  end

  
  # journal entry
  # 債権債務が絡む取引は、都度つど仕訳を作る
  # The caller must initiate a transaction
  def gen_je_for_delivery user
    raise TypeError if !user.is_a?(User)
    
    amt = {}
    self.details.each do |detail|
      amt[detail.item.accounting.revenue_ac_id] =
                        (amt[detail.item.accounting.revenue_ac_id] || 0) +
                        detail.price * detail.quantity
    end

    entry_no = rand(2_000_000_000)
    # Cr.
    sum_amt = 0
    amt.each do |rev_ac_id, a|
      # TODO: 金額は取引通貨でなければならない。が、機能通貨建てになっている
      #       受入れのときに取引通貨と両方保存が必要
      r = AccountLedger.new date: self.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: rev_ac_id,  # Cr.
                            amount: -a,  # 取引通貨, 貸方マイナス
                            currency: self.order.currency,
                            description: "delivery",
                            creator_id: user.id,
                            status: 'approved',
                            inventory_id: self.id
      r.save!
      sum_amt += a
    end

    # Dr.
    r = AccountLedger.new date: self.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: self.account_id,
                            amount: sum_amt,  # 取引通貨
                            currency: self.order.currency,
                            description: "delivery",
                            creator_id: user.id,
                            status: 'approved',
                            inventory_id: self.id
    r.save!
  end

  
private

  # Update the inventory quantity directly. If the voucher is for before today,
  # it will be accumulated.
  # only for detail items
  def update_stock() 
    case operation
    when 'exp_in'  # 購買入庫
      Stock.change date, store_id, 1, details, +1

    when 'pur_tran' # purchase-in-transit
      Stock.change date, store_id, 10, details, +1
          
    when 'pit_in' # PIT -> IN
      # There may be a change in quantity. Call the original `inventory` and
      # subtract it.
      orig = Inventory.eager_load(:details)
                      .where(order_id: order_id, operation:'pur_tran').take
      Stock.change date, orig.store_id, 10, orig.details, -1
      Stock.change date, store_id, 1, details, +1
          
    when 'exp_out' # 仕入戻し
      Stock.change date, store_id, 1, details, -1

    when 'inc_out'  # 販売出庫 w/ order
      Stock.change date, store_id, 1, details, -1

    when 'inc_in'   # 顧客返品
      Stock.change date, store_id, 1, details, +1

    when 'out'     # 転送出庫
      Stock.change date, store_id, 1, details, -1
      Stock.change date, order.trans_to_id, 5, details, +1
          
    when 'in'      # 転送入庫
      Stock.change date, order.store_id, 5, details, -1
      Stock.change date, store_id, 1, details, +1
          
    when 'trans'   # 1-step transfer
      raise "not implemented"
    else
      raise "internal error"
    end
  end


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

=begin
    def op_ref_type
      case
      when is_in?    then "I"
      when is_out?   then "E"
      when is_trans? then "T"
      end
    end
=end
    
end # of class Inventory
