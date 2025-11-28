
# class to help search
class Movements::Search < BaseForm
  attribute :search, :string
  attribute :date_start, :date
  attribute :date_end, :date

  attribute :state, array: true, default: ['draft', 'confirmed', 'in_transit', 'delivered']
  attribute :overdue, :date

  
  # @param model [Class] SalesOrder or PurchaseOrder
  def search_by_text model
    ret = model.where(state: state)
    ret = ret.where('date >= ?', date_start) if !date_start.nil?
    ret = ret.where('date <= ?', date_end) if !date_end.nil?
    
    if !search.blank?
      ret = ret.joins(:details).where('movement_details.description ILIKE :s',
                                      s: "%{search}%")
      #s = s.where("accounts.name ILIKE :s OR accounts.description ILIKE :s OR contacts.matchcode ILIKE :s", s: "%#{ args[:search] }%")
    end
    #s = get_state(s)

    return ret
  end

  
private

=begin
  def get_state(s)
      case args[:state]
      when 'draft', 'approved', 'nulled', 'paid'
        s.where(state: args[:state])
      when 'due'
        s.where("accounts.state = ? AND accounts.due_date <= ?", 'approved', Date.today)
      when 'error'
        s.where(has_error: true)
      else
        s
      end
    end
=end
  
end
