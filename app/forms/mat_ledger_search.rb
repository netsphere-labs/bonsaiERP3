
class MatLedgerSearch < BaseForm
  attribute :text, :string

  attribute :from, :date
  attribute :to, :date

  # 品目は必須
  attribute :item_id, :integer
  
  attribute :store_id, :integer
  attribute :invt_type, :integer


  # @return [Array of InventoryDetail]
  def search()
    raise ArgumentError, "品目は必須" if item_id.blank?
  
    ret = InventoryDetail.joins(:inventory).where(item_id: item_id)
    ret = ret.where("ref_number ILIKE :s OR description ILIKE :s ", s: text) if !text.blank?
    ret = ret.where("inventories.date >= ?", from) if !from.blank?
    ret = ret.where("inventories.date <= ?", to) if !to.blank?
    ret = ret.where(store_id: store_id) if !store_id.blank?
    
    return ret
  end
end

